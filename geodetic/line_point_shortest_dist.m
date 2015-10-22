% LINE_POINT_SHORTEST_DIST  Shortest distance from a point to a line
%
%    The algorithm is based on the "Vector formulation" section of the
%    follwoing Wikipedia page:
%    https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
%
%    All input data must be column vectors, all having the same length. Any
%    dimension is handled.
%
% FORMAT   [d,clp,l2clp] = line_point_shortest_dist(a,n,p)
%
% OUT   d      The minimum distance
%       clp    Corrdinates of the closest point.
%       l2clp  Length from a to the closest point
% IN    a      A point on the line.
%       n      A unit vector along the line.
%       p      The point of concern.

% 2015-10-22 Patrick Eriksson

function [d,clp,l2clp] = line_point_shortest_dist(a,n,p)

% Check input
%
if ~istensor1(a) | ~istensor1(n) | ~istensor1(p)
  error( 'All input arguments must be column vectors.' );
end
if length(a) ~= length(n)  |  length(a) ~= length(p)
  error( 'All input vectors must have the same length.' );
end
if abs(norm(n)-1) > 1e-12
  error( 'Argument *n* must be a vector with norm = 1.' );
end
 

% Vector from p to a
%
pa = a - p;


% Unit vector from closest point to a
%
nca = dot( pa, n ) * n;


% Vector from p to closest point
%
pc = pa - nca;


% the smallest distance
%
d = norm( pc );


if nargout > 1
  % Closest point 
  clp = p + pc;
  
  % Length from a
  l2clp = norm( clp - a );
end
