% CART2GEODETIC   Cartesian coordinates to geodetic position to 
%
%    Converts Cartesian coordinates to geodetic positions. 
%
%    The WGS-84 reference ellisoid is used. The Cartesian coordinates follow
%    the system used in ARTS.
%
% FORMAT   [h,lat,lon] = geodetic2cart( x,y,z )
%        
% OUT   h     Altitude
%       lat   Geodetic latitude.
%       lon   Longitude.
% IN    x     x coordinate
%       x     y coordinate
%       z     z coordinate

% 2011-09-06   Created by Patrick Eriksson.

function [h,lat,lon] = cart2geodetic( x, y, z )

% The algorith is taken from the Odin processing chain, see
% http://svn.rss.chalmers.se/projects/odinsmr/browser/oops/trunk/Library/geodetic.c
  
% These lines to handle difference in Cartesian system:
dummy = z;
z     = y;
y     = dummy;

a = 6378140.0;
f = 1.0/298.257;

lon = atan2( y, x );
if lon < 0.0
  lon = lon + 2.0*pi;
end

r  = sqrt( x*x + y*y );
e2 = 2*f-f*f;
b  = atan( z/r );
 	  
old = 0.0;
% 	  
while abs(b-old) > 1e-6
  old = b;
  C   = 1.0 / sqrt( 1 - e2*sin(b)^2 );
  b   = atan( (z+a*C*e2*sin(b))/r );
end

lat = b;
h = r/cos(b) - a*C;

lat = 180/pi * lat;
lon = 180/pi * lon;