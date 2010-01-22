% ARTS_CART2POSLOS   Converts cartesian POS/LOS to spherical coordinates. 
%
%   Position is given as (x,y,z), while line-of-sight is given as
%   (dx,dy,dz). The corresponding quantities in cartesian coordinates are
%   (r,lat,lon) and (za,aa), respectively.
%
%   See *arts_sph2cart* for defintion of coordinate systems.
%
% FORMAT   [r,lat,lon,za,aa] = arts_cart2poslos(x,y,z,dx,dy,dz)
%        
% OUT   r    Radius.
%       lat  Latitude.
%       lon  Longitude.
%       za   Zenith angle.
%       aa   Azimuth angle.
% IN    x    Coordinate in x dimension.
%       y    Coordinate in y dimension.
%       z    Coordinate in z dimension.
%       dx   LOS component in x dimension.
%       dy   LOS component in y dimension.
%       dz   LOS component in z dimension.

% 2007-05-16   Created by Patrick Eriksson.


function [r,lat,lon,za,aa] = arts_cart2poslos(x,y,z,dx,dy,dz)

deg2rad = constants( 'DEG2RAD' );
rad2deg = constants( 'RAD2DEG' );


[r,lat,lon] = arts_cart2sph( x, y, z );


coslat = cos( deg2rad * lat );
sinlat = sin( deg2rad * lat );
coslon = cos( deg2rad * lon );
sinlon = sin( deg2rad * lon );
dr     = coslat.*coslon.*dx + sinlat.*dy + coslat.*sinlon.*dz;
dlat   = -sinlat.*coslon./r.*dx + coslat./r.*dy - sinlat.*sinlon./r.*dz;
dlon   = -sinlon./coslat./r.*dx + coslon./coslat./r.*dz;


% LOS angles
za = rad2deg * acos( dr );
%
if( za < 1e-4  ||  za > 180-1e-4  )
  aa = 0;
  
elseif( abs( lat ) <= 89.99 )
  %
  aa = rad2deg * acos( r .* dlat ./ sin( deg2rad * za ) );

  ind = find( isnan(aa) );
  %
  if ~isempty(ind)
    aa(ind) = 180 *(1 - dlat(ind) >= 0);
  else
    ind = find( dlon < 0 );
    aa(ind) = -aa(ind);
  end
    
  % For lat = +- 90 the azimuth angle gives the longitude along which the
  % LOS goes
else
  aa = rad2deg * atan2( dz, dx );

end

