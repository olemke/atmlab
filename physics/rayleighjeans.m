% RAYLEIGHJEANS   The RJ approximation of the Planck function
%
% Calculates the approximation of the Planck function (blackbody radiation) for
% given frequency and temperature.
% 
% FORMAT   i = rayleighjeans(f,T)
%
% OUT	   i = radiance [W/(m2*Hz*sr)].
% IN       f  = frequency
%          T  = Temperature in [K].
%
% See also: planck

% 2014-10-06 Created by Patrick Eriksson

function i = rayleighjeans(f, T)

boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

i = (2 * boltzmann / speed_light^2) .* f.^2 .* T;

