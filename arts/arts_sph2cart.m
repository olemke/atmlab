% ARTS_SPH2CART   Conversion to ARTS cartesian coordinates.
%
%    Follows the ARTS definition on the the cartesian coordinate system.
%    Input format as the Matlab function *sph2cart*.
%
% FORMAT   [x,y,z] = function arts_sph2cart(r,lat,lon)
%        
% OUT   x     x position.
%       y     y position.
%       z     z position.
% IN    r     Radius.
%       lat   Latitude.
%       lon   Longitude.

% 2002-12-27   Created by Patrick Eriksson.


function [x,y,z] = function arts_sph2cart(r,lat,lon)


DEG2RAD = constants( 'DEG2RAD' );


%- Note the order of arguments
%
[ x, z, y ] = sph2cart( DEG2RAD * lon, DEG2RAD * lat, r );
