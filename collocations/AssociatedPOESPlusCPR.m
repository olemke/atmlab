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
            self.fieldcopier_core = FieldCopier(self.parent, f_mhs, f_cpr, 'name', [self.name '_sub_mhs_cpr']);
            self.fieldcopier_other_primary.amsua = FieldCopier(self.parent, f_amsua, struct(), 'name', [self.name '_sub_amsua']);
            self.fieldcopier_other_primary.hirs = FieldCopier(self.parent, f_hirs, struct(), 'name', [self.name '_sub_hirs']);

            %            self.fieldstruct_mhs = f_mhs;
%            self.fieldstruct_amsua = f_amsua;
%            self.fieldstruct_hirs = f_hirs;
        end
        
        %% implementation of abstract methods
        
%         function args = primary_arguments(self)
%             args = self.fieldcopier.primary_arguments();
%         end
%         
%         function args = secondary_arguments(self)
%             args = self.fieldcopier.secondary_arguments();
%         end
%         
%         function bool = needs_primary_data(self)
%             bool = self.fieldcopier.needs_primary_data();
%         end
%         
%         function bool = needs_secondary_data(self)
%             bool = self.fieldcopier.needs_secondary_data();
%         end
%         
%         function out = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies)
%             d = datasets;
%             
%             %% copy fields for MHS and CPR
%             
%             out_mhs_cpr = self.fieldcopier_mhs_cpr.process_granule(processed_core, data1, date1, spec1, data2, date2, spec2, dependencies);
%             
%             %% get fields for AMSU-A and HIRS
%             
%             % (ab)use a FieldCopier also for AMSU-A and HIRS by editing
%             % processed_core and putting in the AMSUA line/pos instead of
%             % the MHS ones.
%             
%             pc_amsua = processed_core;
%             pc_hirs = processed_core;
%             
%             data_amsua = d.amsua.read_granule(date1, spec1);
%             data_hirs = d.hirs.read_granule(date1, spec1);
%             
%             [aah aaw] = size(data_amsua.lon); % amsu-a width, amsu-a height
%             
%             mhs_line = processed_core(:, self.parent.LINE1);
%             mhs_pos = processed_core(:, self.parent.POS1);
%             
%             amsua_line = min(max(round(mhs_line/3), 1), aah);
%             amsua_pos = min(max(round(mhs_pos/3), 1), aaw);
%             
%             pc_amsua(:, self.parent.LINE1) = amsua_line;
%             pc_amsua(:, self.parent.POS1) = amsua_pos;
%             
%             out_amsua = self.fieldcopier_amsua.process_granule(pc_amsua, data_amsua, date1, spec1, data2, date2, spec2, dependencies);
%                 
%             % TODO: optimise this bit of code
%             % find hirs scanline (row) closest in time for each mhs scanline
% 
%             hirs_line =  arrayfun(...
%                     @(v) mini(abs(hirs.time-v)), ...
%                     data_mhs.time(mhs_line));
%             % find hirs pixel (col) in scanline closest in distance to CPR-point
%             hirs_pos = arrayfun(...
%                 @(i) mini(...
%                 (hirs.lat(hirs_line(i), :)-processed_core(i, self.parent.LAT2)).^2 + ...
%                 (hirs.lon(hirs_line(i), :)-processed_core(i, self.parent.LON2)).^2 ...
%                 ), 1:size(processed_core, 1));
%             
%             pc_hirs(:, self.parent.LINE1) = hirs_line;
%             pc_hirs(:, self.parent.POS1) = hirs_pos;
%             
%             out_hirs = self.fieldcopier_hirs.process_granule(pc_hirs, data_hirs, date1, spec1, data2, date2, spec2, dependencies);
%             
%             out = self.merge(out_mhs_cpr, out_amsua);
%             out = self.merge(out, out_hirs);
%         end
        
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
