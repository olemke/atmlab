% P2Z_SIMPLE   Simple conversion from pressures to altitudes
%
%    Pressures are converted to altitudes by assuming that the pressure
%    at 0 m is 1000 hPa, and that the pressure drops with a factor of 10
%    for each 16 km increase in altitude.
%
%    Only pressures above 0.01Pa/112km are accepted, as this conversion is not
%    even roughly OK in the thermosphere.
%
% FORMAT   z = p2z_simple( p )
%        
% OUT   z   Altitudes [m]
% IN    p   Pressure [Pa]

% 2005-05-11   Created by Patrick Eriksson.

function z = p2z_simple( p )

if any( p < 0.01 )
  error( 'Pressures below 0.01 Pa are not accepted.' );
end

z = 16e3 * ( 5 - log10(p) );