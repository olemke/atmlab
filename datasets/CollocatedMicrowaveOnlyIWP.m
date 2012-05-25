classdef CollocatedMicrowaveOnlyIWP < HomemadeDataset
    % Class holding functionality for Gerrits most primivite IWP dataset
    %
    % This class performs two major roles:
    %
    % - Reading and locating granules, mostly inherited from SatDataset
    % - Retrieving IWP
    %
    % The second task depends on the Neural Network Toolbox, tested with
    % version 7.0.3 (R2012a).
    %
    % TODO:
    %
    %   - Different networks for different viewing angles or viewing angle
    %   as an input
    %   - Same for different latitude regions
    %   - Better way to treat different versions in parallel
    
    % $Id$
    
    properties
        nets = struct();
        nchannels = 3;
        data;
        localcols;
    end
       
    properties (GetAccess = private, SetAccess = private)
       selection; 
       maxsize = 20000; % max number of entries for neural net
       retrieval_limits;
       training_limits;
       fromfile;
    end
    
    properties (Constant)
        version = 0.3;
        changelog = [...
            'version 0.0: initial version, negative IWP, linear all\n' ...
            'version 0.1: cf [0, 1], log-IWP retrieved, more descriptive atts\n', ...
            'version 0.2: more descriptive atts, cf -> cf100, improved training sel\n' ...
            'version 0.3: added lza, pos, line, fromfile; apply more lims; apply same lims to retrieved as to trained (afap)'];
    end
    
    methods
        function self = CollocatedMicrowaveOnlyIWP(varargin)
            self = self@HomemadeDataset(varargin{:});
            self.setcols();
            self.setmembers();
            self.reader = @(varargin) (common_read_netcdf_dataset(self, varargin{:}));
            self.training_limits.retrieval = struct(...
                'MEAN_ROIWP', [eps inf], ... % positive
                'NO_ROIWP', [10 inf], ... % at least 10
                'FRAC1_ROIWP', [1 1], ... % fully cloudy
                'CV_ROIWP', [0 1]); % sd <= mean
        end
        
        function getdata(self, start_date, end_date)
            d = datasets;
            
            self.retrieval_limits = ...
                struct('LAT1', [-30 30], ...
                       'POS1', [40 50], ...
                       'B_BT', [0 400]);
            
            [M, c] = d.CollocatedDataset_mhs_cpr.read(...
                start_date, end_date, 'noaa18', ...
                {'LAT1', 'LON1', 'POS1', 'TIME1', 'B_BT', 'B_LZA', ...
                 'NO_ROIWP', 'MEAN_ROIWP', 'CV_ROIWP', 'FRAC1_ROIWP', 'FRAC10_ROIWP', 'FRAC100_ROIWP', 'FRAC1000_ROIWP'}, ...
                 self.retrieval_limits);
             
             self.data = M;
             self.localcols = c;
             if size(M, 1) > self.maxsize
                 self.selection = unique(round(linspace(1, size(M, 1), self.maxsize)));
             else
                 self.selection = 1:size(M, 1);
             end
        end
        
        function make_retrieval_net(self)
            % prepare neural network with BT and IWP
            %
            % takes BT, IWP. Warning; each row is a channel, each column a
            % collocation. This is opposite of Collocations Toolbox.
                        
            self.needsbox();
            if isempty(self.data)
                error(['atmlab:' mfilename ':nodata'], ...
                    'No data found. Did you run .getdata(...)?');
            end
