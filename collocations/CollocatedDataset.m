classdef CollocatedDataset < SatDataset %& HomemadeDataset
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
        associated = [];
        %version = {'', ''};
        collocated_data;
        
        members = struct(...
            'START1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary granule start time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LINE1', struct(...
                'type', 'short', ...
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
                'type', 'short', ...
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
        
        cols;
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
        
        %%
        
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
            
            b = find(granule_start - colloc_config('interval') > granules_unixsecs, 1, 'last');
            
            % first granule ending before the reference granule
            
            e = find(granule_end + colloc_config('interval') < granules_unixsecs, 1, 'first');
            
            secondary_granules = threedays(b:e, :);
        end
        
        function [result, additional_results] = collocate_granule(self, date1, spec1, spec2, varargin)
            
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
                data1 = self.primary.read_granule(date1, spec1, extra_args_primary, false); % keep duplicates for now
            catch ME
                switch ME.identifier
                    case {'MATLAB:load:couldNotReadFile', 'atmlab:invalid_data'}
                        logtext(eid, 'Collocating failed: %s\n', ME.message);
                        return
                    otherwise
                        ME.rethrow();
                end
            end
            
            %self.version{1} = self.primary.version;
            %self.version{2} = '?'; % secondary version not yet available
            
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
                
                %self.version{2} = self.secondary.version;
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
                    this_additional_result = additional.process(collocations, this_result, data1, date1, spec1, data2, secondary_granules(i, :), spec2);
                    if isempty(additional_results{j})
                        additional_results{j} = this_additional_result;
                    else
                        additional_results{j} = [additional_results{j}; this_additional_result];
                    end
                end
                logtext(fid, 'Info collected\n');
            end
        end
        
        function result = collocate_date(self, date, spec1, spec2, varargin)
            
            % collocate_date Collect all collocations for given date
            %
            % This method collects all collocations for the given date.
            %
            % FORMAT
            %
            %   M = collocate_date([year, month, day], spec1, spec2)
            %
            % IN
            %
            %   datevec vector      [year month day]
            %   spec1
            %   spec2
            %
            % OUT
            %
            %   M       matrix      results...
            %
            % FIXME DOC
            %
            % $Id$
            
            
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
                    spec1, year, monht, day);
            end
            ngrans = size(grans, 1);
            
            result = zeros(0, length(fieldnames(self.cols)));

            anysuccess = false;
            
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
                    result_granule = self.collocate_granule(...
                        [thisyear, thismonth, thisday, hour, minute], spec1, spec2, oneday);
                    anysuccess = true;
                catch ME
                    switch ME.identifier
                        case 'atmlab:find_datafile_by_date'
                            logtext(atmlab('ERR'), 'Error in searching for datafile %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'atmlab:collocate', 'atmlab:atovs_get_l1c:zamsu2l1c', 'atmlab:collocate_granule:noother'}
                            logtext(atmlab('ERR'), 'Error in collocating with datafile at %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'MATLAB:hdfinfo:invalidFile'}
                            logtext(atmlab('ERR'), 'Cannot read datafile %s %s %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                                self.primary.name, spec1, thisyear, thismonth, thisday, hour, minute, ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                result = [result; result_granule]; %#ok<AGROW>
            end
            
            if ~anysuccess
                error('atmlab:collocate_date:nosource', 'no source data found at all');
            end
            
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
            M(:, c.START1) = data1.epoch; % FIXME: not really
            M(:, c.START2) = data2.epoch; % FIXME: not really
            
            M(:, c.TIME1) = data1.epoch + data1.time(line1);
            M(:, c.TIME2) = data2.epoch + data2.time(line2);
                        
            %% remove duplicates
            
            first1 = self.primary.granule_first_line(date1, spec1);
            first2 = self.secondary.granule_first_line(date2, spec2);
            wrongrows = (M(:, c.LINE1) < first1) & ...
                        (M(:, c.LINE2) < first2);
            logtext(atmlab('OUT'), ['Removing %d scanlines primary before %d, ', ...
                                   'or secondary before %d\n'], ...
                                   sum(wrongrows), first1, first2); 
            M(wrongrows, :) = [];
            
        end

        %%
        
        function add_associated(cd, ad)
            % INTERNAL USE adds an associated dataset
            %
            cd.associated = [cd.associated ad];
        end
        

    end
end

%%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS %%
%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
%% END OF FILE %%
%%%%%%%%%%%%%%%%%
