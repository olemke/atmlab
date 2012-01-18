classdef SatDataset < handle
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
    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        collocations = [];
    end
    
    methods
        function ds = SatDataset(varargin)
            % Creates SatDataset object
            %
            % properties can be set upon constructing as when calling
            % 'struct'
            for i = 1:2:nargin
                ds.(varargin{i}) = varargin{i+1};
            end
        end
       
        function AddCollocation(ds, cd)
            % INTERNAL USE. Adds a collocated dataset.
            %
            % This is called by the CollocatedDataset constructor.
            ds.collocations = [ds.collocations cd];
        end
    end
end
