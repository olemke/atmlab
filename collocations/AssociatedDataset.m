classdef AssociatedDataset < SatDataset
    % Defined data associated with CollocatedDataset
    %
    % Work in progress!
    %
    % $Id$
    properties (SetAccess = protected)
        parent;
    end
    
    methods
        function ad = AssociatedDataset(cd, varargin)
            ad = ad@SatDataset(varargin{:}); % call parent constructor
            ad.parent = cd;
        end
    end
end
