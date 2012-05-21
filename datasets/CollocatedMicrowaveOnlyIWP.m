classdef CollocatedMicrowaveOnlyIWP < HomemadeDataset
    % Class holding functionality for Gerrits most primivite IWP dataset
    %
    % Retrieving depends on the functionality depends on the Neural Network Toolbox,
    % tested with Versio 7.0.3 (R2012a).
    %
    % Reading etc. works fine without this toolbox.
    
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
        version = 0.1;
        changelog = [...
            'version 0.0: initial version, negative IWP, linear all\n' ...
            'version 0.1: cf [0, 1], log-IWP retrieved, more descriptive atts\n'];
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
                        
            BT = self.data(self.selection, self.localcols.B_BT(3:5)).';
            IWP = self.data(self.selection, self.localcols.MEAN_ROIWP).';
            
            positive = IWP>0;
            net = fitnet(6);
            net.trainParam.showWindow = false;
            net = train(net, BT(:, positive), log10(IWP(positive)));
            self.nets.retrieval = net;
        end
        
        function make_classification_net(self)
            % prepare neural net with BT and cloudfrac
            
            BT = self.data(self.selection, self.localcols.B_BT(3:5)).';
            cloudfrac = self.data(self.selection, self.localcols.FRAC100_ROIWP).';
            net = patternnet(6);
            net.trainParam.showWindow = false;
            net = train(net, BT, cloudfrac);
            self.nets.classification = net;
        end
        
        function plot_test_classification_net(self)
            x = self.data(:, self.localcols.FRAC100_ROIWP);
            y = self.nets.classification(self.data(:, self.localcols.B_BT(3:5)).');
            bins = linspace(0, 1, 10);
            satboxplot(x, y, bins, 'kx');
        end
        
        function plot_test_retrieval_net(self)
            xbt = self.data(:, self.localcols.B_BT(3:5));
            x = self.data(:, self.localcols.MEAN_ROIWP);
            yc = self.nets.classification(xbt.');
            yf = 10.^self.nets.retrieval(xbt.');
            y = yc.*yf;
            plot(x, y, '.');
            xlabel('CPR IWP [g/m^2]');
            ylabel('Gerrit IWP [g/m^2]');
            set(gca, 'XScale', 'log');
            set(gca, 'YScale', 'log');
        end
        
        function storenets(self, fl)
            nt = self.nets; %#ok<NASGU>
            save(fullfile(self.basedir, fl), 'nt');
        end
        
        function loadnets(self, fl)
            self.nets = loadvar(fullfile(self.basedir, fl), 'nt');
        end
        
        function retrieve_and_store_gran(self, dt, spec)
            d = datasets;
            ds = d.(amsub_or_mhs(spec));
            grandata = ds.read_granule(dt, spec);
            %graninfo = ds.find_info_from_granule(ds.find_granule_by_datetime(dt, spec));
            mytb = reshape(grandata.tb(:), [numel(grandata.lat) 5]);
            cf = self.nets.classification(mytb(:, 3:5).');
            fiwp = 10.^self.nets.retrieval(mytb(3:5).');
            ciwp = cf .* fiwp;
            time = repmat(grandata.time, [1 90]);
            time = time(:);
            M = zeros(numel(grandata.lat), 6);
            %M(:, self.cols.tb) = mytb(3:5);
            M(:, self.cols.lat) = grandata.lat(:);
            M(:, self.cols.lon) = grandata.lon(:);
            M(:, self.cols.time) = time;
            M(:, self.cols.cf) = cf;
            M(:, self.cols.fiwp) = fiwp;
            M(:, self.cols.ciwp) = ciwp;
            M = sortrows(M, self.cols.time);
            info.version = sprintf('%03.1f', self.version);
            info.history = self.changelog;
            % FIXME: resort
            % FIXME: more additional info
            self.store(dt, spec, M, info);
        end
        
        function setcols(self)
            self.cols.lat = 1;
            self.cols.lon = 2;
            self.cols.time = 3;
            self.cols.cf = 4;
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
            self.members.cf.type = 'float';
            self.members.fiwp.type = 'float';
            self.members.fiwp.atts.long_name = 'Full uncorrected Ice Water Path';
            self.members.fiwp.atts.description = 'Uncorrected Ice Water Path, retrieved even when there may be no cloud';
            self.members.fiwp.atts.units = 'g/m^2';
            self.members.ciwp.type = 'float';
            self.members.ciwp.atts.units = 'g/m^2';
            self.members.ciwp.atts.long_name = 'CF-corrected IWP';
            self.members.ciwp.atts.description = 'Corrected Ice Water Path, including guess ''is there a cloud?''';
        end
    end
    
end
