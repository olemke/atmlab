% I2RAYJEANTB   Rayleigh-Jeans brightness temperature
%
%    Convert intensities to "Rayleigh-Jeans" temperatures using the
%    Rayleigh-Jeans scaling factor.
%
% FORMAT   i2rayjeanTb(i,f)
%        
% OUT   tb   brightness temperatures [K]
% IN    i    intensities [W/(m^2*Hz*sr)]
%       f    frequencies [Hz]

% 2002-12-12   Created by Claudia Emde.


function tb = i2rayjeanTb(i,f)

boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

tb = speed_light^2./(2*f.^2*boltzmann) .* i;
