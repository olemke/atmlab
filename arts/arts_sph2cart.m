% ARTS_SPH2CART   Converts a spherical position to cartesian coordinates.
%
%    The coordinates systems are defined following ARTS. That is:
% 
%       Latitude range is [-90,90].
%       Longitude range [0,360].
%
%       Line-of-sights (LOS) are specified by zenith and azimuth angles.
%
%       x-axis is along latitude 0 and longitude 0
%       y-axis is along latitude +90
%       z-axis is along latitude 0 and longitude +90
%
% FORMAT   [x,y,z] = arts_sph2cart(r,lat,lon)
%        
% OUT   x    Coordinate in x dimension.
%       y    Coordinate in y dimension.
%       z    Coordinate in z dimension.
% IN    r    Radius.
%       lat  Latitude.
%       lon  Longitude.

% 2007-05-16   Created by Patrick Eriksson.


function [x,y,z] = arts_sph2cart(r,lat,lon)
  
deg2rad = constants( 'DEG2RAD' );

latrad = deg2rad * lat;
lonrad = deg2rad * lon;

x = r .* cos( latrad );   % Common term for x and z
z = x .* sin( lonrad );
x = x .* cos( lonrad );
y = r .* sin( latrad );

