classdef Collapser < AssociatedDataset
    % collapse small footprint upon large footprint
    %
    % This class can be used for collocations where the primary has a
    % significantly larger footprint than the secondary, such as between
    % MHS and CloudSat or between MHS and AVHRR. It can be used e.g. for
    % calculation of arbitrary statistics, such as mean, standard
    % deviation, etc., or for selecting a single small-footprint for each
    % large-footprint. Whereas the original collocations contain one entry
    % for each of the smaller footprints --- thus repeating many times the
    % entry for the larger footprint --- a dataset with this class contains
    % at most one entry for each of the larger footprints. This is usually
    % the desirable behaviour.
    %
    % The class is normally associated with an <a href="matlab:help AssociatedDataset">AssociatedDataset</a> that works on
    % the full-size --- often this is <a href="matlab:help FieldCopier">FieldCopier</a>.
    %
    % For each primary footprint, the class copies data for the primary and
    % gathers data for the secondary. The data for the secondary is then
    % input to processing-functions, that can do arbitrary processing.
    % For example, processing functions may calculate the mean, the standard
    % deviation, the secondary closest to the primary, etc. Any
    % function-handle can be passed. The class can either pass all secondary
    % footprints, or a sub-set based on prescribed limitations (also with
    % function-handles). If no secondary footprints meet the requirements,
    % the primary footprint is not selected either. Limitations can be
    % either global (applying to all processors) or local (applying to a
    % single processor).
    %
    % Information on fields to be copied, fields to be processed, processor
    % functions, local limitatiors, global limitations, and how to store
    % fields, is all contained in a structure passed on to the constructor.
    % See <a href="matlab:help Collapser/Collapser">constructor documentation</a> for details.
    %
    % Collapser Properties:
    %
    %   fieldstruct -           Structure with complete field information
    %   overall_limitators -    Limitations applied to all fields
    %  (remaining properties inherited from <a href="matlab:help AssociatedDataset">AssociatedDataset</a>.
    %   Use <a href="matlab:properties Collapser">properties</a> for a complete listing)
    %
    % Collapser Methods:
    %
    %   Collapser -             Create Collapser object
    %  (remaining methods from <a href="matlab:help AssociatedDataset">AssociatedDataset</a>)
    %
    % Example:
    %
    %   >> mfcs.RO_ice_water_path.limitators = {@(X)(X>0)};
    %   >> mfcs.RO_ice_water_path.processors.MEAN = @mean;
    %   >> mfcs.RO_ice_water_path.stored.NO.type = 'single';
    %   >> global_lims = {@(X)(X(:, mhscpr.cols.DIST)<7.5), @(X)(abs(X(:, mhscpr.cols.INT))<600)};
    %   % f from <a href="matlab:help FieldCopier">FieldCopier</a> example
    %   >> mfc = Collapser(f, mfcs, global_lims, ...
    %           'name', 'MyLittleThing', 'basedir', '/some/path', ...
    %           'subdir', '$YEAR4/$MONTH/$DAY', ...
    %           'filename', 'mean_collocations_$SAT.nc.gz');
    %
    % See also: AssociatedDataset (abstract superclass), FieldCopier,
    %           CollocatedDataset, SatDataset, Collapser (constructor).
    %
    % Don't forget the Collocation User's Guide
    
    % TODO:
    %  - store result of limitators as bitfield?
    %  - store limitators in NetCDF props
    
    properties (Transient, SetAccess = protected)
        %members = []; % See <a href="matlab:help AssociatedDataset.members">AssociatedDataset.members</a>
        parent = []; % See <a href="matlab:help AssociatedDataset.parent">AssociatedDataset.parent</a>
        dependencies = {}; % See <a href="matlab:help AssociatedDataset.dependencies">AssociatedDataset.dependencies</a>
        
        % Structure with all fields information
        %
        % The members of this fieldstruct must correspond to fieldnames
        % contained by the <a href="matlab:help AssociatedDataset.parent">parent</a> dataset. The value of each entry
        % in this struct is itself a structure, as follows:
        %
        % entry_name (structure with name corresponding to parent fieldname)
        %
        %   limitators  cell-array of function_handle
        %
        %       Each limitator receives as input the subset of secondary
        %       footprints that fall within the primary footprint. Each
        %       limitator must return a logical 1-D vector with the same
        %       length as the number of footprints in the input. Any later
        %       processing functions are applied only to those collocations
        %       for which ALL limitators return true.
        %
        %   processors  structure
        %
        %       A structure with a field for each processing.
        %       The field is the processors name, such as MEAN,
        %       STD, etc. The value is a function handle. This
        %       function handle takes as input the secondary
        %       footprints corresponding to the primary
        %       footprint, after global and local limitators
        %       are applied. The function handle must return a
        %       single, scalar value, or a single row of values
        %       if the input data are 2-D.
        %
        %       The final members field will prepend each field
        %       with the name of its processor, e.g.
        %       MEAN_RO_ice_water_path, STD_RO_ice_water_path.
        %
        %   stored      structure
        %
        %       This structure contains information on how each
        %       field is stored. Fieldnames should be the same
        %       as for processors. Values are like for the <a href="matlab:help FieldCopier/fieldstruct_primary">Fieldcopier</a>.
        %       By default, no attributes are stored and all
        %       fields are stored as single (float).
        %
        %   incore      logical (scalar boolean)
        %
        %       If set to 'true', this field is not taken from the
        %       AssociatedDataset, but from the AssociatedDataset's parent,
        %       the CollocatedDataset or the core. This can be used to e.g.
        %       calculate an average position or to store a vector of
        %       line-numbers in the collapsed dataset.
        %
        % It is assumed that additional dimensions (no. channels, profile
        % height, etc.) for the collapsed field corresponds to the one for
        % the original field, which makes sense for mean, std, etc.  It
        % might not always be so; if it is not, one should explicitly set
        % (field).stored.(processor).profile = false
        fieldstruct = []; 
        % Cell array of global limitators.
        %
        % Global limitators are applied to the subset of secondary
        % footprints corresponding to a shared primary footprint before
        % going into any field-specific processing. It is suitable to use
        % for limiting distance or time for a certain averaging function.
        % Each function handle receives as input a matrix
        % of collocations, e.g. Nx14 when there are N
        % secondary inside the primary, and shall
        % return a logical of Nx1. All limitators are
        % processed sequentially and are applied to
        % all fields.
        overall_limitators = []; % List of global limitators
    end
        
    % $Id$
    methods
        %% constructor
        function self = Collapser(ad, fieldstruct, overall_limitators, varargin)
            % constructor for Collapser class
            %
            % This constructs a <a href="matlab:help Collapser">Collapser</a>
            %
            % FORMAT
            %
            %   cl = Collapser(ad, fs, global_lims, ...)
            %
            % IN
            %
            %   ad      AssociatedDataset
            %
            %       <a href="matlab:help AssociatedDataset">AssociatedDataset</a> from which this Collapser should
            %       take its data.
            %
            %   fs      structure
            %
            %       Structure giving full information on fields to process
            %       and how to process them. See <a href="matlab:help Collapser/fieldstruct">property docs</a> for details.
            %
            %   global_lims     cell array
            %
            %       See <a href="matlab:help Collapser/overall_limitators">property documentation</a>.
            %
            % OUT
            %
            %   Collapser object --- see <a href="matlab:help Collapser">class documentation</a>.
            %
            % EXAMPLE
            %
            %   See <a href="matlab:help Collapser">class docs</a>.

            cd = ad.parent;
            dependency = ad;
            
            % sort out which ones are just copied, which one processed
            % smartly
            
            self = self@AssociatedDataset(cd, {dependency}, varargin{:}); % call parent constructor
            
            % make sure all members have at least 'processors',
            % 'limiters', 'stored' and 'incore'; set appropiate
            % values where they don't
            fields = fieldnames(fieldstruct);
            for i = 1:length(fields)
                field = fields{i};
                if ~isfield(fieldstruct.(field), 'processors')
                    error(['atmlab:' mfilename], 'No processors specified for %s', field);
                end
                if ~isfield(fieldstruct.(field), 'limitators');
                    fieldstruct.(field).limitators = {@(x)true(size(x, 1), 1)};
                end
                if ~isfield(fieldstruct.(field), 'incore')
                    fieldstruct.(field).incore = false;
                end
                if fieldstruct.(field).incore
                    fieldstruct.(field).origin = cd;
                else
                    fieldstruct.(field).origin = ad;
                end
                % populate one or more 'members' for this field
                procnames = fieldnames(fieldstruct.(field).processors);
                for pi = 1:length(procnames)
                    procname = procnames{pi};
                    newfieldname = [upper(procname) '_' field];
                    newfield = fieldstruct.(field);
                    newfield = rmfield(newfield, 'processors');
                    newfield = rmfield(newfield, 'limitators');
                    newfield.orig_name = field;
                    if isfield(newfield.stored.(procname), 'type')
                        newfield.type = newfield.stored.(procname).type;
                    else
                        newfield.type = 'float';
                    end
                    if (isfield(fieldstruct, field) && ...
                        isfield(fieldstruct.(field), 'stored') && ...
                        isfield(fieldstruct.(field).stored, procname))
                        warning('off', 'catstruct:DuplicatesFound');
                        newfield = catstruct(newfield, fieldstruct.(field).stored.(procname));
                      
                    end
                    self.members.(newfieldname) = newfield;
                end
            end
            
            self.fieldstruct = fieldstruct;
            self.overall_limitators = overall_limitators;

            % add core members
            self.members.FIRST.type = 'int';
            self.members.FIRST.atts.long_name = 'First corresponding row in overlap';
            
            self.members.LAST.type = 'int';
            self.members.LAST.atts.long_name = 'Last corresponding row in overlap';
            
        end
        
    end
    
    methods (Access = {?SatDataset})
        %% implementation abstract methods
        
        function args = primary_arguments(~, ~)
            args = {};
        end
        
        function args = secondary_arguments(~, ~)
            args = {};
        end
        
        function bool = needs_primary_data(~, ~)
            bool = false;
        end
        
        function bool = needs_secondary_data(~, ~)
            bool = false;
        end
        
        function fields = fields_needed_for_dependency(self, fields, ~)
            fields = unique(struct2cell(structfun(@(e) safegetfield(e, 'orig_name', ''), getfields(self.members, fields{:}), 'UniformOutput', false)));
            fields = fields(~cellfun(@isempty, fields));
        end
        
        function [M, localcols] = process_granule(self, processed_core, ~, ~, ~, ~, ~, ~, deps, varargin)
            
            
            [deps_cols, memnames] = optargs(varargin, {{self.dependencies{1}.cols}, 'all'});
            M_data = deps{1};
