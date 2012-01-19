classdef SatDataset < handle % subclass from handle to pass-by-reference
    % Class to represent a dataset
    %
    % Work in progress!
    %
    % $Id$
    
    % read/write props
    properties
        name;
        basedir;
        subdir;
        regexp;
        filename;
        reader = @(p)[];
        granule_duration;
    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        collocated_datasets = [];
    end
    
    methods
        
        %% constructor
        
        function ds = SatDataset(varargin)
            % Creates SatDataset object
            %
            % properties can be set upon constructing as when calling
            % 'struct'
            for i = 1:2:nargin
                ds.(varargin{i}) = varargin{i+1};
            end
        end
                
        %% methods for internal use (not private, but from other classes)
       
        function add_collocated_dataset(ds, cd)
            % INTERNAL USE. Adds a collocated dataset.
            %
            % This is called by the CollocatedDataset constructor.
            ds.collocated_datasets = [ds.collocated_datasets cd];
        end
    end
end
