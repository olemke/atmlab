% ATMPLOT_GRIDCELL2D   2D grid cell plot.
%
%    The function plots a 2D grid cell. The radius of each corner point is
%    given and the radius is assumed to vary linear as a function of latitude.
%    The vertical surfaces are plotted with linear segments in steps of 
%    0.5 degrees latitude. See *atmplot_pol2cart* for coordinate system used.
%
%    The function does not change the hold status of the plot.
%
%    If no ground radius is given, the ground will not be included in the plot.
%
% FORMAT   atmplot_gridcell2D(lat1,lat3,r1,r2,r3,r4,rground1,rground2)
%        
% IN    lat1       Latitude of left end face of the grid cell
%	lat3       Latitude of right end face of the grid cell
%       r1         Radius of lower-left corner of the grid cell
%       r2         Radius of lower-right corner of the grid cell.
%	r3         Radius of upper-right corner of the grid cell.
%       r4         Radius of upper-left corner of the grid cell.
% OPT   rground1   Radius for the ground at *lat1*. Default is [].
%       rground2   Radius for the ground at *lat3*. Default is [].

% 2002-12-21   Created by Patrick Eriksson.


function atmplot_gridcell2D(lat1,lat3,r1,r2,r3,r4,rground1,rground2)


%= Input
%
min_nargin( 6, nargin );
%
if nargin < 7
  rground1 = [];
  rground2 = [];
else
  min_nargin( 8, nargin );
end


holdst = ishold;


%= Plot latitude faces
%
atmplot_pol2cart( [r1 r4], [lat1 lat1], 'k:' );
hold on;
atmplot_pol2cart( [r2 r3], [lat3 lat3], 'k:' );



%= Plot pressure surfaces
%
dlat = 0.5;    % Latitude distance for each plot line segment
%
n = ceil( ( lat3 - lat1 ) / dlat );
lats = linspace( lat1, lat3, n );
%
c2 = ( r2 - r1 ) / ( lat3 - lat1 );
c4 = ( r3 - r4 ) / ( lat3 - lat1 );
%
r = r1 + c2 * ( lats - lat1 );
atmplot_pol2cart( r, lats, 'k:' );
%
r = r4 + c4 * ( lats - lat1 );
atmplot_pol2cart( r, lats, 'k:' );



%= Plot the ground
%
if ~isempty( rground1 )

  c = ( rground2 - rground1 ) / ( lat3 - lat1 );
  r = rground1 + c * ( lats - lat1 );
  atmplot_pol2cart( r, lats, 'r-', 'LineWidth', 2 );

end



if ~holdst
  hold off
end