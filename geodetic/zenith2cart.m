% ZENITH2CART   Zenith direction in ECEF
%
%   The input latitude can be both geodetic and geocentric.
%
% FORMAT [dx,dy,dz] = zenith2cart(lat,lon)
%
% IN  lat   Latitude(s).
%     lon   Longitude(s).
% OUT dx    x-component of unit vector
%     dy    y-component of unit vector
%     dz    z-component of unit vector

% 2020-09-11   Patrick Eriksson

function [dx,dy,dz] = zenith2cart(lat,lon)

ct = cosd( lat );
dx = ct .* cosd( lon );
dy = ct .* sind( lon );
dz = sind( lat );
