% CART2POSLOS   Converts cartesian position and LOS to spherical coordinates.
%
%    The inverse of *poslos2cart*.
%
%    The azimuth angle is set to 0 when the zenith angle is 0 or 180.
%    The longitude is set to 0 at the poles (lat = +- 90).
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


DEG2RAD = constants( 'DEG2RAD' );
RAD2DEG = constants( 'RAD2DEG' );


%= Spherical coordinates
%
r   = sqrt( x*x + y*y + z*z );
lat = RAD2DEG * asin( y / r );
lon = RAD2DEG * atan2( z, x ); % Check if atan2 works for (0,0)


%= Normalise dx, dy and dz
%
l  = sqrt( dx*dx + dy*dy + dz*dz );
if l ~= 1
  dx = dx / l;
  dy = dy / l;
  dz = dz / l;
end


%= Spherical derivatives
%
coslat = cos( DEG2RAD * lat );
sinlat = sin( DEG2RAD * lat );
coslon = cos( DEG2RAD * lon );
sinlon = sin( DEG2RAD * lon );
%
dr   =    coslat*coslon * dx + sinlat   * dy + coslat*sinlon   * dz;
dlat = -sinlat*coslon/r * dx + coslat/r * dy - sinlat*sinlon/r * dz;
dlon = -sinlon/coslat/r * dx +               + coslon/coslat/r * dz;



%= LOS angles
%
za = acos( dr );

if za < 1e-6  |  za > 180 - 1e-6

  aa = 0;

elseif abs( lat ) < 89.999999

  aa = RAD2DEG * acos( r * dlat / sin( za ) );

  if dlon < 0
    aa = -aa;
  end

else

  aa = RAD2DEG * atan2( dz, dx ); 

end

za = RAD2DEG * za;
