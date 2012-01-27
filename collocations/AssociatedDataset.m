classdef AssociatedDataset < SatDataset
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
    
    properties (SetAccess = protected)
        dependencies;
        parent;
        % this is split in primary and secondary because from these
        % structures is also derived what arguments to pass on to the
        % respective reading routines
        fieldstruct_primary = struct;
        fieldstruct_secondary = struct;
        cols;
    end
    
    methods
        function self = AssociatedDataset(cd, dependencies, varargin)
            % cd: CollocatedDataset it belongs to
            % dependencies: AssociatedDatasets to be processed first
            % rest of arguments passed on to SatDataset
            self = self@SatDataset(varargin{:}); % call parent constructor
            self.parent = cd;
            self.dependencies = dependencies;
            cd.add_associated(self);
        end
        
        function out = process_day(varargin)
            % FIXME DOC
            % FIXME TODO:
            % for a full day granule, split into individual granules, read
            % data for each granule, get collocations for this granule,
            % and pass to self.process(...)
            out = []; % not implemented yet!
        end
    end
    
    % those methods must be implemented by subclasses
    methods (Abstract)
        args = primary_arguments(self)
        args = secondary_arguments(self)

        out = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies)
        store(self, date, spec, result)
    end
    
end
