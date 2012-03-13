classdef FieldCopier < AssociatedDataset
    % class to simply copy fields from original datasets to collocated
    % 
    % Works by passing on fieldnames to reading routine(s) and copying data
    % UNPROCESSED to output reading.
    %
    % For initialisation, see FieldCopier.FieldCopier (constructor)
    %
    % Example, just finding collocations for a single granule, without
    % storing:
    %
    % >> col = datasets_config('collocation_cpr_mhs');
    % >> f = FieldCopier(col, struct('RO_ice_water_content', '', 'RO_liq_water_content', ''), struct(),varagin);
    % >> [result, addis] = col.collocate_granule([2009 12 7 3 28], '', 'noaa18', {f});
    % 
    % Now:
    % - `result` is a 91818x12 matrix with columns described in col.cols
    % - `addis` is a 1x1 cell array with outputs corresponding to the 1x1
    %   cell-array {f}
    % - addis{1} is a 91818x250 matrix with columns described in f.cols, in
    %   this case corresponding to 125 IWC and 125 LWC values, e.g.
    %   f.cols.RO_liq_water_content(1) = 126 meaning column 126 of addis{1}
    %   corresponds to the first value in the LWC-profile.
    %
    % $Id$
    %
    % TODO:
    %  - set some (but not all!!) clever properties for NetCDF
    
    properties (SetAccess = protected)
        
        % this is split in primary and secondary because from these
        % structures is also derived what arguments to pass on to the
        % respective reading routines
        fieldstruct_primary = struct;
        fieldstruct_secondary = struct;
        members = struct(); % set by constructor
        parent = []; % set dynamically, per instance
        dependencies = {}; % set dynamically, per instance
    end    
    
    methods
        function self = FieldCopier(cd, fieldstruct1, fieldstruct2, varargin)
            % cd            CollocatedDataset
            % fieldstruct1  defines names and how to store, from primary
            % fieldstruct2  the same, from secondary
            % remaining arguments passed on to SatDataset, so those are to
            % be used to say where to store and so on. 
            %
            % need to know:
            % - additional arguments to reader primary
            % - additional arguments to reader secondary
            self = self@AssociatedDataset(cd, {}, varargin{:}); % call parent constructor
            
            self.fieldstruct_primary = fieldstruct1;
            self.fieldstruct_secondary = fieldstruct2;
            
            
            % check consistence of fieldstructs
            
            allfields = catstruct(fieldstruct1, fieldstruct2);
            assert(length(fieldnames(fieldstruct1))+length(fieldnames(fieldstruct2))==length(fieldnames(allfields)), ...
                    ['atmlab:' mfilename ':duplicates'], 'Duplicate fieldnames between datasets are not permitted, but were found :(');
            self.members = allfields;
            
            if isempty(self.name)
                % give a name
                existing_names = fieldnames(datasets);
                while true
                    nm = sprintf([class(self) '_%d_%d'], uint64(date2unixsecs()),round(rand(1, 1)*10000));
                    if ~any(strcmp(nm, existing_names))
                        break
                    end
                end
                warning(['atmlab:' mfilename], ...
                    'You didn''t name me! I''ll name myself %s', nm);
                self.name = nm;
            end
        end
        
        %% implementation of abstract methods
        function args = primary_arguments(self)
            args = fieldnames(self.fieldstruct_primary);
            args = args(structfun(@(X) ~isfield(X, 'dataset'), self.fieldstruct_primary));
        end
        
        function args = secondary_arguments(self)
            args = fieldnames(self.fieldstruct_secondary);
            args = args(structfun(@(X) ~isfield(X, 'dataset'), self.fieldstruct_secondary));
        end
        
        function result = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, ~)
            % FIXME DOC

            allnames = fieldnames(self.members);
            n_inprim = length(fieldnames(self.fieldstruct_primary));
            dimsizes = struct();
            % other datasets that may be required (structs filled as needed)
            D = datasets();
            also_read = {struct(), struct()};
            dat_other = {struct(), struct()};
            % will loop through all the names in total 3 times...
            % in the first loop, check if data should be from
            % sibling-datasets, i.e. datasets not occuring in the original
            % collocation, but on the same size (e.g. CPR RO or RVOD)
            for i = 1:length(allnames)
                fieldnam = allnames{i};
                if isfield(self.members.(fieldnam), 'dataset')
                    ds = self.members.(fieldnam).dataset;
                    if i <= n_inprim
                        j = 1;
                    else
                        j = 2;
                    end
                    % add field to read from this DS to
                    % also_read{j}.(dataset_name)
                    if ~isfield(also_read{j}, ds.name)
                        logtext(atmlab('OUT'), ...
                            'Shall read field %s from sibling-dataset %s\n', ...
                            fieldnam, ds.name);
                        also_read{j}.(ds.name) = {fieldnam};
                    else
                        logtext(atmlab('OUT'), ...
                            'Shall also read field %s from sibling-dataset %s\n', ...
                            fieldnam, ds.name);
                        also_read{j}.(ds.name) = [also_read{j}.(ds.name) fieldnam];
                    end
                end
            end
            % read what shall also be read
            for j = 1:2
                if j == 1
                    dt = date1;
                    spc = spec1;
                else
                    dt = date2;
                    spc = spec2;
                end
                dsets_to_read = fieldnames(also_read{j});
                for k = 1:length(dsets_to_read)
                    dsnm = dsets_to_read{k};
                    % read fields from this dataset as indicated by
                    % also_read{j}.(dataset_name)
                    logtext(atmlab('OUT'), ...
                        'Reading dataset %s to grab %d fields\n', ...
                        dsnm, length(also_read{j}.(dsnm)));
                    % in this reading, do not remove doubles, or there will
                    % be a mis-match between indices as provided by the
                    % collocations and indices as determined here
                    dat_other{j}.(dsnm) = D.(dsnm).read_granule(dt, spc, also_read{j}.(dsnm), false, false);
                end
            end
            % read all 
            % in the second loop, check sizes etc.
            for i = 1:length(allnames)
                fieldnam = allnames{i};
                if i<=n_inprim
                    j = 1;
                    dat = data1;
                else
                    dat = data2;
                    j = 2;
                end
                n_scanlines = size(dat.lat, 1);
                n_scanpos = size(dat.lat, 2);
                % data either from prim/sec or from 'sibling'
                if isfield(self.members.(fieldnam), 'dataset')
                    fdata = dat_other{j}.(self.members.(fieldnam).dataset.name).(fieldnam);
                else
                    fdata = dat.(fieldnam);
                end
                % 'n' is the number of measurements per lat/lon, e.g. the
                % number of channels, number of height-bins, etc. Should be
                % scalar...
                n = numel(fdata)/(n_scanlines*n_scanpos);
                assert(iswhole(n), ['atmlab:' mfilename ':dimensions'], ...
                    ['Dimension mismatch: scanlines: %d, scanpos: %d, ' ...
                    'field %s: %s'], n_scanlines, n_scanpos, fieldnam, ...
                    num2str(size(fdata)));
                %% if needed, add dimension info to self.members
                if (n>1)
                    % need to specify dimension in NetCDF, if it doesn't
                    % exist yet, we will need to create the dimension. To
                    % tell the writing routine that it needs to do so, add
                    % a field with a name and a number, but only if this
                    % dimension size is new
                    
                    % iff self.members.(fieldnam).dims is there
                    if ~(isfield(self.members, fieldnam) && ...
                            isfield(self.members.(fieldnam), 'dims'))
                        % find dimension name from dimension size
                        alldimnames = fieldnames(dimsizes);
                        alldimvalues = structfun(@(x)x, dimsizes);
                        if ismember(n, alldimvalues)
                            nm = alldimnames(alldimvalues==n);
                        else
                            nm = sprintf('AUTO_DIM%d_%d', length(alldimvalues)+1, n);
                            dimsizes.(nm) = n;
                        end
                        % store dimension name and size
                        self.members.(fieldnam).dims = {nm, n};
                    end
                    
                end
                    
            end
            
            self.members2cols();
     
            ncollocs = size(processed_core, 1);
            nfields = max(cell2mat(struct2cell(self.cols).'));
            %fields = fieldnames(self.cols);
            result = nan*zeros(ncollocs, nfields); 
            n_inprim = length(fieldnames(self.fieldstruct_primary));
            
            r1 = processed_core(:, self.parent.cols.LINE1);
            r2 = processed_core(:, self.parent.cols.LINE2);
            c1 = processed_core(:, self.parent.cols.POS1);
            c2 = processed_core(:, self.parent.cols.POS2);
            if self.needs_primary_data()
                i1 = sub2ind(size(data1.lat), r1, c1);
            end
            if self.needs_secondary_data()
                i2 = sub2ind(size(data2.lat), r2, c2);
            end
            
            % in the third loop, collect the data

            for i = 1:length(allnames)
                field = allnames{i};
                

                if i <= n_inprim
                    data = data1;
                    ii = i1;
                    j = 1;
                else
                    data = data2;
                    ii = i2;
                    j = 2;
                end
                
                % data either from prim/sec or from 'sibling'
                if isfield(self.members.(field), 'dataset')
                    logtext(atmlab('OUT'), ...
                        'Grabbing field %s from sibling-dataset %s\n', ...
                        field, self.members.(field).dataset.name);
                    fdata = dat_other{j}.(self.members.(field).dataset.name).(field);
                else
                    fdata = data.(field);
                end
                    
                % if this fails, data.(field) may not be a column-vector as
                % required
                sz = size(fdata);
                if isequal(sz, size(data.lat))
                    DD = fdata(:); % 1 point per lat/lon
                else % multi-point per lat/lon
                    DD = reshape(fdata, prod(sz(1:end-1)), sz(end));
                end
                result(:, self.cols.(field)) = DD(ii, :);
                %result(:, self.cols.(field)) = data.(field)(ii, :);
            end
        end
        
        function out = needs_primary_data(self)
            out = ~isempty(fieldnames(self.fieldstruct_primary));
        end
        
        function out = needs_secondary_data(self)
            out = ~isempty(fieldnames(self.fieldstruct_secondary));
        end
        
%         function store(varargin)
%             error(['atmlab:' mfilename ':NotImplemented'], 'Not implemented!');
%         end
    end

end
