classdef CollocatedDataset < SatDataset
    % Defines a collocated dataset, between two (other) datasets
    properties
        primary;
        secondary;
    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        % associated datasets, e.g. additional data, meandata, etc.
        associated = [];
    end
    
    methods
        function cd = CollocatedDataset(prim, sec, varargin)
            cd = cd@SatDataset(varargin{:}); % call parent constructor
            % check that both are SatDataset
            for x = {prim, sec}
                assert(isa(x{1}, 'SatDataset'), ['atmlab:' mfilename ':TypeError'], ...
                        'Collocations must be between 2 x SatDataset, got %s instead', ...
                        class(x{1}));
                x{1}.AddCollocation(cd);
            end
            cd.primary = prim;
            cd.secondary = sec;
            if isempty(cd.name)
                cd.name = ['collocations_' prim.name '_' sec.name];
            end
        end
    end
end
