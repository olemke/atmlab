% CART2GEODETIC    converts from geocentric cartesian coordinate 
%                  to a geodetic coordinate    
%
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%   See CART2GEOCENTRIC for a defintion of the geocentric 
%   coordinate system.
%
% FORMAT [h, lat, lon] = cart2geodetic(x,y,z,ellipsoid) 
%
% OUT    h         Geodetic height (height above the reference ellipsoid)
%        lat       Geodetic latitude
%        lon       Geodetic longitude
%
% IN     x    Coordinate in x dimension
%        y    Coordinate in y dimension
%        z    Coordinate in z dimension
% OPT    ellipsoid a row vector with the form [semimajor axis, eccentricity]
%                  specifying the ellipsoid,
%                  the semimajor axis must use the same units as x,y,z 
%        Default is WGS84 reference ellipsoid
%        http://en.wikipedia.org/wiki/World_Geodetic_System 

% History: created by Bengt Rydberg 2011-10-31
function [h, lat, lon] = cart2geodetic(x,y,z,ellipsoid)

if nargin<4
  %WGS84 reference ellipsoid
  f=1/298.257223563;
  e=sqrt(f*(2-f));
  radius= 6378137;
  ellipsoid=[radius e];
end 

[lat,lon,h] = ecef2geodetic(x,y,z,ellipsoid);
lat=rad2deg(lat);
lon=rad2deg(lon);