%             deps_cols = cell2struct(deps_cols, cellfun(@(X) X.name, self.dependencies, 'UniformOutput', false), 2);
%            deps_cols = deps_cols{1};
            cols_data = deps_cols{1};
            
            %%%
            
            % Nomenclature note:
            %
            % - member is one geophysical quantity, e.g. IWP, LWP, etc.
            % - field is a resulting collapsed quantity, e.g. MEAN_IWP,
            % NO_LWP, etc.
            
            % check that sizes are the same
            assert(size(processed_core, 1)==size(M_data, 1), ...
                ['atmlab:' mfilename ':SizeError'], ...
                ['To average fields, core must have same no. of rows as associated. ' ...
                'Core has ' num2str(size(processed_core, 1)) ' rows, ' ...
                'associated has ' num2str(size(M_data, 1)) ' rows :(.']);
            ad = self.dependencies{1};
            cd = ad.parent;
            % split by primary footprint and find first and last index
            % corresponding to each footprint
            [uniques, firsts] = unique(processed_core(:, [cd.cols.START1 cd.cols.LINE1 cd.cols.POS1]), 'rows', 'first');
            lasts = [firsts(2:end)-1; size(processed_core, 1)];
            
            % put sizes in self.members in order to get self.cols
            if isequal(memnames, 'all')
                memnames = fieldnames(self.members);
            else
                rqre_subset(memnames, fieldnames(self.members));
                memnames = intersect(fieldnames(self.members), memnames);
                memnames = union(memnames, {'FIRST', 'LAST'});
            end
            
            for mi = 1:length(memnames)
                memname = memnames{mi};
                % special cases 'FIRST' and 'LAST' don't have any
                % corresponding data in the corresponding
                % additional-dataset, so no copying is to be done either
                if any(strcmp(memname, {'FIRST', 'LAST'}))
                    continue
                end
                mem = self.members.(memname);
                origmem = mem.origin.members.(mem.orig_name);
                if isfield(origmem, 'dims') && ~isfield(mem, 'dims')
                    mem.dims = origmem.dims;
                end
                % NB: commented out this 2013-03-25 as it caused flag
                % CV_ROIWP.atts.missing_value to be reset.
