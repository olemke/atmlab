% ARTS_ZAAA2CART   Converts zenith and azimuth angles to a cartesian unit vector
%
%   This function and the sister function *arts_cart2zaaa* handles transformation
%   of line-of-sights. This in contrast to the sph/poslos functions that
%   handles positions, or combinations of positions and line-of-sight.
%
%   The cartesian coordinate system used here can be defined as
%     z : za = 0
%     x : za=90, aa=0
%     y : za=90, aa=90
%
% FORMAT   [dx,dy,dz] = arts_poslos2cart(za,aa)
%        
% OUT   dx   LOS component in x dimension.
%       dy   LOS component in y dimension.
%       dz   LOS component in z dimension.
% IN    za   Zenith angle.
%       aa   Azimuth angle.

% 2009-09-23   Created by Patrick Eriksson.

function [dx,dy,dz] = arts_zaaa2cart(za,aa)
  
deg2rad = constants( 'DEG2RAD' );

zarad = deg2rad * za;
aarad = deg2rad * aa;

dz = cos( zarad ) .* ones( size(aa) ); % To make sure that za and aa get
                                       % same size even if za is a scalar
dx = sin( zarad );

dy = sin( aarad ) .* dx;

dx = cos( aarad ) .* dx;

