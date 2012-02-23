classdef MeanDataset < ReducedDataset
    methods
        function self = MeanDataset(varargin)
            self = self@ReducedDataset(varargin{:});
        end
    end
end
