% GRID2EDGES   Estimates grid edges for a set of grid points.
%
%    Between defined grid points, the edge is defined as the middle point. 
%    End edges are set based on the distance between the two closest points.
%
% FORMAT   e = edges2grid(g)
%        
% OUT   e   Edges of grid ranges.
% IN    g   Grid points.

% 2006-03-27   Created by Patrick Eriksson.

function e = edges2grid(g)

e = [g(1)-(g(2)-g(1))/2 edges2grid(g) g(end)+(g(end)-g(end-1))/2 ];

