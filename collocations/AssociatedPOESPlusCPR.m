classdef AssociatedPOESPlusCPR < FieldMultiInstrumentCopier
    % Add AMSU-A, HIRS to MHS-CPR
    %
    % WORK IN PROGRESS!
    
    % $Id$
    
    properties
                
        % For instruments sharing a platform with the primary
        %
        % FIXME DOC
        fieldcopier_other_primary = struct();
        
        % For instruments sharing a platform with the secondary
        %
        % FIXME DOC
        fieldcopier_other_secondary = struct();
    end
    
    methods
        %% constructor
        
        function self = AssociatedPOESPlusCPR(f_mhs, f_amsua, f_hirs, f_cpr, varargin)
            % Create AssociatedPoesPlusCPR object
            %
            % IN
            %
            %   f_mhs       struct      fields from MHS
            %   f_amsua     struct      fields from AMSUA
            %   f_hirs      struct      fields from HIRS
            %   f_cpr       struct      fields from CPR
            %
            % FIXME DOC
            d = datasets;
            self = self@FieldMultiInstrumentCopier(d.CollocatedDataset_mhs_cpr, {}, varargin{:});
            
            self.parent = d.CollocatedDataset_mhs_cpr;
            self.fieldcopier_core = FieldCopier(self.parent, f_mhs, f_cpr, 'name', [self.name '_sub_mhs_cpr'], 'visible', false);
            self.fieldcopier_other_primary.amsua = FieldCopier(self.parent, f_amsua, struct(), 'name', [self.name '_sub_amsua'], 'visible', false);
            self.fieldcopier_other_primary.hirs = FieldCopier(self.parent, f_hirs, struct(), 'name', [self.name '_sub_hirs'], 'visible', false);

            self.members = catstruct(self.fieldcopier_core.members, ...
                self.fieldcopier_other_primary.amsua.members, ...
                self.fieldcopier_other_primary.hirs.members);
            
            if length(fieldnames(self.members)) < (...
                    length(fieldnames(self.fieldcopier_other_primary.amsua.members)) + ...
                    length(fieldnames(self.fieldcopier_other_primary.hirs.members)) + ...
                    length(fieldnames(self.fieldcopier_core.members)))
                error(['amtlab:' mfilename], 'Duplicate fieldnames found!');
            end
            
            %            self.fieldstruct_mhs = f_mhs;
%            self.fieldstruct_amsua = f_amsua;
%            self.fieldstruct_hirs = f_hirs;
        end
        
        %% implementation of abstract methods
                
        function [newline, newpos] = translate(self, processed_core, data_orig, dsname, data_other)
                        
            origline = processed_core(:, self.parent.cols.LINE1);
            origpos = processed_core(:, self.parent.cols.POS1);

            switch dsname
                case 'amsua'
                    [aah aaw] = size(data_other.lon);
                    newline = min(max(round(origline/3), 1), aah);            
                    newpos = min(max(round(origpos/3), 1), aaw);
                case 'hirs'
                    newline = arrayfun(...
                        @(v) self.mini(abs(data_other.time-v)), ...
                        data_orig.time(origline));
                    newpos = arrayfun(...
                        @(i) self.mini(...
                        (data_other.lat(newline(i), :)-processed_core(i, self.parent.cols.LAT2)).^2 + ...
                        (data_other.lon(newline(i), :)-processed_core(i, self.parent.cols.LON2)).^2 ...
                        ), 1:size(processed_core, 1));
                otherwise
                    error(['atmlab:' mfilename ':sorry'], ...
                        'I don''t know what to do with %s', dsname);
            end

        end
        
    end
    
    methods (Static, Access = private)
        function i = mini(v)
            % mini return index for minimum of v (arrayfun wants 1 output)
            [~, i] = min(v);
        end
    end

end
