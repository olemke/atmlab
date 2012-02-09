classdef CollocatedDataset < SatDataset & HomemadeDataset
    % Defines a collocated dataset, between two (other) datasets
    %
    % Work in progress!
    %
    % $Id$
    properties
        primary;
        secondary;
    end
    
    % read-only props (may be alterable with methods)
    properties (SetAccess = protected)
        % associated datasets, e.g. additional data, meandata, etc.
        associated = {};
    end
    
    properties (Constant)
        
        % http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/NetCDF_002d3-Variable-Types.html#NetCDF_002d3-Variable-Types
        members = struct(...
            'START1', struct(...
                'type', 'int', ... % won't work after 2038-01-19 03:14:07 UTC
                'atts', struct(...
                    'long_name', 'primary granule start time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LINE1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary scanline number')), ...
            'POS1', struct(...
                'type', 'byte', ...
                'atts', struct(...
                    'long_name', 'primary scanline position')), ...
            'TIME1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary measurement time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LAT1', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'primary latitude', ...
                    'units', 'degrees_north', ...
                    'valid_range', [-90 90])), ...
            'LON1', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'primary longitude', ...
                    'units', 'degrees_east', ...
                    'valid_range', [-180 180])), ...
            'START2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary granule start time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LINE2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary scanline number')), ...
            'POS2', struct(...
                'type', 'byte', ...
                'atts', struct(...
                    'long_name', 'secondary scanline position')), ...
            'TIME2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary measurement time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LAT2', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'secondary latitude', ...
                    'units', 'degrees_north', ...
                    'valid_range', [-90 90])), ...
            'LON2', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'secondary longitude', ...
                    'units', 'degrees_east', ...
                    'valid_range', [-180 180])));
        
    end
    
    methods
        function self = CollocatedDataset(prim, sec, varargin)
            self = self@SatDataset(varargin{:}); % call parent constructor
            % check that both are SatDataset
            for x = {prim, sec}
                assert(isa(x{1}, 'SatDataset'), ['atmlab:' mfilename ':TypeError'], ...
                    'Collocations must be between 2 x SatDataset, got %s instead', ...
                    class(x{1}));
                x{1}.add_collocated_dataset(self);
            end
            self.primary = prim;
            self.secondary = sec;
            if isempty(self.name)
                self.name = ['collocations_' prim.name '_' sec.name];
            end
            
            % make 'cols'-structure for internal data specification
             
            fnms = fieldnames(self.members);
            nfields = length(fnms);
            fv = 1:nfields;
            self.cols = cell2struct(num2cell(fv), fnms.', 2);
        end
                
        function secondary_granules = overlap_granule(self, date1, spec2)
            % secondary granules that, judging from filenames, might overlap
            %
            % FIXME DOC
            %
            % date1, spec2
            %
            % Assumes granules contain data for at most one day.
            %
            
            
            %% get duration of a granule of sensor1
            
            duration = self.primary.granule_duration;
            
            %% find starting time in unixsecs
            
            granule_start = date2unixsecs(date1(1), date1(2), date1(3), date1(4), date1(5));
            granule_end = granule_start + duration;
            
            %% find all granules yesterday/today/tomorrow
            
            today_num = datenum(date1(1), date1(2), date1(3));
            yesterday = datevec(today_num - 1);
            tomorrow = datevec(today_num + 1);
            
            threedays = [...
                self.secondary.find_granules_by_date(yesterday, spec2, false); ...
                self.secondary.find_granules_by_date(date1, spec2, false); ...
                self.secondary.find_granules_by_date(tomorrow, spec2, false)];
            threedays = sortrows(threedays);
            granules_unixsecs = date2unixsecs(...
                threedays(:, 1), threedays(:, 2), threedays(:, 3), threedays(:, 4), threedays(:, 5));
            
            % last granule starting after the reference granule
            % those are all 'too late'
            
            b = find(granule_start - colloc_config('interval') > granules_unixsecs, 1, 'last');
            
            % first granule ending before the reference granule
            % those are all 'too early'
            
            e = find(granule_end + colloc_config('interval') < granules_unixsecs, 1, 'first');
            
            % if all match, none are too early or too late
            if isempty(b) && isempty(e)
                okej = (granule_start < granules_unixsecs) & (granule_end > granules_unixsecs);
            elseif ~isempty(b) && ~isempty(e)
                % anything not too early, not too late, is good
                okej = b:e;
            else
                % the non-empty one as index
                X={b,e};
                okej = X{[~isempty(b) ~isempty(e)]};
            end   
            
            secondary_granules = threedays(okej, :);
        end
        
        function [result, additional_results, also] = collocate_granule(self, date1, spec1, spec2, varargin)
            
            % collocate_granule Collocate granules from sat/sensor pairs
            %
            % date1: datevec for 1.
            %
            % spec1: specification for 1 (e.g. satellite).
            %
            % spec2: specification for 2 (e.g. satellite).
            %
            % additionals, cell array of AssociatedDataset-objects (or,
            % naturally, one of its subclasses)
            %
            % oneday
            %
            % TO BE DOCUMENTED
            
            [additionals, oneday] = optargs(varargin, {{}, false});
            additional_results = cell(size(additionals));
            
            % collect all extra fields, for all additional datasets
            extra_args_primary = {};
            extra_args_secondary = {};
            for i = 1:length(additionals)
                addi = additionals{i};
                primfields = addi.primary_arguments();
                secofields = addi.secondary_arguments();
                extra_args_primary = [extra_args_primary primfields]; %#ok<AGROW>
                extra_args_secondary = [extra_args_secondary secofields]; %#ok<AGROW>
            end
            extra_args_primary = unique(extra_args_primary);
            extra_args_secondary = unique(extra_args_secondary);
            
            %% output
            
            fid = atmlab('OUT');
            eid = atmlab('ERR');
            
            %% find date/times for which to search for secondary granules
            
            % overlap check 1: primary filename, secondary filename
            secondary_granules = self.overlap_granule(date1, spec2);
            
            if size(secondary_granules, 1)==0
                error(['atmlab:' mfilename ':noother'], ...
                    'No overlapping granules found for [%s] %s/%s with %s/%s', ...
                    num2str(date1), spec1, self.primary.name, spec2, self.secondary.name);
            end
            
            logtext(fid, 'Found %d other granules to collocate with\n', size(secondary_granules, 1));
            
            %%
            
            result = zeros(0, length(fieldnames(self.cols)));
            
            %% read data for sat1/sensor1
            % Here, I decide to keep the duplicates for now. Simple is better than
            % complex. My collocation output are rows and column indices, and if I already
            % remove duplicates /before/ collocation, the row-indices will be
            % incorrect/ need to be corrected for. This causes more problems than it
            % solves, so I will remove the duplicates in the postprocessing instead.
            try
                data1 = self.primary.read_granule(date1, spec1, extra_args_primary, false, false); % keep duplicates for now
            catch ME
                switch ME.identifier
                    case {'MATLAB:load:couldNotReadFile', 'atmlab:invalid_data'}
                        logtext(eid, 'Collocating failed: %s\n', ME.message);
                        return
                    otherwise
                        ME.rethrow();
                end
            end
            
            also.version{1} = data1.version;
            also.version{2} = '?'; % secondary version not yet available
            
            if isempty(data1.time)
                logtext(fid, 'Primary is empty, nothing to collocate\n');
                %                self.version{2} = 'N/A';
                return
            end
            
            % keep effective range, check time overlap before actually reading the
            % secondary data, because the primary might be sparse. E.g. when judging
            % from the filenames the granules contain overlapping periods, but if the
            % primary in reality only contains data for a certain part of this period
            % (e.g. in the case of collocations), should check the primary data with
            % the secondary filename in order not to read files one knows will not
            % contain overlap anyway.
            
            % self.primary and self.secondary may actually be the same
            % object, do not store any 'temporary' data there.
            data1.time_orig = data1.time; % store because of subsequent unify_time_axis can lead to errors
            data1.eff_range = double(data1.epoch) + ...
                [min(data1.time)-colloc_config('interval'), ...
                max(data1.time)+colloc_config('interval')];
            
            %% loop through all the granules to collocate with
            
            for i = 1:size(secondary_granules, 1)
                datecell = num2cell(secondary_granules(i, 1:5));
                
                logtext(atmlab('OUT'), 'Collocating with ''%s'' @ %04d-%02d-%02d %02d:%02d\n', ...
                    self.secondary.name, datecell{1:5});
                
                % Overlap check 2; primary data with secondary filename
                data2_start = date2unixsecs(datecell{1:5});
                data2_end = data2_start + self.secondary.granule_duration;
                
                if (data2_start > data1.eff_range(2)) || (data2_end < data1.eff_range(1))
                    % no possible time overlap; data1 range already compensated for
                    % colloc_config('interval'); no use even reading granule2
                    logtext(atmlab('OUT'), 'Not reading, no overlap with primary\n');
                    continue
                end
                
                %% read secondary
                
                try
                    data2 = self.secondary.read_granule(secondary_granules(i, :), spec2, extra_args_secondary, false);
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', 'atmlab:invalid_data'}
                            logtext(eid, 'Error in reading datafile %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                                datecell{:}, ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                
                also.version{2} = data2.version;
                data2.time_orig = data2.time; % store, see note at data1.time_orig
                if isempty(data2.time)
                    logtext(fid, 'Secondary is empty, skipping\n');
                    continue
                end
                
                %%
                switch sign(data1.epoch - data2.epoch)
                    case -1 % data1 epoch is earliest
                        data2.time = data2.time + double(data2.epoch - data1.epoch);
                        data2.epoch = data1.epoch;
                    case 0 % do nothing
                    case 1 % data2 epoch is earliest
                        % FIXME: Bug? primary changes also for next loop
                        % iteration? Or should be ok as long as
                        % epoch/time consistent, maybe will iteratively
                        % increase but at least consistent
                        data1.time = data1.time + double(data1.epoch - data2.epoch);
                        data1.epoch = data2.epoch;
                    otherwise
                        error(['atmlab:' mfilename ':bug'], 'Reached impossible place. Bug.');
                end
                
                % overlap check 3: primary data, secondary data
                [iv1, iv2] = find_common_time(data1.time, data2.time, colloc_config('interval'));
                % limit to one day (if needed)
                switch oneday
                    case 1
                        % only consider data on the same date as the start for data1
                        if data1.time(1) < 86400
                            sameday = data1.time < 86400;
                        else
                            sameday = data1.time < 2*86400;
                        end
                        if ~all(sameday)
                            logtext(fid, 'taking only %d/%d that are on the same day\n', ...
                                sum(sameday), length(data1.time));
                        end
                        iv1 = iv1 & sameday;
                    case 2
                        % only consider data on date after the start date for data1
                        sameday = data1.time > 86400;
                        iv1 = iv1 & sameday;
                        if ~all(sameday)
                            logtext(fid, 'taking from primary only %d/%d that are on the next day\n', ...
                                sum(sameday), length(data1.time));
                        end
                end
                if ~(any(iv1) && any(iv2)) % no overlap
                    logtext(fid, 'upon checking actual data, no actual time overlap, so nothing to collocate\n');
                    continue
                end
                
                %% perform collocations
                collocations = collocate(data1.time(iv1), ...
                    data1.lat(iv1, :), ...
                    data1.lon(iv1, :), ...
                    data2.time(iv2), ...
                    data2.lat(iv2, :), ...
                    data2.lon(iv2, :), ...
                    colloc_config('distance'), colloc_config('interval'));
                if any(collocations)
                    % compensate for the fact that we passed only a subset to collocate
                    collocations(:, 1) = collocations(:, 1) + find(iv1, 1, 'first') - 1;
                    collocations(:, 3) = collocations(:, 3) + find(iv2, 1, 'first') - 1;
                else
                    logtext(fid, 'No collocations\n');
                    continue
                end
                %% process core
                % should return a matrix with info
                logtext(fid, 'Collecting info for %d collocations\n', size(collocations, 1));
                
                this_result = self.process(collocations, data1, date1, spec1, data2, secondary_granules(i, :), spec2);
                result = [result; this_result]; %#ok<AGROW>
                
                %% process additional
                %
                % additionals are all subclasses of AssociatedDataset able
                % to process data and knowing how to store it, how to deal
                % with it, etc.
                % for copying, a special AssociatedDataset shall take care
                % of this
                % FIXME: associated datasets
                % FIXME: additional fields copied
                for j = 1:length(additionals)
                    additional = additionals{j};
                    % FIXME: pass more, what else?
                    % FIXME: multiple datasets from one additional, or
                    % second additional needing output from 1st additional
                    % --> dependencies
                    % FIXME: concatenation in subfunction or so, will be
                    % needed in collocate_date and date_range as well
                    this_additional_result = additional.process_granule(this_result, data1, date1, spec1, data2, secondary_granules(i, :), spec2);
                    if isempty(additional_results{j})
                        additional_results{j} = this_additional_result;
                    else
                        additional_results{j} = [additional_results{j}; this_additional_result];
                    end
                end
                logtext(fid, 'Info collected\n');
            end
        end
        
        function [result, additional_results, also] = collocate_date(self, date, spec1, spec2, varargin)
            
            % collocate_date Collect all collocations for given date
            %
            % This method collects all collocations for the given date.
            %
            % FORMAT
            %
            %   [M, addis] = collocate_date([year, month, day], spec1, spec2)
            %
            % IN
            %
            %   datevec vector      [year month day]
            %   spec1
            %   spec2
            %   additionals (optional) cell array
            %
            % OUT
            %
            %   M       matrix      results...
            %   addis   cell array  results corresponding to additionals
            %
            % FIXME DOC
            %
            % $Id$
            
            additionals = optargs(varargin, {{}});
            
            fid = atmlab('OUT');
            year = date(1);
            month = date(2);
            day = date(3);
            % find granules for primary dataset; if the length equals one day, do not
            % take the day before as it's already sorted per day
            grans = self.primary.find_granules_by_date(date, spec1, ...
                self.primary.granule_duration~=86400);
            if isempty(grans)
                logtext(atmlab('ERR'), 'no granules found %s/%s %d-%d-%d\n', ...
                    self.primary.name, spec1, year, month, day);
            end
            ngrans = size(grans, 1);
            
            % pre-allocate; I know 'result's right size, but do not know
            % the right size for additional_results because I don't know
            % the sizes of the involved fields
            result = zeros(0, length(fieldnames(self.cols)));
            additional_results = cell(size(additionals));
            
            anysuccess = false;
            also = struct();
            
            for i = 1:ngrans
                % keep track, because first granule is probably yesterday
                thisyear = grans(i, 1);
                thismonth = grans(i, 2);
                thisday = grans(i, 3);
                hour = grans(i, 4);
                minute = grans(i, 5);
                
                logtext(fid, 'Collocating %s %s %04d-%02d-%02d %02d:%02d with %s %s \n', ...
                    self.primary.name, spec1, thisyear, thismonth, thisday, hour, minute, self.secondary.name, spec2);
                
                if ~isequal([thisyear thismonth thisday], [year month day]);
                    % only take collocations happening in part of granule occuring on
                    % the day requested
                    oneday = 2;
                else % take any collocations happening on the day requested
                    oneday = 1;
                end
                
                try
                    [result_granule, result_granule_addis, new_also] = self.collocate_granule(...
                        [thisyear, thismonth, thisday, hour, minute], spec1, spec2, additionals, oneday);
                    if ~isempty(fieldnames(also)) && ~isequal(also, new_also)
                        warning(['atmlab:' mfilename ':inconsistent'], ...
                            ['Additional information structures not consistent within the day. ' ...
                             'Expected: ' struct2string_compact(also) ...
                             'Got: ' struct2string_compact(new_also)]);
                    end
                    also = new_also;
                    anysuccess = true;
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', 'atmlab:find_granule_by_datetime'}
                            logtext(atmlab('ERR'), 'Error in searching for datafile %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'atmlab:collocate', 'atmlab:atovs_get_l1c:zamsu2l1c', 'atmlab:CollocatedDataset:noother', 'atmlab:collocate_granule:noother'}
                            logtext(atmlab('ERR'), 'Error in collocating with datafile at %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'MATLAB:hdfinfo:invalidFile', 'MATLAB:imagesci:hdfinfo:invalidFile'}
                            logtext(atmlab('ERR'), 'Cannot read datafile %s %s %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                                self.primary.name, spec1, thisyear, thismonth, thisday, hour, minute, ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                result = [result; result_granule]; %#ok<AGROW>
                for j = 1:length(additional_results)
                    if isempty(additional_results{j})
                        additional_results{j} = result_granule_addis{j};
                    else
                        additional_results{j} = [additional_results{j}; result_granule_addis{j}];
                    end
                end
            end
            
            if ~anysuccess
                error('atmlab:collocate_date:nosource', 'no source data found at all');
            end
            
        end
        
        function collocate_and_store_date(self, date, spec1, spec2, varargin)
            % collocate_and_store_date Collect collocations and store appropiately
            %
            % For a given date, check whether a collocation datafile exists.
            % If it doesn't (or colloc_config('overwrite') is set), collocate the indicated
            % satellites and sensors with each other and store the result in the
            % appropiate datafile.
            %
            % TODO:
            % use existing collocation but then read additional datasets
            %
            % FORMAT
            %
            %   collocate_and_store_date(date, spec1, spec2, additionals)
            %
            % IN
            %
            %   datevec
            %   spec1
            %   spec2
            %   additionals (optional)
            %
            % OUT
            %
            %   none (but writes file)
            
            additionals = optargs(varargin, {{}});
            % get filename
            
            if isempty(spec1)
                spec = spec2;
            elseif isempty(spec2)
                spec = spec1;
            else
                spec = {spec1, spec2};
            end
            
            fn = self.find_granule_by_datetime(date, spec);
            mainfileexists = exist(fn, 'file');
            addisexist = false(size(additionals));
            for i = 1:length(additionals)
                fna = additionals{i}.find_granule_by_datetime(date, spec);
                addisexist(i) = exist(fna, 'file');
            end
            
            % if everything is already there, do nothing
            if mainfileexists && all(addisexist) && ~colloc_config('overwrite')
                % FIXME TODO: should I check that the fields match?
                logtext(atmlab('OUT'), 'All output files already exist:\n', fn);
                logtext(atmlab('OUT'), '    %s\n', fn);
                for i = 1:length(additionals)
                    logtext(atmlab('OUT'), '    %s\n', additionals{i}.find_granule_by_datetime(date, spec));
                end
                return
            end
                            
            % so SOME work is to be done, at least
                           
            info_addi = struct();
            info_addi.history = [datestr(now, 'YYYY-mm-dd') ' Obtained additionals from collocs'];
            info_addi.parent_dataset = self.name;
            info_addi.parent_spec = spec;
            
            if mainfileexists && ~colloc_config('overwrite')
                logtext(atmlab('OUT'), 'Collocations exist, but additionals incomplete\n');
                % FIXME: don't reprocess all additionals, but read those
                % that are already there?
                [result, ~, attr] = self.read_date(date, spec, fieldnames(self.cols));
                info_addi.parent_id = attr.id;
                
                for i = 1:length(additionals)
                    logtext(atmlab('OUT'), 'Collecting additionals for ''%s''\n', additionals{i}.name);
                    addi = additionals{i}.process_delayed(result, spec1, spec2);
                    additionals{i}.store(date, spec, addi, info_addi);
                end

            else
                % assumption:
                % if the main file does not exist, associated don't either
                
                try
                    [result, addis, also] = ...
                        self.collocate_date(date, spec1, spec2, additionals);
                catch ME
                    switch ME.identifier
                        case {'atmlab:collocate_date:nosource', ...
                                'atmlab:CollocatedDataset:noother'}
                            logtext(atmlab('ERR'), ...
                                'No succesful collocations at %04d-%02d-%02d, not writing\n', ...
                                date(1), date(2), date(3));
                            return;
                        otherwise
                            ME.rethrow();
                    end
                end
                
                % additional attributes, main part
                
                info_core = struct();
                info_core.history = [datestr(now, 'YYYY-mm-dd') ' Collocations generated from scratch'];
                info_core.maxdist_km = colloc_config('distance');
                info_core.maxtime_s = colloc_config('interval');
                info_core.primary_dataset = self.primary.name;
                info_core.primary_info = spec1;
                info_core.primary_version = also.version{1};
                info_core.secondary_dataset = self.secondary.name;
                info_core.secondary_sensor = spec2;
                info_core.secondary_version = also.version{2};
                info_core.start_time = double(date2unixsecs(date(1), date(2), date(3)));

                [~, attr] = self.store(date, spec, result, info_core);
                
                info_addi.parent_id = attr.id;
                for i = 1:length(additionals)
                    additionals{i}.store(date, spec, addis{i}, info_addi);
                end
            end
        end
        
        function collocate_and_store_date_range(self, date_start, date_end, spec1, spec2, varargin)
            % FIXME DOC
            logtext(atmlab('OUT'), 'Starting collocations\n');
            logtext(atmlab('OUT'), '%s %s vs. %s %s\n', self.primary.name, spec1, self.secondary.name, spec2);
            logtext(atmlab('OUT'), 'From %s to %s\n', mat2str(date_start), mat2str(date_end));
            alldates = daterange(date_start, date_end);
            for i = 1:size(alldates, 1);
                year = alldates(i, 1);
                month = alldates(i, 2);
                day = alldates(i, 3);
                logtext(atmlab('OUT'), 'collocating %04d-%02d-%02d\n', ...
                    year, month, day);
                self.collocate_and_store_date([year, month, day], spec1, spec2, varargin{:});
            end
            logtext(atmlab('OUT'), 'Finished!\n');
            %%%
        end
        
        function M = process(self, collocations, data1, date1, spec1, data2, date2, spec2)
            % Process core collocations
            %
            % + Process 'core' fields
            % + Copy additional fields?
            % + Concatenate to what's already there?
            %
            % NOTE: time is assumed to be 1D
            
            n = size(collocations, 1);
            X = mat2cell(collocations, size(collocations, 1), [1 1 1 1]);
            
            c = self.cols;
            nfields = length(fieldnames(c));
            M = nan*zeros(n, nfields);
            [line1, pos1, line2, pos2] = X{:};
            
            % index for direct addressing
            i1 = sub2ind(size(data1.lat), line1, pos1);
            i2 = sub2ind(size(data2.lat), line2, pos2);
            
            M(:, c.LINE1) = line1;
            M(:, c.LINE2) = line2;
            
            M(:, c.POS1) = pos1;
            M(:, c.POS2) = pos2;
            
            M(:, c.LAT1) = data1.lat(i1);
            M(:, c.LON1) = data1.lon(i1);
            
            M(:, c.LAT2) = data2.lat(i2);
            M(:, c.LON2) = data2.lon(i2);
            
            % FIXME: this is not correct, use datevec!
            X = num2cell(date1);
            % round here; slight loss of precision causes this to be
            % slightly less than integer, which causes it to be floored
            % down to the /previous/ integer when storing in NetCDF later
            M(:, c.START1) = round(date2unixsecs(X{:}));
            X = num2cell(date2);
            M(:, c.START2) = round(date2unixsecs(X{:}));
            
            M(:, c.TIME1) = data1.epoch + data1.time(line1);
            M(:, c.TIME2) = data2.epoch + data2.time(line2);
            
            %% remove duplicates
            
            first1 = self.primary.granule_first_line(date1, spec1);
            first2 = self.secondary.granule_first_line(date2, spec2);
            wrongrows = (M(:, c.LINE1) < first1) | ...
                (M(:, c.LINE2) < first2);
            logtext(atmlab('OUT'), ['Removing %d scanlines primary before %d, ', ...
                'or secondary before %d\n'], ...
                sum(wrongrows), first1, first2);
            M(wrongrows, :) = [];
            
        end
        
        function [M, M_cols, addis, addis_cols, additionals] = read(self, date_start, date_end, spec, all_fields, varargin) 
            % collocation_read Read collocations for indicated period
            %
            % This method reads all or a selection of the collocations for
            % the indicated period, between date_start and date_end.
            %
            % FORMAT
            %
            % [M, M_cols, addis, addis_cols, additionals] = ...
            %       col.read(date_start, date_end, spec, fields[, limits[,
            %       filters]]);
            %
            % IN
            %
            %   date_start  datevec     First date to read
            %   date_end    datevec     Last date to read (inclusive)
            %   spec        various     Specification. Details depend
            %                           on dataset, but usually a
            %                           string with a satellite or a
            %                           cell array of strings with two
            %                           satellites.
            %   fields      cell-str    Cell array of strings with all
            %                           the fields to be read. Can be
            %                           from the core-dataset or from
            %                           the additional datasets.
            %
            % OPT
            %
            %   limits      structure   Structure describing acceptable
            %                           ranges for zero or more fields.
            %                           E.g. struct('LAT1', [-30 30])
            %                           will limit collocations to
            %                           those where the value of
            %                           'LAT1', is between -30 and +30,
            %                           inclusive on both ends.
            %
            %   filters     cell-array  Cell array of cell arrays:
            %                           {filter1, filter2, ...}. Each
            %                           filter1 is itself a cell-array
            %                           with 2 or 3 elements:
            %                           {handle, fieldnames, extra},
            %                           where handle is a
            %                           function-handle, fieldnames a
            %                           cell array of strings with
            %                           fields whose values will be
            %                           passed on to the filter, and
            %                           extra a cell array of arbitrary
            %                           values that will be passed on
            %                           to the handle as-is.
            % 
            % OUT
            %
            %   M       matrix      with values corresponding to fields stored
            %                       in core collocations
            %
            %   M_cols  structure   describing what field ended up in what
            %                       column of M
            %
            %   addis   cell-array  Cell array of matrices similar to 'M',
            %                       one for each additional dataset for
            %                       which at least one field was found
            %
            %   addis_cols structure Like M_cols, corresponding to each of
            %                       addis
            %
            %   associated cell-array of AssociatedData containing the
            %                       AssociatedData objects for which at
            %                       least one field ended up in addis.
            %
            % TODO:
            %  - read back from original data. Currently,
            %  col.collocate_and_store_date can already take care of this, if
            %  collocations exist.
            %  - so far limits and filters work only for core fields. Should
            %  work for any fields.
            %  - add check that associated-datasets match
            %
            % EXAMPLE
            %
            % [M, c, MM, cc, aa] = ...
            %       col.read([2007 1 1],[2007 1 10], 'n18', ...
            %                {'LAT1', 'LON1', 'LAT2', 'LON2', 'RO_ice_water_path', 'cld_reff_vis','cld_opd_vis'}, ...
            %                 struct('LAT1', [-30 30]), ...
            %                 {{@(x, y) x>y, {'LAT1', 'LON1'}}});
            
            %% prepare configuration things        
            
            [limits_all, filters_by_name] = optargs(varargin, {struct(), {}});
            % distribute fields, limits, etc. over core, additionals
            [fields_core, additionals, additional_fields, deal_index] = self.deal_fields(all_fields);
            additionals_limits = cell(size(additionals));
            % use deal_index to sort limits-fields in categories
            for i = 1:length(all_fields)
                field = all_fields{i};
                if any(strcmp(field, fieldnames(limits_all)))
                    if deal_index(i) == 0
                        limits_core.(field) = limits_all.(field);
                    else
                        additionals_limits{deal_index(i)}.(field) = limits_all.(field);
                    end
                end
            end

            additionals_day = cell(size(additional_fields));
            addis_cols = cell(size(additional_fields));
            addis = cell(size(additional_fields));
            for i = 1:length(addis)
                addis{i} = struct();
            end
            
            if nargout<3 && ~isempty(additionals)
                warning(['atmlab:' mfilename], ...
                    '%s was called with %d (<3) output arguments, additionals are lost', ...
                    mfilename, nargout);
            end
            % Not filtering duplicates, this should be done when processing
            % collocations initially

            M = [];
            
            %% loop through all the dates
            
            dates = daterange(date_start, date_end);
            M_cols = struct();
            filters_by_no = cell(size(filters_by_name));
            hitno = 0; % count no. of days with collocs
            for i = 1:size(dates, 1)
                date = dates(i, :);
                %% read collocations for date
                                                
                try
                    [collocations_day, M_cols_here] = self.read_single_day(date, spec, fields_core);
                    if max(size(collocations_day))==0
                        logtext(atmlab('OUT'), 'no collocations\n');
                        continue
                    end
                    M_cols = M_cols_here;
                    hitno = hitno + 1;
                    for j = 1:length(additionals)
                        [additionals_day{j}, addis_cols{j}] = additionals{j}.read_single_day(date, spec, additional_fields{j});
                    end
                catch ME
                    switch (ME.identifier)
                        case {'MATLAB:load:couldNotReadFile', 'MATLAB:nonExistentField', ...
                                'MATLAB:gunzip:invalidFilename','MATLAB:netcdf:open:noSuchFile', ...
                                'atmlab:exec_system_cmd:shell'}
                            logtext(atmlab('ERR'), 'Problem for %04d-%02d-%02d: %s\n', ...
                                date(1), date(2), date(3), ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                
                %% apply limitations
                if hitno == 1
                    % convert limits-structure to limits-matrix. This is
                    % only done after the first time I find collocations,
                    % because only then I know for sure what sizes the
                    % fields have.
                    limmat = limstruct2limmat(limits_all, M_cols);
                    for k = 1:length(filters_by_name)
                        filters_by_no{k} = {...
                            filters_by_name{k}{1}, ...
                            cellfun(@(s) M_cols.(s)', filters_by_name{k}{2}, 'UniformOutput', false), ...
                            filters_by_name{k}{3:end}};
                    end
                    
                end
                
                lim = collocation_restrain(collocations_day, limmat, filters_by_no);
                collocations_day = collocations_day(lim, :);
                for j = 1:length(additionals)
                    additionals_day{j} = additionals{j}.limit_to(additionals_day{j}, lim);
                end
                %                 if dolimits
                %                     lim = collocation_restrain(collocations_day, limmat, filters);
%                     collocations_day = collocations_day(lim, :);
%                 end
                
                %% add to total
                if isempty(M) % should mean additionals are empty, too
                    M = collocations_day;
                    addis = additionals_day;
                else
                    L = size(M, 1);
                    N = size(collocations_day, 1);
                    M((L+1):(L+N), :) = collocations_day;
                    for j = 1:length(additional_fields)
                        N_a = size(additionals_day{j}, 1);
                        addis{j}((L+1):(L+N_a), :) = additionals_day{j};
                    end
                end
            end
            if hitno==0
                warning(['atmlab:' mfilename], ...
                    'No collocations found at all. Do not trust column descriptions.');
            end
            
            %%%
        end
        
        % semi-internal use
        
        function add_associated(cd, ad)
            % INTERNAL USE adds an associated dataset
            %
            cd.associated = {cd.associated{:} ad}; %#ok<CCAT>
        end
        
    end
    
    methods (Access = private)
        function [fields, additionals, additional_fields, deal_index] = deal_fields(self, all_fields)
            % deal fields: core, additionals?
            n_f = 0;
            n_add = zeros(size(self.associated));
            additionals = {};
            additional_fields = {};
            deal_index = nan*zeros(size(all_fields));
            for i = 1:length(all_fields)
                field = all_fields{i};
                if any(strcmp(fieldnames(self.members), field))
                    n_f = n_f + 1;
                    fields{n_f} = field; %#ok<AGROW>
                    deal_index(i) = 0;
                else
                    found = false;
                    for j = 1:length(self.associated)
                        asso = self.associated{j};
                        if any(strcmp(fieldnames(asso.members), field))
                            n_add(j) = n_add(j) + 1;
                            additional_fields{j}{n_add(j)} = field; %#ok<AGROW>
                            % check if this additionaldataset is already
                            % known, if yes, find index in existing names
                            existing_names = cellfun(@(X) X.name, additionals, 'UniformOutput', false);
                            if ~any(strcmp(existing_names, asso.name))
                                additionals = {additionals{:} asso}; %#ok<CCAT>
                            end
                            samename = strcmp(cellfun(@(X) X.name, additionals, 'UniformOutput', false), asso.name);
                            assert(sum(samename)<=1, ['atmlab:' mfilename], ...
                                ['More than one additional contains field ' ...
                                 asso.name]);
                            deal_index(i) = find(samename);
                            found = true;
                        end
                    end
                    if ~found
                        error(['atmlab:' mfilename], ...
                            'Field %s was not found in core or in any additional dataset', ...
                            field);
                    end
                end
            end
        end
    end
end
