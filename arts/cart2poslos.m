% CART2POSLOS   Converts cartesian position and LOS to spherical coordinates.
%
%    The inverse of *poslos2cart*.
%
% FORMAT   [r,lat,lon,za,aa] = cart2poslos(x,y,z,dx,dy,dz)
%        
% OUT   r     Radius of observation position.
%       lat   Latitude of observation position.
%       lon   Longitude of observation position
%       za    LOS zenith angle at observation position.
%       aa    LOS azimuth angle at observation position.
% IN    x     x-coordinate of observation position.
%       y     y-coordinate of observation position.
%       z     z-coordinate of observation position.
%       dx    x-part of LOS unit vector.
%       dy    y-part of LOS unit vector.
%       dz    z-part of LOS unit vector.

% 2002-12-27   Created by Patrick Eriksson.


function [r,lat,lon,za,aa] = cart2poslos(x,y,z,dx,dy,dz)


%= Input
%
min_nargin( 6, nargin );


RAD2DEG = constants( 'RAD2DEG' );


%= Spherical coordinates
%
r   = sqrt( x*x + y*y + z*z );
lat = RAD2DEG * asin( y / r );
lon = RAD2DEG * atan2( z, x );


za=0;
aa=0;