%                 w = warning('off', 'catstruct:DuplicatesFound');
%                 self.members.(memname) = catstruct(...
%                     self.members.(memname).origin.members.(mem.orig_name), ...
%                     self.members.(memname));
%                 warning(w);
                fields{mi} = self.members.(memname).orig_name;
            end
            self.members2cols();
            fields = unique(fields(~cellfun(@isempty, fields)));
            localcols = self.get_cols_from_bro(memnames, deps_cols);
%             if isequal(fields, 'all');
%                 fields = fieldnames(self.fieldstruct);
%                 self.set_cols_from_bro();
%                 localcols = self.cols;
%             else
%                 localcols = self.get_cols_from_bro(fields, deps_cols);
%             end
            
            nfields = max(cell2mat(struct2cell(localcols).'));
            
            % this flag is only used until the end of the function.  It signals
            % that the collapser gave no data for a particular footprint, but
            % only when this is due to the global limitator.  This data is
            % then removed, so this flag should never be exposed to the calling
            % function.
            %
            % When the footprint itself is valid (i.e. global limitator returns
            % some valid footprints) but the data are not (i.e. individual
            % limitators return nothing or data are flagged to begin with), data
            % are set to missing_value.
            flag_notset = -realmax(); % hopefully, no real data has this value!
            flag_globlimfailed = .9*-realmax();
            flag_allflagged = +realmax();
            M = flag_notset*ones(size(uniques, 1), nfields);
            
            % cache some things outside the loops to speed it up a bit
            % (done with profiler; code in this loop may be executed
            % millions of types for processing a single day)
            
            %fields = fieldnames(self.fieldstruct);
            n_overall_limitators = length(self.overall_limitators);
            has_overall_limitators = n_overall_limitators>0;
            answers = cell(1, n_overall_limitators);
%             field_has_limitators = cellfun(@(fname)~isempty(self.fieldstruct.(fname).limitators), fields);
%             field_limitators = cellfun(@(fname) self.fieldstruct.(fname).limitators, fields, 'UniformOutput', false);
            
            for k = 1:length(fields)
                fname = fields{k};
                procnames = fieldnames(self.fieldstruct.(fname).processors);
                
                field_limitators{k} = self.fieldstruct.(fname).limitators;
                field_has_limitators(k) = ~isempty(self.fieldstruct.(fname).limitators);
                all_procnames{k} = procnames;
                for pi = 1:length(procnames)
                    procname = procnames{pi};
                    proccers{k}{pi} =  self.fieldstruct.(fname).processors.(procname); 
                end
            end
            
            % keep track of time for logging purposes (progress etc.)
            t = 0;
            logtext(atmlab('OUT'), 'Processing %d primary footprints, %d fields, %d total stats, %d values/collocation\n', ...
                size(uniques, 1), length(fields), length(memnames), nfields);
            j = 0; % counter increases only when there is data
            for i = 1:size(uniques, 1) % need to be done in loop due to mean/std/etc.
                tic;
                first = firsts(i);
                last = lasts(i);
                M_coll_part = processed_core(first:last, :);
                M_data_part = M_data(first:last, :);
                
                j = j + 1;
                
                % limitation to all, e.g. for distances
                if ~has_overall_limitators;
                    lim_for_all_fields = true(size(M_data_part, 1), 1);
                else
                    % 2nd version is much faster.  This was still often the
                    % slowest part of the function, applying the overall
                    % limitators, for cases with few fields.
                    %answers = cellfun(@(X)(X(:)), cellfun(@(f)f(M_coll_part), self.overall_limitators, 'UniformOutput', false), 'UniformOutput', false);
                    for ii = 1:n_overall_limitators
                        answers{ii} = flat(self.overall_limitators{ii}(M_coll_part));
                    end

                    lim_for_all_fields = all(horzcat(answers{:}), 2);
                    if ~any(lim_for_all_fields)
                        M(j, :) = flag_globlimfailed;
                        continue
                    end
                end
                
%                 M(j, self.cols.FIRST) = processed_core(first, cd.cols.INDEX);
%                 M(j, self.cols.LAST) = processed_core(last, cd.cols.INDEX);
                M(j, localcols.FIRST) = processed_core(first, cd.cols.INDEX);
                M(j, localcols.LAST) = processed_core(last, cd.cols.INDEX);
               
                % for each field, apply limitations and call processing
                % function on sub-limited set, if any are actually left
                % also keep track if we had any valid fields here
                anyvalidfields = false;
                for k = 1:length(fields)
                    fname = fields{k};
                    if self.fieldstruct.(fname).incore
                        M_source = M_coll_part;
                    else
                        M_source = M_data_part;
                    end
                    
                    % iteratively apply limitations, only if all
                    % limitations return true (including
                    % lim_for_all_fields) the collocation is selected for
                    % further average-processing
                    if ~field_has_limitators(k)
                        limsel = true(size(M_source, 1), 1);
                    else
                        limsel = lim_for_all_fields;
                        limmers = field_limitators{k};
                        
                        for li = 1:length(limmers)
                            limmer = limmers{li};
%                             limhere = limmer(M_source(:, self.fieldstruct.(fname).origin.cols.(fname)));
                            limhere = limmer(M_source(:, cols_data.(fname)));                            
                            limsel = limsel(:) & limhere(:);
                        end
                    end
      
                    procnames = all_procnames{k};
                    if any(limsel)
                        % apply all processors and store in appropiate
                        % place
                        for pi = 1:length(procnames)
                            procname = procnames{pi};
                            if ~isfield(localcols, [procname '_' fname])
                                % probably processor is already there; in
                                % any case, it was not asked for
                                continue
                            end
                            %proccer = self.fieldstruct.(fname).processors.(procname);
%                             capsed = proccers{k}{pi}(M_source(limsel, self.fieldstruct.(fname).origin.cols.(fname)));
                            capsed = proccers{k}{pi}(M_source(limsel, cols_data.(fname)));
                         
                            %if ~isequal(size(capsed), [1 length(self.cols.([procname '_' fname]))])
                            if ~isequal(size(capsed), [1, length(localcols.([procname '_' fname]))])                                
                                error(['atmlab:' mfilename ':mismatch'], ...
                                ['Error in collapsing %s %s %s. Processor ', ...
                                 'returned wrongly-sized field. Got [%d, %d]. ', ...
                                 'Expected [%d, %d].'], ...
                                self.name, fname, procname, size(capsed, 1), ...
                                size(capsed, 2), 1, length(localcols.([procname '_' fname])));
%                                size(capsed, 2), 1, length(self.cols.([procname '_' fname])));                            
                            end
                            M(j, localcols.([procname '_' fname])) = capsed;
%                            M(j, self.cols.([procname '_' fname])) = capsed;                            
                            anyvalidfields = true;
                        end
                    else
                        % set all processors for this field to missing_val
                        for pi = 1:length(procnames)
                            procname = procnames{pi};
                            if isfield(localcols, [procname '_' fname])
                                %M(j, self.cols.([procname '_' fname])) = self.fieldstruct.(fname).stored.(procname).atts.missing_value;
                                M(j, localcols.([procname '_' fname])) = self.fieldstruct.(fname).stored.(procname).atts.missing_value;
                            end
                        end
                    end
                end
                % remove if any are valid at all
                % FIXME: make this optional
                if ~anyvalidfields
                    M(j, :) = flag_allflagged;
                end
                t = t + toc;
                if t > 600
                    logtext(atmlab('OUT'), 'Done %d/%d\n', ...
                        i, size(uniques, 1));
                    t = 0;
                end
            end
            
            % remove remaining part of M, e.g. where I did too much
            % pre-allocation or no relevant data was found
            rest = all(M==flag_globlimfailed, 2);
            % FIXME: what to do with the other flags?
            M(rest, :) = [];
            logtext(atmlab('OUT'), '%d collocations -> %d collapsed and valid collocations\n', ...
                size(processed_core, 1), size(M, 1));
            %%%
            
        end
        
        %% overload parent methods
        
        function [M, M_cols] = merge_matrix(self, M_core, cols_core, M_self, cols_self)
            M = [M_core(M_self(:, cols_self.FIRST), :) M_self];
            M_cols = self.merge_new_cols(M_core, cols_core, cols_self);
        end
        
        function S = merge_struct(varargin)
            error(['atmlab:' mfilename ':notimplemented'], ...
                'Collocating collapsed datasets is not implemented yet');
        end
        
        function C = get_mergefields(self) %#ok<MANU>
            C = {'FIRST'};
        end
        
        function new = concatenate(self, old_core_result, old_additional_result, new_additional_result)
            if isempty(new_additional_result)
                new = old_additional_result;
                return
            end
            if ~isempty(old_core_result)
                correction = old_core_result(end, self.parent.cols.INDEX);
                new_first = new_additional_result(:, self.cols.FIRST) + correction;
                new_last = new_additional_result(:, self.cols.LAST) + correction;
                new_additional_result(:, self.cols.FIRST) = new_first;
                new_additional_result(:, self.cols.LAST) = new_last;
            end
            if isempty(old_additional_result)
                new = new_additional_result;
            else
                new = [old_additional_result; new_additional_result];
            end
        end
        
        function [S, strattr] = read_homemade_granule(self, file, varargin)
            info = self.find_info_from_granule(file);
            dt = [str2double(info.year), str2double(info.month), str2double(info.day)];
            extra_fields = optargs(varargin, {{}});
            core_fields = {'LAT1', 'LON1', 'TIME1'};%, 'FIRST', 'LAST'};
            all_fields = union(extra_fields, core_fields);
            [M, c] = self.parent.read(dt, dt, info.satname, ...
                all_fields, ...
                struct(), ...
                {}, ...
                [self.dependencies, {self}]);
            %self.parent.read_homemade_granule(self.parent.find_granule_by_datetime([2007, 1, 1], 'noaa18'), {})
            if isempty(M)
                S = cell2struct(repmat({[]}, [1, length(all_fields)]), all_fields, 2);
                S.lat = [];
                S.lon = [];
                S.epoch = [];
                S.time = [];
                S.version = 0;
                return
            end
            % need to call cast_fields_back for each dataset-type
            % individually
            [fields_core, additionals, additional_fields] = self.parent.deal_fields(all_fields, self.parent.associated);
            S = self.parent.cast_fields_back(M, getfields(c, fields_core{:}));
            for i = 1:length(additionals)
                S = catstruct(S, ...
                              additionals{i}.cast_fields_back(M, ...
                                                              getfields(c, ...
                                                              additional_fields{i}{:})));
            end
