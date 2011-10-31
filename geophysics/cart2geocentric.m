% CART2GEOCENTRIC   converts a cartesian position   
%                   to spherical coordinate 
%
%   The geocentric Cartesian coordinate system is fixed with respect to the
%   Earth, with its origin at the center of the ellipsoid and its X-, Y-,
%   and Z-axes intersecting the surface at the following points:
% 
%                 lat   lon
%       X-axis:    0     0      (Equator at the Prime Meridian)
%       Y-axis:    0    90      (Equator at 90-degrees East)
%       Z-axis:   90     0      (North Pole)
% 
%    A common synonym is Earth-Centered, Earth-Fixed coordinates, or ECEF.
% 
% FORMAT  [r,lat,lon]=cart2geocentric(x,y,z) 
%
% OUT     r    Radius 
%         lat  Latitude
%         lon  Longitude
% IN      x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension

% History: created by Bengt Rydberg 2011-10-31

function [r,lat,lon]=cart2geocentric(x,y,z)

[lon,lat,r] = cart2sph(x,y,z);
lon=rad2deg(lon);
lat=rad2deg(lat);


