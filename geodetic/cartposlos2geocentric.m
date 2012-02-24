% CARTPOSLOS2GEOCENTRIC   Converts cartesian POS/LOS to spherical coordinates. 
%
%   Position is given as (x,y,z), while line-of-sight is given as
%   (dx,dy,dz). The corresponding quantities in cartesian coordinates are
%   (r,lat,lon) and (za,aa), respectively.
%
%   See *Contents* for defintion of coordinate systems.
%
% FORMAT   [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz)
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

% 2011-11-15   Created by Bengt Rydberg.


function [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz)

deg2rad = constants( 'DEG2RAD' );
rad2deg = constants( 'RAD2DEG' );


[r,lat,lon] = cart2geocentric( x, y, z );


coslat = cos( deg2rad * lat );
sinlat = sin( deg2rad * lat );
coslon = cos( deg2rad * lon );
sinlon = sin( deg2rad * lon );
dr     = coslat.*coslon.*dx + sinlat.*dz + coslat.*sinlon.*dy;
dlat   = -sinlat.*coslon./r.*dx + coslat./r.*dz - sinlat.*sinlon./r.*dy;
dlon   = -sinlon./coslat./r.*dx + coslon./coslat./r.*dy;


% LOS angles
za = rad2deg * acos( dr );
%
for i = 1 : length(za)
  if( za(i) < 1e-4  ||  za(i) > 180-1e-4  )
    aa(i) = 0;
    
  elseif abs( lat(i) ) <= 90-1e-8 
    %
    aa(i) = rad2deg * acos( r(i) .* dlat(i) ./ sin( deg2rad * za(i) ) );

    ind = find( isnan(aa) );
    %
    if isnan( aa(i) )
      aa(i) = 180 *(1 - dlat(i) >= 0);
    elseif dlon(i) < 0
      aa(i) = -aa(i);
    end
      
    % For lat = +- 90 the azimuth angle gives the longitude along which the
    % LOS goes
  else
    aa(i) = rad2deg * atan2( dy(i), dx(i) );

  end
end
