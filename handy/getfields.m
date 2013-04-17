function S = getfields(S, varargin)
%% getfields Get multiple fields from structure
%
% This is like getfield, but accepts multiple fieldnames.
%
% IN
%
%   S       structure
%   fields  Fields to be returned
%
% OUT
%
%   S       new structure

% $Id$

S = cell2struct(cellfun(@(field) S.(field), varargin, 'UniformOutput', false), ...
                varargin, ...
                2);

end
