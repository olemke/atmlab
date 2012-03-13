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
        reader = @(varargin)[];
        granule_duration;
        satname; % for single-satellite datasets
        dataset; % e.g. MYD06_L2 for modis
        firstline_filename = 'firstline_$NAME_$SPEC';

        % defaults cannot be set in any subclass, because re-defining a
        % property is not allowed except under special circumstances that
        % cannot be met here. Therefore, defaults should be encompassed in
        % a property, a structure, 'defaults', that is /not/ defined here,
        % but only by the class at the end of the hierarchy
    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        collocated_datasets = [];
    end
    
    methods
        
        %% constructor
        
        function self = SatDataset(varargin)
            % Creates SatDataset object
            %
            % properties can be set upon constructing as when calling
            % 'struct'
            
            % this may be defined in subclasses
            if isprop(self, 'defaults')
                def_fields = fieldnames(self.defaults); %#ok<*MCNPN>
                for i = 1:length(def_fields)
                    fldnm = def_fields{i};
                    self.(fldnm) = self.defaults.(fldnm);
                end
            end

            for i = 1:2:nargin
                self.(varargin{i}) = varargin{i+1};
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
            
            assert(any(self.basedir), errid, 'No basedir initialised for %s', char(self.name));
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
            %   tol         number  Optional: tolerance in seconds. Due to
            %                       rounding errors, a date like 2009-12-06
            %                       20:53:00 passed to date2unixsecs and
            %                       back to unixsecs2date becomes
            %                       2009-12-06 20:52:59.99999, which is
            %                       hard to round in a straightforward way
            %                       (don't want ...52:60). By default, a
            %                       tolerance of 0.01 seconds is applied.
            %
            % OUT
            %
            %   datafile    string     Path to the looked-for datafile.
            
            errid = 'atmlab:find_granule_by_datetime';
            [spec, tol] = optargs(varargin, {'', 0.01});
            
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
                if tol>0 % use tolerance
                    g = mat2cell(granules, size(granules, 1), [1 1 1 1 1]);
                    grans_unisecs = date2unixsecs(g{:});
                    X = num2cell(datevec);
                    dv_unisecs = date2unixsecs(X{:});
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
        
        function [allgrans, allpaths] = find_granules_for_period(self, date1, date2, spec)
            
            % find_granules_for_period List all granules for sat/dataset for period
            %
            % For the period between date1 and date2, list all granules (as vectors
            % indicating the starting date/time) available.
            %
            % FORMAT
            %
            %   [allgrans, allpaths] = find_granules_for_period(date1, date2, spec)
            %
            % IN
            %
            %   date1   datevec     starting date
            %   date2   datevec     ending date
            %   spec    various
            %
            % OUT
            %
            %   allgrans matrix     all granules in daterange
            %   allpaths cellstr    all paths to those granules
            
            dates = daterange(date1, date2);
            ndates = size(dates, 1);
            
            allgrans = nan*zeros(ndates*15, 5);
            allpaths = cell(size(allgrans));
            
            n = 0;
            for i = 1:ndates
                date = dates(i, :);
                [grans, paths] = self.find_granules_by_date(date, spec, false);
                ngrans = size(grans, 1);
                allgrans(n+1:n+ngrans, :) = grans;
                allpaths(n+1:n+ngrans) = paths;
                n = n + ngrans;
            end
            
            to_remove = isnan(allgrans(:, 1));
            allgrans(to_remove, :) = [];
            allpaths(to_remove) = [];
            [allgrans, I] = sortrows(allgrans);
            allpaths = allpaths(I);

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
            % TODO: implement caching, e.g. last N read granules are
            % stored in memory, in some global array or persistent thingy
            % or so?
            %
            % $Id$
             
            % optional arguments
            [spec, extra, remdouble, force] = optargs(varargin, {'', {}, true, false});
            
            % find datafile and function to read it
            datafile = self.find_granule_by_datetime(date, spec);
            
            % read datafile
            %logtext(colloc_config('stdout'), '%s(''%s'')\n', ...
            %    func2str(reader), datafile);
            logtext(atmlab('OUT'), 'Reading %s\n', datafile);
            try
                data = self.reader(datafile, extra);
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
                firstline = self.granule_first_line(date, spec);
                if firstline > 0
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
            %   force       logical     (optional) If nothing found, don't
            %                           throw an error, but return empty.
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
            
            [spec, reload, force] = optargs(varargin, {'', false, false});
            
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
            if isempty(first) && ~force
                error(['atmlab:' mfilename ':missing_firstline'], ['no data found for %s @ %d. ', ...
                    'You may want to run self.find_granule_first_line(...) ', ...
                    'for a sufficiently long period.'], ...
                    self.name, unisecs);
            end
            
        end
        
        function find_granule_first_line(self, startdate, enddate, varargin)
            % find_granule_first_line Create hashtable with scanline overlaps
            %
            % Creates a hashtable (such as used by granule_first_line) that maps for
            % each granule the first scanline not occuring in the previous
            % scanline.
            %
            % The resulting hashtable is written to a file according to
            % datasets_config('firstline_data'), which is also where
            % granule_first_line is looking for it.
            %
            % FORMAT
            %
            %   find_scanline_first_line(startdate, enddate, spec)
            %
            % IN
            %
            %   startdate   datevec     start here
            %   enddate     datevec     end here
            %   spec        various     specification
            %
            % OUT
            %
            %   none, but writes a file
            
            spec = optargs(varargin, {''});            
            
            if isempty(spec)
                sat = self.satname;
            else
                sat = spec;    
            end

            scanfile = datasets_config('firstline_data');
            scanfile = strrep(scanfile, '$SAT', sat);
            scanfile = strrep(scanfile, '$SENSOR', self.name);
            
            logtext(atmlab('OUT'), 'Locating granules\n');
            allgrans = self.find_granules_for_period(startdate, enddate, spec);
            ngrans = size(allgrans, 1);
            logtext(atmlab('OUT'), 'Found %d granules\n', ngrans);
            
            if exist(scanfile, 'file')
                tm = load(scanfile);
                ht = tm.ht;
            else
                ht = java.util.Hashtable;
            end
            
            uni_first = date2unixsecs(allgrans(1, 1), allgrans(1, 2), allgrans(1, 3), allgrans(1, 4), allgrans(1, 5));
            if ~ht.containsKey(uint32(uni_first))
                logtext(atmlab('OUT'), 'Setting very first to flag\n');
                ht.put(uint32(uni_first), -5);
            end
            next = 0;
            
            for i = 1:ngrans-1
                logtext(atmlab('OUT'), 'granule %d/%d: %d-%02d-%02d %02d:%02d\n', i, ngrans-1, ...
                    allgrans(i, 1), allgrans(i, 2), allgrans(i, 3), allgrans(i, 4), allgrans(i, 5));
                uni = date2unixsecs(allgrans(i+1, 1), allgrans(i+1, 2), allgrans(i+1, 3), allgrans(i+1, 4), allgrans(i+1, 5));
                if ht.containsKey(uint32(uni)) && ht.get(uint32(uni)) ~= -5
                    logtext(atmlab('OUT'), 'Already exists (%d:%d)\n', uint32(uni), ht.get(uint32(uni)));
                    continue
                end
                try
                    couldreadcur = false;
                    if isequal(next, 0)
                        cur = self.read_granule(allgrans(i, :), spec, {}, false, false);
                    else
                        cur = next;
                    end
                    couldreadcur = true;
                    couldreadnext = false;
                    next = self.read_granule(allgrans(i+1, :), spec, {}, false, false);
                    couldreadnext = true;
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', 'atmlab:atovs_get_l1c:zamsu2l1c',...
                                'atmlab:invalid_data','atmlab:find_granule_by_datetime',...
                                'MATLAB:imagesci:hdfinfo:invalidFile'}
                            logtext(atmlab('ERR'), 'Problem: %s\n', ME.message);
                        otherwise
                            ME.rethrow();
                    end
                end
                %uni = date2unixsecs(allgrans(i+1, 1), allgrans(i+1, 2), allgrans(i+1, 3), allgrans(i+1, 4), allgrans(i+1, 5));
                if couldreadcur && couldreadnext
                    t_cur = cur.epoch + cur.time;
                    t_next = next.epoch + next.time;
                    %[t_cur, t_next] = unify_time_axis(cur.time, next.time);
                    firstline = find(t_next > t_cur(end), 1, 'first');
                    if ~isempty(firstline)
                        logtext(atmlab('OUT'), 'First line: %d\n', firstline);
                        ht.put(uint32(uni), firstline);
                    else
                        logtext(atmlab('OUT'), 'No first line, setting to -2\n');
                        ht.put(uint32(uni), -2);
                    end
                elseif couldreadcur
                    logtext(atmlab('OUT'), 'Could not read next, setting next to -3\n');
                    ht.put(uint32(uni), -3);
                else
                    logtext(atmlab('OUT'), 'Could not read current. setting to -4\n');
                    ht.put(uint32(uni), -4);
                end
            end
            
            save(scanfile, 'ht');           
            
        end
        
        %% methods for internal use (not private, but from other classes)
       
        function add_collocated_dataset(ds, cd)
            % INTERNAL USE. Adds a collocated dataset.
            %
            % This is called by the CollocatedDataset constructor.
            ds.collocated_datasets = [ds.collocated_datasets cd];
        end
        
        function set.name(self, value)
            if ~isempty(self.name)
                % deregister old name
                datasets('delete', self);
            end
            self.name = value;
            datasets(self);
        end
    end
end
