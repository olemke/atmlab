% GRIDCELL_CROSSING_3D   Position of crossing between path and a grid face
%
%    This is the basic function to determine where the path exits the grid
%    cell, given a single grid face. Or rather, the function determines
%    the position of the path for a given radius, latitude or longitude.
%
%    The function considers only crossings in the forward direction, but
%    not after a tangent point. If no crossing is found, *r* is set to -1.
%
%    An example, to find the crossing with a latitude grid face at 10 degrees,
%    call the function as: gridcell_crossing_3d(x,y,z,dx,dy,dz,2,10);
%
% FORMAT   [r,lat,lon,l] = gridcell_crossing_3d(x,y,z,dx,dy,dz,
%                                                            known_dim,rlatlon)
%        
% OUT   r           Radius for crossing with given r/lat/lon.
%       lat         Latitude for crossing with given r/lat/lon.
%       lon         Longitude for crossing with given r/lat/lon.
%       l           Distance along path between (x,y,z) and the crossing point.
% IN    x     	    x-coordinate of observation position.
%       y     	    y-coordinate of observation position.
%       z     	    z-coordinate of observation position.
%       dx    	    x-part of LOS unit vector.
%       dy    	    y-part of LOS unit vector.
%       dz    	    z-part of LOS unit vector.
%       known_dim   Given spherical dimension, 1=r, 2=lat and 3=lon.
%       rlatlon     The value for the known dimension.

% 2002-12-29   Created by Patrick Eriksson.


function [r,lat,lon,l] = gridcell_crossing_3d(x,y,z,dx,dy,dz,known_dim,rlatlon)


%= Input
%
min_nargin( 8, nargin );
%
if ~isinteger(known_dim) | known_dim<1 | known_dim>3
  error('The argument *known_dim* must be an integer between 1 and 3.');
end


%= Set dummy values to be used if there is no crossing
%
r   = -1;
lat = 999;
lon = 999;
l   = -1;


DEG2RAD = constants( 'DEG2RAD' );
RAD2DEG = constants( 'RAD2DEG' );


switch known_dim

case 1   % Radius is known
   
  a  = dx*dx + dy*dy + dz*dz;
  p  = ( x*dx + y*dy + z*dz ) / a;
  pp = p * p;
  q  = ( x*x + y*y + z*z - rlatlon*rlatlon ) / a;

  l = -p + sign(p) * sqrt( pp - q );      % Not still totally sure that sign(p)
                                          % for all cases !!!
  if l >= 0
    r   = rlatlon;
    lat = RAD2DEG * asin( ( y+dy*l ) / r );
    lon = RAD2DEG * atan2( z+dz*l, x+dx*l );
  end


case 2   % Latitude is known

  latrad = DEG2RAD * rlatlon;
  t2     = tan( latrad );
  t2     = t2 * t2;
  a      = dx*dx + dz*dz - dy*dy/t2;
  p      = ( x*dx + z*dz -y*dy/t2 ) / a;
  pp     = p * p;
  q      = ( x*x + z*z - y*y/t2 ) / a;

  l = -p + sign(p) * sqrt( pp - q );      % Not still totally sure that sign(p)
                                          % for all cases !!!
  if l >= 0
    lat = rlatlon;
    r   = ( y+dy*l ) / sin( latrad ); 
    lon = RAD2DEG * atan2( z+dz*l, x+dx*l );
  end
  

case 3   % Longitude is known

  lonrad = DEG2RAD * rlatlon;
  coslon = cos( lonrad );
  tanlon = tan( lonrad );

  l = ( z - tanlon*x ) / ( tanlon*dx - dz );

  if l >= 0
    lon = rlatlon;
    lat = atan( coslon * ( y+dy*l ) / (x+dx*l) );
    r   = ( y+dy*l ) / sin( lat );
    lat = RAD2DEG * lat;
  end
end
