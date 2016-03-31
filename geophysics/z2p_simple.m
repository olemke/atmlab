% Z2P_SIMPLE   Simple conversion from altitudes to pressures
%
%    Altitudes are converted to pressures by assuming that the pressure
%    at 0 m is 1000 hPa, and that the pressure drops with a factor of 10
%    for each 16 km increase in altitude.
%
%    Only pressures above 0.01Pa/112km are accepted by default, as this conversion is not
%    even roughly OK in the thermosphere. To overide set checkalt to 0.
%
% FORMAT   p = z2p_simple( z[,checkalt] )
%        
% OUT   p           Pressure [Pa]
% IN    z           Altitudes [m]
% OPT   checkalt    Variable to ovveride altitude check

% 2004-09-26   Created by Patrick Eriksson.

function p = z2p_simple( z, checkalt )

if nargin < 2
  checkalt = 1;
end

if checkalt
    if any( z > 120e3 )
        error( 'Altitudes above 120 km are not accepted.' );
    end
end

p = 10.^( 5 - z/16e3 );


