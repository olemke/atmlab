classdef ReducedDataset < AssociatedDataset
    % for AssociatedDataset with less datapoints, e.g. mean or subselection
    
    % $Id$
        methods
        function self = ReducedDataset(varargin)
            self = self@AssociatedDataset(varargin{:});
        end
    end
end
