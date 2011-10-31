% GEOCENTRIC2CART   converts from spherical coordinate 
%                   to a cartesian position    
%
% See CART2GEOCENTRIC for a defintion of the geocentric 
% coordinate system
% 
% FORMAT  [x,y,z]=geocentric2cart(r,lat,lon) 
%
% OUT     x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%
% IN      r    Radius 
%         lat  Latitude
%         lon  Longitude

% History: created by Bengt Rydberg 2011-10-31

function [x,y,z]=geocentric2cart(r,lat,lon)

lon=deg2rad(lon);
lat=deg2rad(lat);
[x,y,z] = sph2cart(lon,lat,r);

