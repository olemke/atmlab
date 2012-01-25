classdef SatDataset < handle % subclass from handle to pass-by-reference
    % Class to represent a dataset
    %
    % Work in progress!
    %
    % $Id$
    
    % read/write props
    properties
        name;
        basedir;
        subdir;
        re;
        filename;
        reader = @(p)[];
        granule_duration;
        satname; % for single-satellite datasets
    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        dependencies; % what does generation depend on?
        collocated_datasets = [];
        version; % FIXME should be inaccessible before read_granule! 
        data; % FIXME the same!
    end
    
    methods
        
        %% constructor
        
        function ds = SatDataset(varargin)
            % Creates SatDataset object
            %
            % properties can be set upon constructing as when calling
            % 'struct'
            for i = 1:2:nargin
                ds.(varargin{i}) = varargin{i+1};
            end
        end
        
        %% things that can be done with datasets
        
        function fulldir = find_datadir_by_date(self, date, varargin)
            % find_datadir_by_date Find directory containing granules
            %
            % For the given datevec and specification, return a string with
            % the path to the directory that contains the granules for this particular
            % datevec.
            %
            % FORMAT
            %
            %   fulldir = ds.find_datadir_by_date(datevec, spec)
            %
            % IN
            %
            %   datevec     vector      [year month day] etc.
            %   spec        any         name of sat or cellstr {sat1 sat2}
            %
            % OUT
            %
            %   fulldir     string      path to directory
            
            % verify basedir is defined and exists
            
            spec = optargs(varargin, {''});
            errid = ['atmlab:' mfilename]; %find_datadir_by_date';
            
            assert(any(self.basedir), errid, 'No basedir initialised for %s', dataset);
            assert(exist(self.basedir, 'dir')~=0, errid, ...
                ['Configured data directory for %s is %s, ' ...
                'but this does not exist or is not a directory. ' ...
                'Please define basedir for %s correctly ' ...
                'or create the directory.'], ...
                self.name, self.basedir, self.name);
            
            fulldir = fullfile(self.basedir, self.subdir);
            
            fulldir = strrep_variables(fulldir, spec, date);
   
        end
        
        function [M, paths] = find_granules_by_date(self, date, varargin)
            % find_granules_by_date Find all granule start times for date/sat/dataset
            %
            % FIXME DOC
            %
            % This function finds all granule start times for granules with any coverage
            % for the the indicated for the indicated satellite/dataset pair. This
            % includes the last granule of the date before, unless this is explicitly
            % prohibited. Note that the last granule of the date before may or may not
            % actually contain information for the day requested. The
            % function assumes at most one granule for the previous date
            % contains information for the current date.
            %
            % FORMAT
            %
            %   [M, paths] = find_granules_by_date(date, spec, with_yesterday)
            %
            % OUT
            %
            %   M     N x m matrix     where each row corresponds to one granule and is
            %                          a datevec.
            %   paths cell strings     Cell array of strings, corresponding full paths
            %
            % IN
            %
            %   date
            %   spec
            %   with_yesterday (optional)
            %
            % $Id$
            
            % errid = 'atmlab:find_granules_by_date';
            
            [spec, with_yesterday] = optargs(varargin, {'', true});
            
            datadir = self.find_datadir_by_date(date, spec);
            yearstr = num2str(date(1), '%04d'); % for comparing easily with 2digit years
            
            matchy = self.re;
            if isequalwithequalnans(matchy, nan) || isempty(matchy)
                matchy = self.filename; % exact match only
            end
            
            matchy = strrep_variables(matchy, spec, date);
            
            files = dir(datadir);
            nfiles = length(files);
            M = zeros(nfiles, 5);
            for i = 1:nfiles
                fname = files(i).name;
                nam = regexp(fname, matchy, 'names');
                if ~isempty(nam)
                    % if present, year/month/day should be the same
                    if (isfield(nam, 'year02') && ~isempty(nam.year02) && ~strcmp(nam.year02, yearstr(3:4))) || ...
                            (isfield(nam, 'year04') && ~isempty(nam.year04) && str2double(nam.year04)~=date(1)) || ...
                            (isfield(nam, 'year') && ~isempty(nam.year) && str2double(nam.year)~=date(1)) || ...
                            (isfield(nam, 'month') && ~isempty(nam.month) && str2double(nam.month)~=date(2)) || ...
                            (isfield(nam, 'day') && ~isempty(nam.day) && str2double(nam.day)~=date(3)) || ...
                            (isfield(nam, 'doy') && ~isempty(nam.doy) && str2double(nam.doy)~=dayofyear(date(1), date(2), date(3)));
                        continue;
                    end
                    
                    M(i, 1:3) = date(1:3);
                    if isfield(nam, 'hour')
                        M(i, 4) = str2double(nam.hour);
                    end
                    if isfield(nam, 'minute')
                        M(i, 5) = str2double(nam.minute);
                    end
                end
            end
            % all paths
            paths = cellfun(@(f) fullfile(datadir, f), {files.name}, 'UniformOutput', false);
            % remove lines with zeroes (those are not granules)
            nogran = M(:, 1)==0;
            M(nogran, :) = [];
            paths(nogran) = [];
            % sort
            [M, I] = sortrows(M);
            paths = paths(I);
            % add yesterday
            if with_yesterday
                yesterday = datevec(datenum(date)-1);
                [M_yesterday, paths_yesterday] = self.find_granules_by_date(yesterday, spec, false);
                if ~isempty(M_yesterday) % maybe today is genesis/big bang/epoch/birth/1970-01-01
                    M = [M_yesterday(end, :); M];
                    paths = [paths_yesterday(end) paths];
                end
            end
        end
        
        function datafile = find_granule_by_datetime(self, datevec, varargin)
        
            % find_granule_by_datetime Return full path of datafile by date/time
            %
            % Returns the full path of the datafile corresponding to the input
            % arguments. There are two modes:
            %
            %   - If dataset.filename is defined, the path is
            %     calculated directly from datasets_config settings and the arguments
            %     passed on. The file may or may not actually exist, so in this case,
            %     you can use it to calculate the path when planning to create it.
            %
            %   - If this is not defined, then dataset.re has to
            %     be defined. It will search the filesystem for a file matching the
            %     regular expression and the indicated datevec/spec for this dataset.
            %     In this case, one can apply a tolerance in seconds.
            %
            % FORMAT
            %
            %   datafile = dataset.find_granule_by_datetime(date, [spec[, tol]])
            %
            % IN
            %
            %   datevec     vector  Date/time to find datafile for
            %   spec        string/ Name of satellite. For datasets belonging to one
            %               cellstr satellite, a simple string. For datasets belonging
            %                       to two satellites (such as collocations), a cell
            %                       array of two strings.
            %   tol         number  Optional: tolerance in seconds. Sometimes, MSPPS
            %                       doesn't start the same minute as AMSU :(.
            %
            % OUT
            %
            %   datafile    string     Path to the looked-for datafile.
            
            errid = ['atmlab:' mfilename];
            [spec, tol] = optargs(varargin, {'', 0});
            
            % implementation:
            % 1. find the directory containing the files from basedir/subdir
            % 2. if possible, calculate the filename directly
            % 3. otherwise, list all files and match with regexp+tolerance
            
            fulldir = self.find_datadir_by_date(datevec, spec);
            
            if ~isequalwithequalnans(self.filename, nan) && ~isempty(self.filename) % calculate directly
                fn = strrep_variables(self.filename, spec, datevec);
                datafile = fullfile(fulldir, fn);
            else % will search through all granules with find_granules_by_date
                [granules, paths] = self.find_granules_by_date(datevec, spec, false);
                if exist('tol', 'var') && tol>0 % use tolerance
                    g = mat2cell(granules, size(granules, 1), [1 1 1 1 1]);
                    grans_unisecs = date2unixsecs(g{:});
                    dv_unisecs = date2unixsecs(datevec(1), datevec(2), datevec(3), datevec(4), datevec(5));
                    found = abs(grans_unisecs - dv_unisecs) < tol;
                else
                    found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);
                end
                
                nfound = sum(found);
                if nfound==0
                    error(errid, 'No datafile found for %s %s [%s]', self.name, spec, num2str(datevec));
                elseif nfound > 1
                    error(errid, 'Multiple datefiles found for %s %s', self.name, spec);
                else
                    datafile = paths{found};
                end
                
            end
            
        end        
        
        function data = read_granule(self, date, varargin)
            % read_granule Read any granule
            %
            % High-level function to read a particular granule for a
            % satellite/sensor-pair, if one doesn't know what function is suitable to
            % use to read it. It also gets rid of ballast.
            %
            % Uses member 'reader' to find out what function to use to
            % read this particular data. Uses self.granule_first_line to find out the first
            % scanline to use (e.g. the rest are doubles).
            %
            % FORMAT
            %
            %   M = read_granule(date[, spec[, extra[, remdouble[, force]]]])
            %
            % IN
            %
            %   datevec     vector      Date-vector indicating the starting time.
            %   spec        various     (optional) E.g. satellite (noaa18, cloudsat, etc.) 
            %   extra       cellstr     (optional) extra args to reader
            %   remdouble   logical     (optional) Remove doubles or not? Default true.
            %   force       logical     (optional) rather than throwing an error,
            %                           return [] in case of error. Default false.
            %
            % OUT
            %
            %   data        struct  Contains at least lat, lon, time and one or more
            %                       data fields. Exact results depend on the particular
            %                       satellite/sensor-pair.
            %
            % $Id$
             
            % optional arguments
            [spec, extra, remdouble, force] = optargs(varargin, {'', {}, true, false});
            
            % find datafile and function to read it
            datafile = self.find_granule_by_datetime(date, spec);
            
            % read datafile
            %logtext(colloc_config('stdout'), '%s(''%s'')\n', ...
            %    func2str(reader), datafile);
            try
                if isempty(extra)
                    data = self.reader(datafile);
                else
                    data = self.reader(datafile, extra);
                end
            catch ME
                if force
                    switch ME.identifier
                        case 'atmlab:invalid_data'
                            logtext(atmlab('ERR'), ...
                                'Unable to read: %s\n', ME.message);
                            return
                        otherwise
                            ME.rethrow();
                    end
                else
                    ME.rethrow();
                end
            end
            %logtext(colloc_config('stdout'), 'read %s\n', datafile);
            nlines = size(data.time, 1);
            
            if remdouble
                % read ballast
                firstline = self.granule_first_line(datevec, spec);
                % get rid of ballast in all fields
                for f = fieldnames(data)'
                    fn = f{1};
                    if isnumeric(data.(fn)) && size(data.(fn), 1) == nlines
                        % magic in next lines explained at
                        % http://www.mathworks.de/matlabcentral/newsreader/view_thread/290890
                        sz = size(data.(fn));
                        data.(fn) = reshape(data.(fn)(firstline:nlines, :), [nlines-firstline+1, sz(2:end)]);
                    end
                end
            end
        end
                
        function first = granule_first_line(self, d, varargin)
            % granule_first_line Returns first scanline not present in previous granule
            %
            % For a certain granule, return the number of the first scanline that
            % is not in the previous scanline. This m-file uses a previously created
            % database (a hashtable). This hash-table is cached between subsequent
            % calls of the function.
            %
            % There should exist an entry for each satellite/sensor granule. If it's
            % not found, an error is raised, and there is probably a bug somewhere. If
            % the satellite/sensor granule exists, but there is no (unique) previous
            % granule, line -2 is returned.
            %
            % FORMAT
            %
            %   first = granule_first_line(datevec[, spec[, reload]])
            %
            % IN
            %
            %   d           various     Starting date/time for granule,
            %                           datevec or unixsecs
            %   spec        various     (optional) Might be indicating satellite(s)
            %   reload      logical     (optional) Reload scanline data (i.e. not
            %                           cached). Defaults to false.
            %
            % OUT
            %
            %   first       number      First scanline not in previous granule.
            %                           Special values: -1 (no data found), -2 (no
            %                           previous granule found)
            
            persistent S;
                        
            if isempty(S)
                S = struct;
            end
            
            [spec, reload] = optargs(varargin, {'', false});
            
            assert(ischar(spec), ['atmlab:' mfilename], ...
                'function works only for single-satellite datasets');
            if isempty(spec)
                sat = self.satname;
            else
                sat = spec;
            end
            
            if isfield(S, sat) && isfield(S.(sat), self.name) && ~reload
                ht = S.(sat).(self.name);
            else
                scanfile = datasets_config('firstline_data');
                scanfile = strrep(scanfile, '$SAT', sat);
                scanfile = strrep(scanfile, '$SENSOR', self.name);
                
                t = load(scanfile);
                ht = t.ht;
                S.(sat).(self.name) = ht;
            end
            
            if isscalar(d)
                unisecs = uint32(d);
            else
                dv = num2cell(d);
                unisecs = uint32(date2unixsecs(dv{:}));
            end
            
            first = ht.get(unisecs);
            if isempty(first)
                error(['atmlab:' mfilename], 'no data found for %s @ %d', ...
                    self.name, unisecs);
            end

        end
        
        %% methods for internal use (not private, but from other classes)
       
        function add_collocated_dataset(ds, cd)
            % INTERNAL USE. Adds a collocated dataset.
            %
            % This is called by the CollocatedDataset constructor.
            ds.collocated_datasets = [ds.collocated_datasets cd];
        end
    end
end
