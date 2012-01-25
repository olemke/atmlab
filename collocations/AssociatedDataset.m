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
        parent;
        % this is split in primary and secondary because from these
        % structures is also derived what arguments to pass on to the
        % respective reading routines
        fieldstruct_primary = struct;
        fieldstruct_secondary = struct;
    end
    
    methods
        function self = AssociatedDataset(cd, varargin)
            self = self@SatDataset(varargin{:}); % call parent constructor
            self.parent = cd;
            cd.add_associated(self);
        end
    end
    
    % those methods must be implemented by subclasses
    methods (Abstract)
        args = primary_arguments(self)
        args = secondary_arguments(self)
        % FIXME: arguments to processing
        out = process(self, varargin)
        
        % for sorting, dependencies, etc.
        out = lt(self, other)
        out = gt(self, other)
        out = eq(self, other)
    end
    
end
