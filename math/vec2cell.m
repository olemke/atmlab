% VEC2CELL   Converts a vector to a cell array
%
%    Copies the elements in avector to a cell. E.g. c{i} = v(i);
%
%    v must be a vector, or be empty.
%
% FORMAT   c = vec2cell(v)
%        
% OUT   c   Created cell array.
% IN    v   A vector

% 2015-08-11  Created by Patrick Eriksson

function c = vec2cell(v)

if isempty(v)
  c = [];
  return
end
  
if ~isvector( v ) 
  error( 'The input variable is not a vector.' );
end

for i = length(v) : -1 : 1
  c{i} = v(i);
end