%            from_parents = intersect(all_fields, fieldnames(self.parent.members));
%            from_self = intersect(all_fields, fieldnames(self.members));
%            S1 = self.parent.cast_fields_back(M, getfields(c, from_parents{:}));
%            S2 = self.cast_fields_back(M, getfields(c, from_self{:}));
%            S = catstruct(S1, S2);
%            S = self.cast_fields_back(M, getfields(c, all_fields{:}));
            S.lat = S.LAT1;
            S.lon = S.LON1;
            [year, month, day, hour, minute, second] = unixsecs2date(S.TIME1);
            S.epoch = min(date2unixsecs(year, month, day));
            S.time = S.TIME1 - S.epoch;
            S.version = 0;
            %error('Not implemented');
        end
        
        function set_cols_from_bro(self)
            % Set cols-structure based on brothers cols
            %
            % When a collapsed dataset is processed, the AssociatedDataset
            % it belongs to has always been processed already, so from its
            % cols-structure can be inferred all the expected sizes.  Use
            % this to set or update the local cols-structure.
            self.cols = self.get_cols_from_bro(self, fieldnames(self.members));
        end
        
        function cc = get_cols_from_bro(self, members, deps_cols)
            % get cols-structure based on brothers cols
            %
            % When a collapsed dataset is processed, the AssociatedDataset
            % it belongs to has always been processed already, so from its
            % cols-structure can be inferred all the expected sizes.  Use
            % this to set or update the local cols-structure.
            n = 1;
            for i = 1:length(members)
                field = members{i};
                if isfield(self.members.(field), 'origin') && ...
                        ~(isfield(self.members.(field), 'profile') && self.members.(field).profile==false)
                    % if it has an origin, it should have an orig_name
                    if isempty(fieldnames(self.members.(field).origin.cols))
                        ncols = length(deps_cols{...
                            strcmp(self.members.(field).origin.name, ...
                                cellfun(@(X) X.name, ...
                                    self.dependencies, ...
                                    'UniformOutput', false))}.(self.members.(field).orig_name));
                    else
                        ncols = length(self.members.(field).origin.cols.(self.members.(field).orig_name));
                    end
                    % FIXME/TODO: should reuse existing dimension names...
                    self.members.(field).dims = {sprintf('HEIGHT_%s', field), ncols};
                else % should be FIRST, LAST... ncols==1
                    ncols = 1;
                end
                cc.(field) = n:(n+ncols-1);
                n = n + ncols;
            end
        end
        
    end
    
end
