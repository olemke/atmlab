% ARTS_POSLOS2CART   Converts spherical POS/LOS to cartesian coordinates. 
%
%   Position is given as (r,lat,lon), while line-of-sight is given as
%   (za,aa). The corresponding quantities in cartesian coordinates are
%   (x,y,z) and (dx,dy,dz), respectively.
%
%   See *arts_sph2cart* for defintion of coordinate systems.
%
% FORMAT   [x,y,z,dx,dy,dz] = arts_poslos2cart(r,lat,lon,za,aa)
%        
% OUT   x    Coordinate in x dimension.
%       y    Coordinate in y dimension.
%       z    Coordinate in z dimension.
%       dx   LOS component in x dimension.
%       dy   LOS component in y dimension.
%       dz   LOS component in z dimension.
% IN    r    Radius.
%       lat  Latitude.
%       lon  Longitude.
%       za   Zenith angle.
%       aa   Azimuth angle.

% 2007-05-16   Created by Patrick Eriksson.

function [x,y,z,dx,dy,dz] = arts_poslos2cart(r,lat,lon,za,aa)

if r == 0
  error( 'This set of functions are not handling the case of r = 0.' );  
end

deg2rad = constants( 'DEG2RAD' );


% For lat = +- 90 the azimuth angle gives the longitude along which the
% LOS goes
%
if abs( lat ) > 89.9999
  %
  s = sign( lat );
  %
  x = 0;
  z = 0;
  y = s .* r;
  %
  dy = s .* cos( deg2rad .* za );
  dx = sin( deg2rad .* za );
  dz = dx .* sin( deg2rad .* aa );
  dx = dx .* cos( deg2rad .* aa );

else
  %
  latrad = deg2rad * lat;
  lonrad = deg2rad * lon;
  zarad  = deg2rad * za;
  aarad  = deg2rad * aa;
  %
  [x,y,z] = arts_sph2cart( r, lat, lon );
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
  dr     = cosza;
  dlat   = sinza .* cosaa;            % r-terms cancel out below
  dlon   = sinza .* sinaa / coslat; 
  %
  dx = coslat.*coslon.*dr - sinlat.*coslon.*dlat - coslat.*sinlon.*dlon;
  dy =         sinlat.*dr +         coslat.*dlat;
  dz = coslat.*sinlon.*dr - sinlat.*sinlon.*dlat + coslat.*coslon.*dlon;
end

