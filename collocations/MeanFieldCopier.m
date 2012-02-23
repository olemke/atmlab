classdef MeanFieldCopier < MeanDataset% & FieldCopier
    % copy fields and average them over the larger footprint
    %
    % the secondary will be averaged over the primary
    %
    % Based on a FieldCopier, takes one structure whose members indicate:
    % - what fields to copy (from first 'inside' footprint)
    % - what other processing to do, e.g. member 'processors' is itself a
    % structure with MEAN=@mean, STD=@std, etc.
    % - how to store fields (default: like parent; warning: loss of
    % precision may occur in default case, e.g. averaging int to int)
    % - ...
    % - overall limitators (e.g. maximum distance), those are passed the
    % core collocations where secondary is within primary (e.g. Nx14), and
    % should return a Nx1-logical
    % - specific limitators (e.g. positive values), those are passed the
    % data that the processors will act upon (e.g. (Nxp) where p is 1 for
    % scalar data, but may also be an entire profile), and should return
    % a Nx1-logical.
    % 
    % for this one, 'fieldstruct' and 'members' are different, since
    % 'members' relates to what's actually stored, which may be more than
    % 'fieldstruct', which relates to fields. E.g. if MEAN and STD for a
    % field IWP are stored, we have in fieldstruct
    % IWP.processors.MEAN = @mean;
    % IWP.processors.STD = @std;
    % but in members
    % MEAN_IWP
    % STD_IWP
    %
    % FIXME DOC
    %
    % TODO:
    %  - store result of limitators as bitfield
    %  - do storing
    %      + store limitators in NetCDF props
    %  - do reading
    
    properties (SetAccess = protected)
        members = []; % set dynamically
        parent = []; % the same
        dependencies = {}; % the same
        fieldstruct = []; % also dynamically set
        overall_limitators = []; % the trend may be clear by now
    end
        
    % $Id$
    methods
        function self = MeanFieldCopier(ad, fieldstruct, overall_limitators, varargin)
            % - first  the corresponding associated-dataset
            % - second the fieldstruct, see class doc
            % - third cell array of 'global' limitators operating on core
            % - rest passed to parent classes, ultimately to SatDataset
            % FIXME DOC
            
            cd = ad.parent;
            dependency = ad;
            
            % sort out which ones are just copied, which one processed
            % smartly
            
            self = self@MeanDataset(cd, {dependency}, varargin{:}); % call parent constructor
            
            % make sure all members have at least 'processors' and
            % 'limiters'; set noops where they don't.
            % also populate actual 'members' structure
            fields = fieldnames(fieldstruct);
            for i = 1:length(fields)
                field = fields{i};
                if ~isfield(fieldstruct.(field), 'processors')
                    error(['atmlab:' mfilename], 'No processors specified for %s', field);
                end
                if ~isfield(fieldstruct.(field), 'limitators');
                    fieldstruct.(field).limitators = {@(x)true(size(x))};
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
        
        
        function args = primary_arguments(~)
            % needs nothing, because uses ONLY FieldCopier output
            args = {};
        end
        
        function args = secondary_arguments(~)
            % see comment for primary_arguments
            args = {};
        end
        
        function bool = needs_primary_data(~)
            % see comment for primary_arguments
            bool = false;
        end
        
        function bool = needs_secondary_data(~)
            % see comment for primary_arguments
            bool = false;
        end
        
        function M = process_granule(self, processed_core, ~, ~, ~, ~, ~, ~, deps)
            % FIXME TODO
            %
            % - pre-allocate M, need to know no. of cols
            % - use smaller subset, user passes on limitation somehow,
            %   should be to class constructor; limitation on distance,
            %   limitation on data values...
            % - set self.cols appropiately
            % - limitation on data values for fields with more than one,
            % contains bugs 
            % - implement lim_to_all
            %
            % does not use original data
            
            %%%
                        
            M_data = deps{1};
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
            memnames = fieldnames(self.members);
            for mi = 1:length(memnames)
                memname = memnames{mi};
                % special cases 'FIRST' and 'LAST' don't have any
                % corresponding data in the corresponding
                % additional-dataset, so no copying is to be done either
                if any(strcmp(memname, {'FIRST', 'LAST'}))
                    continue
                end
                mem = self.members.(memname);
                self.members.(memname) = catstruct(...
                    ad.members.(mem.orig_name), ...
                    self.members.(memname));
            end
            self.members2cols();
            
            nfields = max(cell2mat(struct2cell(self.cols).'));
            M = nan*zeros(size(uniques, 1), nfields);
            
            fields = fieldnames(self.fieldstruct);
            j = 0; % counter increases only when there is data
            for i = 1:size(uniques, 1) % need to be done in loop due to mean/std/etc.
                first = firsts(i);
                last = lasts(i);
                M_coll_part = processed_core(first:last, :);
                M_data_part = M_data(first:last, :);
                % FIXME TODO 
                %CS_in_MHS = M_coll_part(:, c.overlap.B_DIST) < colloc_config('distance_for_average_MHS');
                %CS_in_HIRS = M_coll_part(:, c.overlap.H_DIST) < colloc_config('distance_for_average_HIRS');
                %flagged = M_data_part(:, c.data.ROIWP) < 0;
                %
                %if all(flagged | ~CS_in_MHS) % don't bother, all are flagged
                %    continue
                %end
                %
                %fine = CS_in_MHS & ~flagged;
                
                j = j + 1;
                M(j, self.cols.FIRST) = first;
                M(j, self.cols.LAST) = last;

                % limitation to all, e.g. for distances
                answers = cellfun(@(X)(X(:)), cellfun(@(f)f(M_coll_part), self.overall_limitators, 'UniformOutput', false), 'UniformOutput', false);
                lim_for_all_fields = all(horzcat(answers{:}), 2);
                if ~any(lim_for_all_fields)
                    continue
                end
                
                % for each field, apply limitations and call processing
                % function on sub-limited set, if any are actually left
                for k = 1:length(fields)
                    fname = fields{k};
                    
                    % iteratively apply limitations, only if all
                    % limitations return true (including
                    % lim_for_all_fields) the collocation is selected for
                    % further average-processing
                    limsel = lim_for_all_fields;
                    limmers = self.fieldstruct.(fname).limitators;

                    for li = 1:length(limmers)
                        limmer = limmers{li};
                        limhere = limmer(M_data_part(:, ad.cols.(fname)));
                        limsel = limsel(:) & limhere(:);
                    end
                    
                    if any(limsel)
                        procnames = fieldnames(self.fieldstruct.(fname).processors);
                        % apply all processors and store in appropiate
                        % place
                        for pi = 1:length(procnames)
                            procname = procnames{pi};   
                            proccer = self.fieldstruct.(fname).processors.(procname);
                            M(j, self.cols.([procname '_' fname])) = proccer(M_data_part(limsel, ad.cols.(fname)));
                        end
                    end
                end
            end
            
            % remove remaining part of M, e.g. where I did too much
            % pre-allocation or no relevant data was found
            rest = isnan(M(:, 1));
            M(rest, :) = [];
            logtext(atmlab('OUT'), '%d collocations -> %d mean collocations\n', ...
                size(processed_core, 1), size(M, 1));
            %%%
            
        end
        
        % FIXME: implement reading, how again?
    end
    
    methods (Static)
        function lim_out = limit_to(data_in, lim)
            % for example:
            % 'lim' may be 258712x1 logical
            % data_in may be 1820x2 double
            % then lim_out must be 1820x1 logical
            if all(lim)
                lim_out = true(size(data_in, 1), 1);
            else
                error(['atmlab:' mfilename 'NotImplemented'], ...
                    'Limitations with smaller-sized datasets not implemented');
            end
        end
        
        function lim_out = limit_from(~, lim_in)
            % FIXME!
            error('Not implemented');
        end
        
        
    end
end
