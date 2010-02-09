% ARTS_CART2ZAAA   Converts a cartesian directional vector to zenith and azimuth
%
%   This function and the sister function *arts_zaaa2cart* handles transformation
%   of line-of-sights. This in contrast to the sph/poslos functions that
%   handles positions, or combinations of positions and line-of-sight.
%
%   The cartesian coordinate system used here can be defined as
%     z : za = 0
%     x : za=90, aa=0
%     y : za=90, aa=90
%
% FORMAT   [za,aa] = arts_cart2zaaa(dx,dy,dz)
%        
% OUT   za   Zenith angle.
%       aa   Azimuth angle.
% IN    dx   LOS component in x dimension.
%       dy   LOS component in y dimension.
%       dz   LOS component in z dimension.

% 2009-09-23   Created by Patrick Eriksson.

function [za,aa] = arts_cart2zaaa(dx,dy,dz)
  
rad2deg = constants( 'RAD2DEG' );


r = sqrt( dx.^2 + dy.^2 + dz.^2 );

if any( r == 0 )
  error( 'The length of [dx,dy,dz] must be > 0.' );
end

za = rad2deg * acos( dz ./ r );

aa = rad2deg * atan2( dy, dx );





