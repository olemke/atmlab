% POSLOS2CART   Conversion from ARTS position and LOS to cartesian coordinates
%
%    A position (in geographical coordinates) and LOS are converted to a
%    cartesian position and a viewing vector. The viewing direction is the
%    the vector [dx,dy,dz]. This vector is normalised (it has length 1).
%
%    This is a test implementation of the ARTS (internal) function with the
%    same name.
%
% FORMAT   [x,y,z,dx,dy,dz] = poslos2cart(r,lat,lon,za,aa)
%        
% OUT   x     x-coordinate of observation position.
%       y     y-coordinate of observation position.
%       z     z-coordinate of observation position.
%       dx    x-part of LOS unit vector.
%       dy    y-part of LOS unit vector.
%       dz    z-part of LOS unit vector.
% IN    r     Radius of observation position.
%       lat   Latitude of observation position.
%       lon   Longitude of observation position
%       za    LOS zenith angle at observation position.
%       aa    LOS azimuth angle at observation position.

% 2002-12-27   Created by Patrick Eriksson.


function [x,y,z,dx,dy,dz] = poslos2cart(r,lat,lon,za,aa)


%= Input
%
min_nargin( 5, nargin );


DEG2RAD = constants( 'DEG2RAD' );


%= Handle lat = +- 90 as they are special cases
%
if abs( lat ) > 89.999999

  s = sign( lat );

  x = 0;
  z = 0;
  y = s * r;

  dy = s * cos( DEG2RAD * za );
  dx = sin( DEG2RAD * za );
  dz = dx * sin( DEG2RAD * aa );
  dx = dx * cos( DEG2RAD * aa );

else

  %= Convert angles to radians
  %
  latrad = DEG2RAD * lat;
  lonrad = DEG2RAD * lon;
  zarad  = DEG2RAD * za;
  aarad  = DEG2RAD * aa;


  %= Position
  %
  [ x, y, z ] = arts_sph2cart( r, lat, lon );


  %= LOS
  %
  coslat = cos( latrad );
  sinlat = sin( latrad );
  coslon = cos( lonrad );
  sinlon = sin( lonrad );
  cosza  = cos( zarad );
  sinza  = sin( zarad );
  cosaa  = cos( aarad );
  sinaa  = sin( aarad );
  %
  dr   = cosza;
  dlat = sinza * cosaa;              % r-term cancels out below
  dlon = sinza * sinaa / coslat;     % r-term cancels out below
  %
  dx = coslat*coslon * dr - sinlat*coslon * dlat - coslat*sinlon * dlon;
  dy =        sinlat * dr +        coslat * dlat;
  dz = coslat*sinlon * dr - sinlat*sinlon * dlat + coslat*coslon * dlon;

end