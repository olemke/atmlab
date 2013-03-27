function y = c(x, varargin)
% C function equivalent of curly braces
%
% For a discussion on the thoughts behind this function, see <a
% href="matlab:help p">p</a>.
% C is the equivalent but with curly braces.
%
% FORMAT
%
%   y = c(func(), a, b, ...)
%
% IN
%
%   func()      expression to be indexed or called
%   a, b, ...   index per dimension
%
% OUT
%
%   y           result of indexing operation x{a, b, ...}
%
% By Gerrit Holl, inspired by http://is.gd/b3MkRf
%
% See also: p

% $Id$
y = x{varargin{:}};
end
