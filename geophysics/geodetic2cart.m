% GEODETIC2CART    converts from geodetic coordinate 
%                  to a geocentric cartesian position    
%
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%   See CART2GEOCENTRIC for a defintion of the geocentric 
%   coordinate system.
%
% FORMAT [x, y, z] = geodetic2cart(h,lat,lon,ellipsoid)
% 
% OUT    x    Coordinate in x dimension
%        y    Coordinate in y dimension
%        z    Coordinate in z dimension
%
% IN     h         Geodetic height (height above the reference ellipsoid)
%        lat       Geodetic latitude
%        lon       Geodetic longitude
% OPT    ellipsoid a row vector with the form [semimajor axis, eccentricity]
%                  specifying the ellipsoid,
%                  the semimajor axis must use the same units as h  
%        Default is WGS84 reference ellipsoid
%        http://en.wikipedia.org/wiki/World_Geodetic_System 

% History: created by Bengt Rydberg 2011-10-31
function [x, y, z] = geodetic2cart(h,lat,lon,ellipsoid)

if nargin<4
  %WGS84 reference ellipsoid
  f=1/298.257223563;
  e=sqrt(f*(2-f));
  radius= 6378137;
  ellipsoid=[radius e];
end 

a  = ellipsoid(1);
e2 = ellipsoid(2) ^ 2;
sinphi = sind(lat);
cosphi = cosd(lat);
N  = a ./ sqrt(1 - e2 * sinphi.^2);
x = (N + h) .* cosphi .* cosd(lon);
y = (N + h) .* cosphi .* sind(lon);
z = (N*(1 - e2) + h) .* sinphi;

