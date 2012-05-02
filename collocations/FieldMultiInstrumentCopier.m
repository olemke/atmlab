classdef FieldMultiInstrumentCopier < AssociatedDataset
    % Add others
    %
    % This class is for getting fields from other instruments on the same
    % satellite that do not have the same resolution but do have a 1-to-1
    % relation with the instrument originally used for collocating.
    %
    % This is an abstract class. One implementation is
    % <a href="matlab:help AssociatedPOESPlus">AssociatedPOESPlus</a>.
    %
    % WORK IN PROGRESS
    %
    % FIXME DOC
    
    % $Id$
    
    properties (Abstract)
                
        % For instruments sharing a platform with the primary
        %
        % FIXME DOC
        fieldcopier_other_primary
        
        % For instruments sharing a platform with the secondary
        %
        % FIXME DOC
        fieldcopier_other_secondary

    end
    
    
    properties
        % This is for fields that are copied from the core
        %
        % FIXME DOC
        fieldcopier_core
        
        
        % FIXME DOC
        fieldstruct_other
    end
    
    
    properties (SetAccess = protected)
        %members
        parent
        dependencies
    end
        
    methods (Abstract)
        % FIXME DOC
        [newline, newpos] = translate(self, processed_core, data_orig, dsname, data_other)
    end
    
    methods
        %% constructor
        
         function self = FieldMultiInstrumentCopier(varargin)
             self = self@AssociatedDataset(varargin{:});
         end
%             % Create FieldMultiInstrumentCopier object
%             %
%             d = datasets;
%             self.parent = d.CollocatedDataset_mhs_cpr;
%             self.fieldcopier_mhscpr = FieldCopier(self.parent, f_mhs, f_cpr);
%             self.fieldcopier_other.amsua = FieldCopier(self.parent, f_amsua, struct());
%             self.fieldcopier_other.hirs = FieldCopier(self.parent, f_hirs, struct());
%             
%             self.fieldstruct_mhs = f_mhs;
%             self.fieldstruct_other.amsua = f_amsua;
%             self.fieldstruct_other.hirs = f_hirs;
%         end
        
        %% implementation of abstract methods
        
        function args = primary_arguments(self)
            args = self.fieldcopier_core.primary_arguments();
        end
        
        function args = secondary_arguments(self)
            args = self.fieldcopier_core.secondary_arguments();
        end
        
        function bool = needs_primary_data(self)
            bool = self.fieldcopier_core.needs_primary_data();
        end
        
        function bool = needs_secondary_data(self)
            bool = self.fieldcopier_core.needs_secondary_data();
        end
        
        function out = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies)
            d = datasets;
            
            %% copy fields for original instruments
            
            out_core = self.fieldcopier_core.process_granule(processed_core, data1, date1, spec1, data2, date2, spec2, dependencies);
            allmembers = self.fieldcopier_core.members;
            
            %% get fields for other instruments on primary
            
            % (ab)use a FieldCopier also for other instruments on primary
            % by editing processed_core and putting in the line/pos for the
            % other instruments instead of the original ones
            % the abstract method 'translate' is responsible for actually
            % performing this conversion
            
            modes = {'primary', 'secondary'};

            for k = 1:length(modes)
                m = modes{k};
                
                other_instruments{k} = fieldnames(self.(['fieldcopier_other_' m]));
                out_other{k} = {};
                
                switch m
                    % sometimes it's the primary where other instruments
                    % are considered, sometimes it's the secondary. Prepare
                    % all that's differente here to avoid code-repetition
                    % later.
                    case 'primary'
                        data_orig = data1;
                        date = date1;
                        spec = spec1;
                        line_i = self.parent.cols.LINE1;
                        pos_i = self.parent.cols.POS1;
                        fc_other = self.fieldcopier_other_primary;
                        arg_i_other = 2;
                    case 'secondary'
                        data_orig = data2;
                        date = date2;
                        spec = spec2;
                        line_i = self.parent.cols.LINE2;
                        pos_i = self.parent.cols.POS2;
                        fc_other = self.fieldcopier_other_secondary;
                        arg_i_other = 5;
                    otherwise
                        error('BUG! CRASH! This place ought to be unreachable!');
                end
                
                for i = 1:length(other_instruments{k})
                    other_instrument = other_instruments{k}{i};
                    logtext(atmlab('OUT'), 'Also taking same-satellite instrument %s\n', ...
                        other_instrument);
                    data_other = d.(other_instrument).read_granule(date, spec, {}, false);
                    pc_other = processed_core;
                
                    
                    [other_line, other_pos] = self.translate(processed_core, data_orig, other_instrument, data_other);
                
                    pc_other(:, line_i) = other_line;
                    pc_other(:, pos_i) = other_pos;
       
                    % FieldCopier's process_granule also sets 'cols'-structure
                    args = {pc_other, data1, date1, spec1, data2, spec2, dependencies};
                    args{arg_i_other} = data_other;
                    out_other{k}{i} = fc_other.(other_instrument).process_granule(args{:}); %#ok<AGROW>
                   
                    allmembers = catstruct(allmembers, fc_other.(other_instrument).members);
                end
            end
            % now that all process_granule methods have been called, the
            % sizes on the various 'members' fields should be set
            % appropiately. Since each call had at least one (primary or
            % secondary) in common with the other, via the 'chain' all have
            % also been checked against duplicates through the various
            % FieldCopiers
                   
            % merge matrices and cols-structures appropiately
            out = out_core;
            newcols = self.fieldcopier_core.cols;
            for k = 1:length(modes)
                m = modes{k};
                for i = 1:length(out_other{k})
                    [out, newcols] = self.merge(out, newcols, out_other{k}{i}, self.(['fieldcopier_other_' m]).(other_instruments{k}{i}).cols);
                end
            end
            self.cols = newcols;
            self.members = allmembers;
            
        end
    end
end
