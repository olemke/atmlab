% CARTPOSLOS2GEOCENTRIC   Converts cartesian POS/LOS to spherical coordinates 
%
%   Position is given as (x,y,z), while line-of-sight is given as
%   (dx,dy,dz). The corresponding quantities in polar coordinates are
%   (r,lat,lon) and (za,aa), respectively.
%
%   See *geocentricposlos2cart* for defintion of coordinate systems.
%
%   If the optional arguments are given, it is ensured that latitude and
%   longitude are kept constant for zenith or nadir cases, and the longitude
%   and azimuth angle for N-S cases. The optional input shall be interpreted
%   as the [x,y,z] is obtained by moving from [r0,lat0,lon0] in the direction
%   of [za0,aa0].
%
% FORMAT   [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz,...
%                                                [ppc,lat0,lon0,za0,aa0] )
%        
% OUT   r      Radius.
%       lat    Latitude.
%       lon    Longitude.
%       za     Zenith angle.
%       aa     Azimuth angle.
% IN    x      Coordinate in x dimension.
%       y      Coordinate in y dimension.
%       z      Coordinate in z dimension.
%       dx     LOS component in x dimension.
%       dy     LOS component in y dimension.
%       dz     LOS component in z dimension.
%       ppc    Propagation path constant = r0*sin(za0)
%       lat0   Original latitude
%       lon0   Original longitude
%       za0    Orignal zenith angle
%       aa0    Orignal azimuth angle

% 2011-11-15   Created by Bengt Rydberg.


function [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz,...
                                                   ppc,lat0,lon0,za0,aa0)

deg2rad = constants( 'DEG2RAD' );
rad2deg = constants( 'RAD2DEG' );


if nargin <= 6
  [r,lat,lon] = cart2geocentric( x, y, z );
else
  [r,lat,lon] = cart2geocentric( x, y, z, lat0, lon0, za0, aa0 );    
end


coslat = cos( deg2rad * lat );
sinlat = sin( deg2rad * lat );
coslon = cos( deg2rad * lon );
sinlon = sin( deg2rad * lon );
dr     = coslat.*coslon.*dx + sinlat.*dz + coslat.*sinlon.*dy;


% LOS angles
if nargin <= 6
  za = rad2deg * acos( dr );
else
  za = rad2deg * asin( ppc ./ r );
end

aa = zeros(size(za));

% FIXME: surely at least some (if not all) cases here can be vectorised

for i = 1 : size(za,1)
for j = 1 : size(za,2)
for k = 1 : size(za,3)

  % Fixes for za with optional input
  if nargin > 6
    if za0(i,j,k) < 1e-6  ||  za0(i,j,k) > 180-1e-6    % Nadir or zenith
      za(i,j,k) = za0(i,j,k);
    elseif isnan(za(i,j,k))
      za(i,j,k) = 90;
    elseif dr(i,j,k) < 0              % Expression above gives only za < 90
      za(i,j,k) = 180 - za(i,j,k);
    end
  end

  % Azimuth angle:
    
  % Take original value if N-S
  if nargin > 6  &&  ( abs(aa0(i,j,k)) < 1e-6  ||  abs(aa0(i,j,k)-180) < 1e-6 )
    % Check that not lon changed with 180 deg
    if lon(i,j,k) == lon0(i,j,k)
      aa(i,j,k) = aa0(i,j,k);
    else
      if abs(aa0(i,j,k)) < 1e-6
        aa(i,j,k) = 180;
      else
        aa(i,j,k) = 0;
      end
    end
  
  % Set to zero for nadir and zenith
  elseif za(i,j,k) < 1e-6  ||  za(i,j,k) > 180-1e-6 
    aa(i,j,k) = 0;
    
  
  % For lat = +- 90 the azimuth angle gives the longitude along which 
  % the LOS goes
  elseif abs( lat(i,j,k) ) > 90-1e-8 
    aa(i,j,k) = rad2deg * atan2( dy(i,j,k), dx(i,j,k) );

  %General case
  else
    %
    dlat  = -sinlat(i,j,k)*coslon(i,j,k)/r(i,j,k)*dx(i,j,k) + coslat(i,j,k)/r(i,j,k)*dz(i,j,k) - ...
             sinlat(i,j,k)*sinlon(i,j,k)/r(i,j,k)*dy(i,j,k);
    dlon  = -sinlon(i,j,k)/coslat(i,j,k)/r(i,j,k)*dx(i,j,k) + coslon(i,j,k)/coslat(i,j,k)/r(i,j,k)*dy(i,j,k);
    aa(i,j,k) = rad2deg * acos( r(i,j,k) * dlat / sin( deg2rad * za(i,j,k) ) );
    %
    if isnan( aa(i,j,k) ) ||  ~isreal( aa(i,j,k) )
      if dlat >= 0
        aa(i,j,k) = 0;
      else
        aa(i,j,k) = 180;
      end
    elseif dlon < 0
      aa(i,j,k) = -aa(i,j,k);
    end
  end
end
end
end
