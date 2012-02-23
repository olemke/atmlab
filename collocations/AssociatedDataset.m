classdef AssociatedDataset < SatDataset & HomemadeDataset
    % Defined data associated with CollocatedDataset
    %
    % Meant to be subclassed, not instantiated directly.
    % To just copy fields, use subclass FieldCopier
    %
    % Work in progress!
    %
    % $Id$
    
    % need to know:
    % - additional arguments to reader primary
    % - additional arguments to reader secondary
            
    properties (Abstract, SetAccess = protected)
        members;
        parent;
        dependencies;
    end
    
    properties
        priority = 0; % to determine order of passing on
    end
    
    methods
        function self = AssociatedDataset(varargin)
            % 2 modes:
            % if 1st argument is CollocatedDataset, then:
            % cd: CollocatedDataset it belongs to
            % dependencies: AssociatedDatasets to be processed first
            % rest of arguments passed on to SatDataset
            % otherwise all to parent
            %
            % FIXME DOC
            if nargin>0 && isa(varargin{1}, 'CollocatedDataset') % dynamic style
                style = 'dynamic';
                cd = varargin{1};
                dp = varargin{2};
                [subargs{1:nargin-2}] = varargin{3:end};
            else
                style = 'static';
                [subargs{1:nargin}] = varargin{:};
            end
            self = self@SatDataset(subargs{:}); % call parent constructor
            if strcmp(style, 'dynamic')
                self.parent = cd;
                self.dependencies = dp;
            end
            self.parent.add_associated(self);
        end
        
        function members2cols(self)
            % converts self.members to corresponding self.cols
            %
            % Assumes sizes in self.members are correct. This may not
            % always be the case before the first data is read!
            allnames = fieldnames(self.members);
            tot = 1;
            for i = 1:length(allnames)
                fname = allnames{i};
                fl = self.members.(fname);
                if isfield(fl, 'dims')
                    no = self.members.(fname).dims{2};
                else
                    no = 1;
                end
                % self.cols is in HomemadeDataset
                self.cols.(fname) = tot:(tot+no-1);
                tot = tot + no;
            end
        end
        
        function out = process_delayed(self, processed_core, spec1, spec2, varargin)
            % FIXME DOC
            %
            % processed_core   should match self.parent.cols
            % spec1
            % spec2
            % depies    cell array with outputs of process_delayed for
            %           whatever this processing function depends on,
            %           defaults to empty cell array
            %
            % FIXME TODO:
            % for a full day granule, split into individual granules, read
            % data for each granule, get collocations for this granule,
            % and pass to self.process(...)
            
            depies = optargs(varargin, {{}});
            % divide in segments where new primary, new secondary starts
            [~, newprim] = unique(processed_core(:, self.parent.cols.START1), 'rows', 'first');
            [~, newsec] = unique(processed_core(:, self.parent.cols.START2), 'rows', 'first');
            % also add 'end' to it, because want to determine segments
            newseg = unique([newprim; newsec]);
            % empty data-structs are all I pass to processors not needing
            % data
            data1 = struct();
            data2 = struct();
            primseg = 0;
            seconseg = 0;
            out = [];
            
            for segcount = 1:length(newseg)
                segstart = newseg(segcount);
                % end of segment: either beginning of next, or end of data
                if segcount < length(newseg)
                    segend = newseg(segcount+1)-1;
                else
                    segend = size(processed_core, 1);
                end
                % keep track of 'primary segment' and 'secondary segment'
                % to know corresponding date1, data1, etc.
                if primseg<length(newprim) && segstart == newprim(primseg+1)
                    primseg = primseg + 1;
                    [dv{1:6}] = unixsecs2date(processed_core(newprim(primseg), self.parent.cols.START1));
                    date1 = cell2mat(dv);
                    if self.needs_primary_data()
                        data1 = self.parent.primary.read_granule(date1, spec1, self.primary_arguments(), false, false);
                    end
                end
                if seconseg<length(newsec) && segstart == newsec(seconseg+1)
                    seconseg = seconseg + 1;
                    [dv{1:6}] = unixsecs2date(processed_core(newsec(seconseg), self.parent.cols.START2));
                    date2 = cell2mat(dv);
                    if self.needs_secondary_data()
                        data2 = self.parent.secondary.read_granule(date2, spec2, self.secondary_arguments(), false, false);
                    end
                end
                new_out = self.process_granule(processed_core(segstart:segend, :), data1, date1, spec1, data2, date2, spec2, depies);
                if isempty(out)
                    out = new_out;
                else
                    out = [out; new_out]; %#ok<AGROW>
                end
            end
        end
    end
    
    methods (Static)
        function data_out = limit_to(data_in, lim)
            % limit_to Limit data to logical
            %
            % FORMAT
            %
            %   data = limit_to(data, lim)
            %
            % IN
            %
            %   data    matrix          input data
            %   lim     logical array   what rows to select
            %
            % OUT
            %
            %   data    matrix          output data
            %
            % Limit associated data to logical. This is trivial if the
            % associated data is at the same resolution as the core data,
            % but non-trivial if it is on a different resolution.
            
            data_out = data_in(lim, :);
        end
        
        function lim_out = limit_from(~, lim_in)
            % limit_from Translate associated-limits to core-limits
            %
            %
            % FORMAT
            %
            %   lim_out = limit_from(data, lim_in)
            %
            % IN
            %
            %   data    matrix          input data for associated dataset
            %   lim_in  logical array   limits applying to associated
            %                           dataset
            %
            % OUT
            %
            %   lim_out logical array   limits applying to core dataset
            %
            % Translate limits. Trivial when on same size, non-trivial
            % otherwise.
            
            lim_out = lim_in;
        end
    end
    
    % those methods must be implemented by subclasses
    methods (Abstract)
        args = primary_arguments(self)
        args = secondary_arguments(self)
        bool = needs_primary_data(self)
        bool = needs_secondary_data(self)

        out = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies)
        %store(self, date, spec, result)
    end
    
end
