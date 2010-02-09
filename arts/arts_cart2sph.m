% ARTS_CART2SPH   Converts a cartesian position to spherical coordinates.
%
%   See *arts_sph2cart* for defintion of coordinate systems.
%
% FORMAT   [r,lat,lon] = arts_cart2sph(x,y,z)
%        
% OUT   r    Radius.
%       lat  Latitude.
%       lon  Longitude.
% IN    x    Coordinate in x dimension.
%       y    Coordinate in y dimension.
%       z    Coordinate in z dimension.

% 2007-05-16   Created by Patrick Eriksson.


function [r,lat,lon] = arts_cart2sph(x,y,z)
  
rad2deg = constants( 'RAD2DEG' );


r   = sqrt( x.*x + y.*y + z.*z );
if r > 0
  lat = rad2deg * asin( y ./ r );
else                                                                       %&%
  error( 'This set of functions are not handling the case of r = 0.' );    %&%
end
lon = rad2deg * atan2( z, x ); 


