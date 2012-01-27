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
    % >> f = FieldCopier(col, struct('RO_ice_water_content', '', 'RO_liq_water_content', ''), struct());
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
    
    properties
        cols1;
        cols2;
    end
    
    methods
        function self = FieldCopier(cd, fieldstruct1, fieldstruct2, varargin)
            % cd            CollocatedDataset
            % fieldstruct1  defines names and how to store, from primary
            % fieldstruct2  the same, from secondary
            % remaining arguments passed on to SatDataset
            %
            % need to know:
            % - additional arguments to reader primary
            % - additional arguments to reader secondary
            self = self@AssociatedDataset(cd, {}, varargin{:}); % call parent constructor
            
            self.fieldstruct_primary = fieldstruct1;
            self.fieldstruct_secondary = fieldstruct2;
            
            
            % check consistunce of fieldstructs
            
            allfields = catstruct(fieldstruct1, fieldstruct2);
            assert(length(fieldnames(fieldstruct1))+length(fieldnames(fieldstruct2))==length(fieldnames(allfields)), ...
                    ['atmlab:' mfilename ':duplicates'], 'Duplicate fieldnames between datasets are not permitted, but were found :(');
           

        end
        
        %% implementation of abstract methods
        function args = primary_arguments(self)
            args = fieldnames(self.fieldstruct_primary);
        end
        
        function args = secondary_arguments(self)
            args = fieldnames(self.fieldstruct_secondary);
        end
        
        function result = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies)
            % FIXME DOC
                         
            n_scanlines = size(data1.lat, 1);
            n_scanpos = size(data1.lat, 2);

            %% make 'cols' structs, fix field structs
            % if self.cols is not yet initialised, do this now. This is not
            % done in constructor because only when I see the data I know
            % the sizes to allocate for each field
            % split in primary/secondary, in order to know from what
            % data-structure to obtain the different fields. This only
            % works because there is only copying going on, e.g. no
            % processing that may depend on both data-inputs.
            
            cc1 = struct; % cols corresponding to primary data
            cc2 = struct; % cols corresponding to secondary data
            allfields = catstruct(self.fieldstruct_primary, self.fieldstruct_secondary);
            allnames = fieldnames(allfields);
            n_inprim = length(fieldnames(self.fieldstruct_primary));
            total = 0;
            for i = 1:length(allnames)
                fieldnam = allnames{i};
                %fieldval = allfields.(fieldnam);
                %c.(fieldnam) = (total+1):(total+n);
                if i<=n_inprim
                    dat = data1;
                else
                    dat = data2;
                end
                n = numel(dat.(fieldnam))/(n_scanlines*n_scanpos);
                assert(iswhole(n), ['atmlab:' mfilename ':dimensions'], ...
                    ['Dimension mismatch: scanlines: %d, scanpos: %d, ' ...
                    'field %s: %s'], n_scanlines, n_scanpos, fieldnam, ...
                    num2str(size(dat.(fieldnam))));
                c.(fieldnam) = (total+1):(total+n);
                total = total + n;
                if i<=n_inprim
                    cc1.(fieldnam) = c.(fieldnam);
                else
                    cc2.(fieldnam) = c.(fieldnam);
                end
            end
            % store this information for our offspring
            self.cols = c;
            self.cols1 = cc1;
            self.cols2 = cc2;

     
            ncollocs = size(processed_core, 1);
            nfields = max(cell2mat(struct2cell(self.cols).'));
            %fields = fieldnames(self.cols);
            result = nan*zeros(ncollocs, nfields); 
            n_inprim = length(fieldnames(self.fieldstruct_primary));
            
            r1 = processed_core(:, self.parent.cols.LINE1);
            r2 = processed_core(:, self.parent.cols.LINE2);
            c1 = processed_core(:, self.parent.cols.POS1);
            c2 = processed_core(:, self.parent.cols.POS2);
            i1 = sub2ind(size(data1.lat), r1, c1);
            i2 = sub2ind(size(data2.lat), r2, c2);

            for i = 1:length(allnames)
                field = allnames{i};
                
                if i <= n_inprim
                    data = data1;
                    ii = i1;
                else
                    data = data2;
                    ii = i2;
                end
                
                result(:, self.cols.(field)) = data.(field)(ii, :);
            end
        end
    end

end
