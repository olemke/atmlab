% GEODETIC2CART   Geodetic position to Cartesian coordinates
%
%    Converts geodetic positions to Cartesian coordinates. 
%
%    The WGS-84 reference ellisoid is used. The Cartesian coordinates follow
%    the system used in ARTS.
%
% FORMAT   [x,y,z] = geodetic2cart( h, lat, lon )
%        
% OUT   x     x coordinate
%       x     y coordinate
%       z     z coordinate
% IN    h     Altitude
%       lat   Geodetic latitude.
%       lon   Longitude.

% 2011-09-06   Created by Patrick Eriksson.

function [x,y,z] = geodetic2cart( h, lat, lon )
  
% Data and equations from http://en.wikipedia.org/wiki/Reference_ellipsoid

% WGS-84 radii
a = 6378137;
b = 6356752.3142;


alpha = acos( b/a );

N = a ./ sqrt(1-(sind(lat)*sin(alpha)).^2);

x = (N+h) * cosd(lat) .* cosd(lon);
z = (N+h) * cosd(lat) .* sind(lon);
y = (cos(alpha)^2*N+h) .* sind(lat);

