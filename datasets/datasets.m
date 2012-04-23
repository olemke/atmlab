function SS = datasets(varargin)

% list or add dataset
%
% Returns a structure with all known datasets.
%
% When called with an argument, adds a dataset. Warning! The constructor of
% SatDataset takes care of the 'registration', and there should never be a
% need to call this function with any argument directly.
%
% When called with 2 and 1st argument is 'delete', deletes 2nd entry.

% $Id$

persistent S

if isempty(S)
    S = struct();
end

if (nargin==2)
    if (strcmp(varargin{1}, 'delete'))
        S = rmfield(S, varargin{2}.name);
    else
        error(['atmlab:' mfilename ':invalid'], ...
            'Invalid call sig. See help text.');
    end
end

if (nargin==1)
    if isfield(S, varargin{1}.name)
        if S.(varargin{1}.name) == varargin{1}
            warning(['atmlab:' mfilename], ...
                'Dataset with name %s was already defined, equally', ...
                varargin{1}.name);
        else
            error(['atmlab:' mfilename], ...
                'Dataset with name %s already exists and is different', varargin{1}.name);
        end
    end
    S.(varargin{1}.name) = varargin{1};
end

SS = S;

end
