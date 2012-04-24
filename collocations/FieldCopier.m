classdef FieldCopier < AssociatedDataset
    % class to copy fields from original datasets to collocated datasets
    % 
    % A common task associated with <a href="matlab:help CollocatedDataset">collocating</a> different <a href="matlab:help SatDataset">dataset</a>s
    % is to copy fields from the original datasets to use with the collocations.
    % FieldCopier implements <a href="matlab:help AssociatedDataset">AssociatedDataset</a>, meaning that it has at
    % least all the properties and methods that are indicated by AssociatedDataset.
    % Therefore, it can be used wherever documentation describes the need
    % for an AssociatedDataset.
    %
    % To copy fields as-is, create an instance of FieldCopier and pass this
    % on to the CollocatedDataset methods <a href="matlab:help CollocatedDataset/collocate_granule">collocate_granule</a>,
    % <a href="matlab:help CollocatedDataset/collocate_date">collocate_date</a>, <a href="matlab:help CollocatedDataset/collocate_and_store_date">collocate_and_store_date</a>, or <a href="matlab:help CollocatedDataset/collocate_and_store_date_range">collocate_and_store_date_range</a>.
    % Fieldnames are taken upon creation from two structures passed on to the
    % constructor: one for the primary, and one for the secondary. The
    % fieldnames of those structures are passed on to the respective
    % <a href="matlab:help SatDataset/reader">reader</a>s, who are expected to return structures with the
    % appropiate data stored in them with the same fieldnames.
    % The values for the fields in the structures passed on to the
    % constructor contain information on how to store the data, among other
    % things. See also the example below.
    %
    % When a FieldCopier is created, it is automatically registered with
    % the <a href="matlab:help CollocatedDataset">CollocatedDataset</a> to which it belongs, in <a href="matlab:help CollocatedDataset/associated">CollocatedDataset.associated</a>.
    % Therefore, only for some tasks involving a FieldCopier, one needs to
    % pass the reference to the method using it. For other tasks, this is
    % taken care of automatically.
    %
    % FieldCopier Properties:
    %
    %   fieldstruct_primary -   Describes what is copied from primary
    %   fieldstruct_secondary - Describes what is copied from secondary
    %  (remaining properties inherited from <a href="matlab:help AssociatedDataset">AssociatedDataset</a>)
    %
    % FieldCopier Methods:
    %
    %   FieldCopier -           Create FieldCopier object
    %  (remaining methods implemented based on <a href="matlab:help AssociatedDataset">AssociatedDataset</a>)
    %
    % Example:
    %
    % % obtain object for <a href="matlab:help CollocatedDataset">CollocatedDataset</a>
    % >> D = <a href="matlab:help datasets">datasets</a>;
    % >> mhscpr = D.CollocatedDataset__1_mhs__2_cpr;
    % % define structures to be passed on when creating FieldCopier
    % % For this to work, the <a href="matlab:help SatDataset">SatDataset</a> in <a href="matlab:help CollocatedDataset/primary">mhscpr.primary</a>
    % % must have a <a href="matlab:help SatDataset/reader">reader</a> that accepts {'tb'} as a second argument,
    % % and then returns a structure containing a field 'tb' with appropriate
    % % data. Similarly, <a href="matlab:help CollocatedDataset/secondary">mhscpr.secondary</a>.reader shall take
    % % {'RO_ice_water_path'} as a second argument and return a structure
    % % with a field 'RO_ice_water_path'.
    % >> fc1 = struct('tb', struct('type', 'float', 'atts', struct('long_name', 'My BT')));
    % >> fc2 = struct('RO_ice_water_path', struct('type', 'int', 'atts', struct('long_name', 'My IWP')));
    % % create FieldCopier object with minimum of information
    % >> fc = FieldCopier(mhscpr, fc1, fc2, 'basedir', '/tmp/testing', ...
    %                     'subdir', '$YEAR4/$MONTH/$DAY', ...
    %                     'filename', 'collocations_$SAT.nc.gz');
    % % Collocate along with FieldCopier
    % >> mhscpr.collocate_and_store_date_range([2009 7 1], [2009 7 5], ...
    %                                          'noaa18', '', {fc});
    %
    % This code now creates two files for each date in the daterange (ten
    % files in total): one for the <a href="matlab:help CollocatedDataset">CollocatedDataset</a>, containing the very
    % core information, and one for the FieldCopier, containing two fields;
    % one copied from the primary <a href="matlab:help SatDataset">dataset</a>, and one copied from the secondary
    % <a href="matlab:help SatDataset">dataset</a>.
    %
    % TODO:
    %  - set some (but not all!!) clever properties for NetCDF
    %
    % See also: AssociatedDataset (abstract superclass), CollocatedDataset, SatDataset, Collapser, datasets
    %
    % $Id$
    
    properties (SetAccess = protected)
        
        % Structure with fields corresponding to primary
        fieldstruct_primary = struct;
        
        % Structure with fields corresponding to secondary
        fieldstruct_secondary = struct;
        
        % Structure with all fields and info on how to store the NetCDF
        %
        % See also <a href="matlab:help AssociatedDataset.members">AssociatedDataset.members</a>
        members = struct(); % set by constructor
        
        % Parent <a href="matlab:help CollocatedDataset">CollocatedDataset</a>.
        %
        % See also <a href="matlab:help AssociatedDataset.parent">AssociatedDataset.parent</a>
        parent = [];
        % FieldCopier has no dependencies
        %
        % See also <a href="matlab:help AssociatedDataset.dependencies">AssociatedDataset.dependencies</a>
        dependencies = {};
    end    
    
    methods
        function self = FieldCopier(cd, fieldstruct1, fieldstruct2, varargin)
            % Creates a FieldCopier object
            %
            % Used to create a <a href="matlab:help FieldCopier">FieldCopier</a> object.
            %
            % FORMAT
            %
            %   cd      CollocatedDataset   <a href="matlab:help CollocatedDataset"> that this FieldCopier belongs to.
            %
            %   fs1     structure
            %
            %       Full definition of fields and information on how to
            %       store. The names of the fields correspond to fields
            %       copies from the primary in a process explained in the
            %       <a href="matlab:help FieldCopier">class documentation</a>. The value for each field is itself
            %       a structure containing information on how to store the
            %       field in the final NetCDF file. This structure can have
            %       the following fields:
            %           
            %           type    string, NetCDF-3 type, such as 'int',
            %                   'float'. Full list <a href="http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/NetCDF_002d3-Variable-Types.html#NetCDF_002d3-Variable-Types">in NetCDF docs</a>.
            %
            %           atts    structure, fields and values are all
            %                   strings and are stored as NetCDF
            %                   attributes. I suggest to use <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html">CF</a>
            %                   conventions.
            %
            %                   NOTE: in the future, attributes not
            %                   provided may possibly be guessed based on
            %                   original data.
            %
            %   fs2     structure
            %
            %       Like fs1, but corresponding to the secondary.
            %
            %   ...remaining arguments passed on to <a href="matlab:help SatDataset">SatDataset</a>,
            %   so those indicate name, where to store, etc. 
            
            self = self@AssociatedDataset(cd, {}, varargin{:}); % call parent constructor
            
            self.fieldstruct_primary = fieldstruct1;
            self.fieldstruct_secondary = fieldstruct2;
            
            
            % check consistence of fieldstructs
            
            allfields = catstruct(fieldstruct1, fieldstruct2);
            assert(length(fieldnames(fieldstruct1))+length(fieldnames(fieldstruct2))==length(fieldnames(allfields)), ...
                    ['atmlab:' mfilename ':duplicates'], 'Duplicate fieldnames between datasets are not permitted, but were found :(');
            self.members = allfields;
            
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
                            nm = alldimnames{alldimvalues==n};
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