%            subdat = self.data(self.selection, :);
            dat = self.data;
            dat = dat(collocation_restrain(dat, limstruct2limmat(self.training_limits.retrieval, self.localcols)), :);
            
            if size(dat, 1) > self.maxsize
                subsel = unique(round(linspace(1, size(dat, 1), self.maxsize)));
                dat = dat(subsel, :);
                logtext(atmlab('OUT'), 'Reducing to %d points before training\n', self.maxsize);
            end
            
            BT = dat(:, self.localcols.B_BT(3:5));
            IWP = dat(:, self.localcols.MEAN_ROIWP);

            net = fitnet(6);
            net.trainParam.showWindow = false;
            logtext(atmlab('OUT'), 'Training...\n');
            net = train(net, BT.', log10(IWP).');
            logtext(atmlab('OUT'), 'Trained\n');
            self.nets.retrieval = net;
            self.nets.retrieval.userdata.retrieval_limits = self.retrieval_limits;
            self.nets.retrieval.userdata.training_limits = self.training_limits;
        end
        
        function make_classification_net(self)
            % prepare neural net with BT and cloudfrac
            
            self.needsbox();
            BT = self.data(self.selection, self.localcols.B_BT(3:5)).';
            cloudfrac100 = self.data(self.selection, self.localcols.FRAC100_ROIWP).';
            net = patternnet(6);
            net.trainParam.showWindow = false;
            logtext(atmlab('OUT'), 'Training...\n');
            net = train(net, BT, cloudfrac100);
            logtext(atmlab('OUT'), 'Trained\n');
            self.nets.classification100 = net;
            self.nets.classification100.userdata.retrieval_limits = self.retrieval_limits;
            self.nets.classification100.userdata.training_limits = self.training_limits;
        end
        
        function storenets(self, fl)
            self.needsbox();
            self.fromfile = fullfile(self.basedir, fl);
            logtext(atmlab('OUT'), 'Storing networks to %s\n', self.fromfile);
            fns = fieldnames(self.nets);
            for i = 1:length(fns)
                if isa(self.nets.(fns{i}), 'network')
                    self.nets.(fns{i}).userdata.stored = self.fromfile;
                end
            end
            nt = self.nets; %#ok<NASGU>               
            save(self.fromfile, 'nt');
        end
        
        function loadnets(self, fl)
            self.needsbox();
            self.fromfile = fullfile(self.basedir, fl);
            logtext(atmlab('OUT'), 'Loading networks from %s\n', self.fromfile);
            self.nets = loadvar(self.fromfile, 'nt');
        end
        
        function retrieve_and_store_gran(self, dt, spec)
            self.needsbox();
            if isempty(self.fromfile)
                error(['atmlab:' mfilename ':nonet'], ...
                    'First get network from or store network to file!');
            end
            d = datasets;
            ds = d.(amsub_or_mhs(spec));
            grandata = ds.read_granule(dt, spec);
            %graninfo = ds.find_info_from_granule(ds.find_granule_by_datetime(dt, spec));
            grandata.pos = repmat((1:size(grandata.lat, 2)), [size(grandata.lat, 1), 1]);
            grandata.line = repmat((1:size(grandata.lat, 1)).', [1 size(grandata.lat, 2)]);
            grandata.time = repmat(grandata.time, [1 90]);
            
            mytb = reshape(grandata.tb, [numel(grandata.lat) size(grandata.tb, 3)]);
            logtext(atmlab('OUT'), 'Retrieving values\n');
            cf100 = self.nets.classification100(mytb(:, 3:5).');
            fiwp = 10.^self.nets.retrieval(mytb(:, 3:5).');
            ciwp = cf100 .* fiwp;
            logtext(atmlab('OUT'), 'Post-processing\n');
            M = zeros(numel(grandata.lat), max(structfun(@(x)max(x), self.cols)));
            M(:, self.cols.mhs_bt_345) = mytb(:, 3:5);
            M(:, self.cols.lat) = grandata.lat(:);
            M(:, self.cols.lon) = grandata.lon(:);
            M(:, self.cols.time) = grandata.time(:);
            M(:, self.cols.cf100) = cf100;
            M(:, self.cols.fiwp) = fiwp;
            M(:, self.cols.ciwp) = ciwp;
            M(:, self.cols.lza) = grandata.lza(:);
            M(:, self.cols.pos) = grandata.pos(:);
            M(:, self.cols.line) = grandata.line(:);
            storelims.lat = self.nets.retrieval.userdata.retrieval_limits.LAT1;
            storelims.pos = self.nets.retrieval.userdata.retrieval_limits.POS1;
            storelims.mhs_bt_345 = self.nets.retrieval.userdata.retrieval_limits.B_BT;
            M = M(collocation_restrain(M, limstruct2limmat(storelims, self.cols)), :);
            M = sortrows(M, [self.cols.time, self.cols.pos]);
            info.title = 'MW-only IWP from ANN trained with CPR collocs';
            info.version = sprintf('%03.1f', self.version);
            info.history = self.changelog;
            info.source = 'Retrieved from collocated CPR/MHS MW-only-trained ANN';
            info.nnet = self.fromfile;
            info.stored_lims = struct2string_compact(storelims);
            % FIXME: more additional info
            logtext(atmlab('OUT'), 'Storing\n');
            self.store(dt, spec, M, info);
        end
        
        function setcols(self)
            self.cols.lat = 1;
            self.cols.lon = 2;
            self.cols.time = 3;
            self.cols.cf100 = 4;
            self.cols.fiwp = 5;
            self.cols.ciwp = 6;
            self.cols.lza = 7;
            self.cols.mhs_bt_345 = 7:9;
            self.cols.pos = 10;
            self.cols.line = 11;
        end
        
        function setmembers(self)
            self.members.lat.type = 'float';
            self.members.lat.atts.long_name = 'Latitude';
            self.members.lat.atts.valid_range = [-90 90];
            self.members.lat.atts.units = 'degrees_north';
            
            self.members.lon.type = 'float';
            self.members.lon.atts.long_name = 'Longitude';
            self.members.lon.atts.units = 'degrees_east';
            self.members.lon.atts.valid_range = [-180 180];
            
            self.members.time.type = 'int';
            self.members.time.atts.long_name = 'Measurement time';
            self.members.time.atts.units = 'Seconds since 1970-01-01 00:00:00';
            
            self.members.cf1.type = 'float';
            
            self.members.cf10.type = 'float';
            
            self.members.cf100.type = 'float';
            self.members.cf100.atts.long_name = 'Cloud fraction >= 100 g/m^2';
            self.members.cf100.atts.valid_range = [0 1];
            self.members.cf100.atts.description = ...
                ['Estimate of fraction of footprint with cloud ' ...
                 '> 100 g/m^2. Retrieved with ANN trained against ' ...
                 'number of CPR > 100 g/m^2 within AMSUB/MHS ' ...
                 'footprint.'];
             
            self.members.fiwp.type = 'float';
            self.members.fiwp.atts.long_name = 'Full uncorrected Ice Water Path';
            self.members.fiwp.atts.description = ...
                ['Uncorrected Ice Water Path. Does not take into' ...
                 'account whether a cloud is present or not.'];
            self.members.fiwp.atts.units = 'g/m^2';
            
            self.members.ciwp.type = 'float';
            self.members.ciwp.atts.units = 'g/m^2';
            self.members.ciwp.atts.long_name = 'CF-corrected IWP';
            self.members.ciwp.atts.description = ...
                ['CF-Corrected Ice Water Path. This is the product ' ...
                 'of fiwp and cf100. This is a more conservative ' ...
                 'estimate of IWP than fiwp, guessing closer to 0 ' ...
                 'if presence of a cloud is not sure.'];
             
            self.members.lza.type = 'float';
            self.members.lza.atts.long_name = 'Local zenith angle';
            self.members.lza.atts.description = ...
                ['Local zenith angle from AMSU-B/MHS granule. See ' ...
                 'KLM User Guide for details.'];
            self.members.lza.atts.units = 'degrees';
            
            self.members.mhs_bt_345.type = 'float';
            self.members.mhs_bt_345.dims = {'CHANNELS', 3};
            self.members.mhs_bt_345.atts.long_name = 'MHS brightness temperatures for the used channel 3, 4 and 5';
            self.members.mhs_bt_345.atts.units = 'Kelvin';
            
            self.members.pos.type = 'byte';
            self.members.pos.atts.long_name = 'AMSU-B/MHS scanline position';
            
            self.members.line.type = 'int';
            self.members.line.atts.long_name = 'AMSU-B/MHS scanline number';
        end
        
    end
    
    methods (Access = private, Static)
        function needsbox()
            v = ver('nnet');
            if isempty(v)
                ST = dbstack;
                error(['atmlab:' mfilename ':needsNNet'], ...
                    ['Method ' ST(2).name ' needs the Neural Network toolbox']);
            end
        end
    end
    
end
