% ATMPLOT_GRIDCELL3D   3D grid cell plot.
%
%    The function plots a 3D grid cell. The radius of each corner point is
%    given and the radius is assumed to vary linear from corner to corner.
%    See *atmplot_sph2cart* for coordinate system used.
%
%    The function does not change the hold status of the plot.
%
%    If no ground radius is given, the ground will not be included in the plot.
%
%    The naming of input arguments is taken from ARTS (see the suer guide).
%
% FORMAT   atmplot_gridcell3D(lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,
%                                        r1b,r2b,r3b,r4b[,rg1a,rg2a,rg1b,rg2b])
%        
% IN    lat1   Lower latitude.
%       lat3   Upper latitude.
%       lon5   Lower longitude.
%       lon6   Upper latitude.
%       r1a    Radius of the lower pressure surface at *lat1* and *lon5*.
%       r2a    Radius of the lower pressure surface at *lat3* and *lon5*.
%       r3a    Radius of the upper pressure surface at *lat3* and *lon5*.
%       r4a    Radius of the upper pressure surface at *lat1* and *lon5*.
%       r1b    Radius of the lower pressure surface at *lat1* and *lon6*.
%       r2b    Radius of the lower pressure surface at *lat3* and *lon6*.
%       r3b    Radius of the upper pressure surface at *lat3* and *lon6*.
%       r4b    Radius of the upper pressure surface at *lat1* and *lon6*.
% OPT   rg1a   Radius of the ground at *lat1* and *lon5*.
%       rg2a   Radius of the ground at *lat3* and *lon5*.
%       rg1b   Radius of the ground at *lat1* and *lon6*.
%       rg2b   Radius of the ground at *lat3* and *lon6*.

% 2002-12-21   Created by Patrick Eriksson.


function atmplot_gridcell3D(lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,rg1a,rg2a,rg1b,rg2b)


%= Input
%
min_nargin( 12, nargin );
%
if nargin < 13
  rg1a = [];
  rg2a = [];
  rg1b = [];
  rg2b = [];
else
  min_nargin( 16, nargin );
end


holdst = ishold;


%= Plot latitude and longitude faces
%
atmplot_sph2cart( [r1a r4a], [lat1 lat1], [lon5 lon5], 'k:' );
hold on;
atmplot_sph2cart( [r2a r3a], [lat3 lat3], [lon5 lon5], 'k:' );
atmplot_sph2cart( [r1b r4b], [lat1 lat1], [lon6 lon6], 'k:' );
atmplot_sph2cart( [r2a r3a], [lat3 lat3], [lon6 lon6], 'k:' );



%= Plot pressure surfaces
%
dlat = 0.5;    % Latitude distance for each plot line segment
%
n = ceil( ( lat3 - lat1 ) / dlat );
lats = linspace( lat1, lat3, n );
%
n = ceil( ( lon6 - lon5 ) / dlat );
lons = linspace( lon5, lon6, n );
%
%- Along lon5: 
c2 = ( r2a - r1a ) / ( lat3 - lat1 );
c4 = ( r3a - r4a ) / ( lat3 - lat1 );
r = r1a + c2 * ( lats - lat1 );
atmplot_sph2cart( r, lats, lon5, 'k:' );
r = r4a + c4 * ( lats - lat1 );
atmplot_sph2cart( r, lats, lon5, 'k:' );
%
%- Along lon6: 
c2 = ( r2b - r1b ) / ( lat3 - lat1 );
c4 = ( r3b - r4b ) / ( lat3 - lat1 );
r = r1b + c2 * ( lats - lat1 );
atmplot_sph2cart( r, lats, lon6, 'k:' );
r = r4b + c4 * ( lats - lat1 );
atmplot_sph2cart( r, lats, lon6, 'k:' );
%
%- Along lat1
c2 = ( r1b - r1a ) / ( lon6 - lon5 );
c4 = ( r4b - r4a ) / ( lon6 - lon5 );
r = r1a + c2 * ( lons - lon5 );
atmplot_sph2cart( r, lat1, lons, 'k:' );
r = r4a + c4 * ( lons - lon5 );
atmplot_sph2cart( r, lat1, lons, 'k:' );
%
%- Along lat3
c2 = ( r2b - r2a ) / ( lon6 - lon5 );
c4 = ( r3b - r3a ) / ( lon6 - lon5 );
r = r2a + c2 * ( lons - lon5 );
atmplot_sph2cart( r, lat3, lons, 'k:' );
r = r3a + c4 * ( lons - lon5 );
atmplot_sph2cart( r, lat3, lons, 'k:' );



%= Plot the ground
%
if ~isempty( rg1a )

  %- Along lon5: 
  c = ( rg2a - rg1a ) / ( lat3 - lat1 );
  r = rg1a + c * ( lats - lat1 );
  atmplot_sph2cart( r, lats, lon5, 'r-', 'LineWidth', 2 );
  %
  %- Along lon6: 
  c = ( rg2b - rg1b ) / ( lat3 - lat1 );
  r = rg1b + c * ( lats - lat1 );
  atmplot_sph2cart( r, lats, lon6, 'r-', 'LineWidth', 2 );
  %
  %- Along lat1
  c = ( rg1b - rg1a ) / ( lon6 - lon5 );
  r = rg1a + c * ( lons - lon5 );
  atmplot_sph2cart( r, lat1, lons, 'r-', 'LineWidth', 2 );
  %
  %- Along lat3
  c = ( rg2b - rg2a ) / ( lon6 - lon5 );
  r = rg2a + c * ( lons - lon5 );
  atmplot_sph2cart( r, lat3, lons, 'r-', 'LineWidth', 2 );

end



if ~holdst
  hold off
end