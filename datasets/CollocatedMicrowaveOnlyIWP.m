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
    
    % $Id$
    
    properties
        nets = struct();
        nchannels = 3;
        data;
        localcols;
    end
    
    properties (GetAccess = private, SetAccess = private)
       selection; 
       maxsize = 10000; % max number of entries for neural net
    end
    
    properties (Constant)
        version = 0.2;
        changelog = [...
            'version 0.0: initial version, negative IWP, linear all\n' ...
            'version 0.1: cf [0, 1], log-IWP retrieved, more descriptive atts\n', ...
            'version 0.2: more descriptive atts, cf -> cf100, improved training sel\n'];
    end
    
    methods
        function self = CollocatedMicrowaveOnlyIWP(varargin)
            self = self@HomemadeDataset(varargin{:});
            self.setcols();
            self.setmembers();
            self.reader = @(varargin) (common_read_netcdf_dataset(self, varargin{:}));
            %self.basedir = sprintf('%s/v%03.1f', self.basedir, self.version);
        end
        
        function getdata(self, start_date, end_date)
            d = datasets;
            [M, c] = d.CollocatedDataset_mhs_cpr.read(...
                start_date, end_date, 'noaa18', ...
                {'LAT1', 'LON1', 'POS1', 'TIME1', 'B_BT', 'B_LZA', ...
                 'NO_ROIWP', 'MEAN_ROIWP', 'FRAC1_ROIWP', 'FRAC10_ROIWP', 'FRAC100_ROIWP', 'FRAC1000_ROIWP'}, ...
                 struct('LAT1', [-30 30], ...
                        'POS1', [30 60], ...
                        'B_BT', [0 400]));
             self.data = M;
             self.localcols = c;
             if size(M, 1) > self.maxsize
                 self.selection = unique(round(linspace(1, size(M, 1), 10000)));
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
%            subdat = self.data(self.selection, :);
            dat = self.data;
            BT = dat(:, self.localcols.B_BT(3:5));
            IWP = dat(:, self.localcols.MEAN_ROIWP);
            
            subsel = IWP>0 & dat(:, self.localcols.FRAC1_ROIWP)==1;
            if sum(subsel) > 10000
                subsel = find(subsel);
                subsel = subsel(unique(round(linspace(1, size(subsel, 1), self.maxsize))));
            end
            net = fitnet(6);
            net.trainParam.showWindow = false;
            net = train(net, BT(subsel, :).', log10(IWP(subsel).'));
            self.nets.retrieval = net;
        end
        
        function make_classification_net(self)
            % prepare neural net with BT and cloudfrac
            
            self.needsbox();
            BT = self.data(self.selection, self.localcols.B_BT(3:5)).';
            cloudfrac100 = self.data(self.selection, self.localcols.FRAC100_ROIWP).';
            net = patternnet(6);
            net.trainParam.showWindow = false;
            net = train(net, BT, cloudfrac100);
            self.nets.classification100 = net;
        end
        
        function storenets(self, fl)
            self.needsbox();
            nt = self.nets; %#ok<NASGU>
            save(fullfile(self.basedir, fl), 'nt');
        end
        
        function loadnets(self, fl)
            self.needsbox();
            self.nets = loadvar(fullfile(self.basedir, fl), 'nt');
        end
        
        function retrieve_and_store_gran(self, dt, spec)
            self.needsbox();
            d = datasets;
            ds = d.(amsub_or_mhs(spec));
            grandata = ds.read_granule(dt, spec);
            %graninfo = ds.find_info_from_granule(ds.find_granule_by_datetime(dt, spec));
            mytb = reshape(grandata.tb(:), [numel(grandata.lat) 5]);
            cf100 = self.nets.classification100(mytb(:, 3:5).');
            fiwp = 10.^self.nets.retrieval(mytb(3:5).');
            ciwp = cf100 .* fiwp;
            time = repmat(grandata.time, [1 90]);
            time = time(:);
            M = zeros(numel(grandata.lat), 6);
            %M(:, self.cols.tb) = mytb(3:5);
            M(:, self.cols.lat) = grandata.lat(:);
            M(:, self.cols.lon) = grandata.lon(:);
            M(:, self.cols.time) = time;
            M(:, self.cols.cf100) = cf100;
            M(:, self.cols.fiwp) = fiwp;
            M(:, self.cols.ciwp) = ciwp;
            M = sortrows(M, self.cols.time);
            info.title = 'MW-only IWP from ANN trained with CPR collocs';
            info.version = sprintf('%03.1f', self.version);
            info.history = self.changelog;
            info.source = 'Retrieved from collocated CPR/MHS MW-only-trained ANN';
            % FIXME: more additional info
            self.store(dt, spec, M, info);
        end
        
        function setcols(self)
            self.cols.lat = 1;
            self.cols.lon = 2;
            self.cols.time = 3;
            self.cols.cf100 = 4;
            self.cols.fiwp = 5;
            self.cols.ciwp = 6;
            %self.cols.tb = 7:9;
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
            self.members.cf100.type = 'float';
            self.members.cf100.atts.long_name = 'Cloud fraction > 100 g/m^2';
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
