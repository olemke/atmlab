%% get dew point from volume mixing ratio
%
% Td = vmr2dewpoint(vmr, pressure)
%
% IN    vmr             water vapor volume mixing ratio in 1/1
%       pressure        ambient pressure in Pascal
% OUT   Td              dew point temperature in Kelvin
%
% uses the Magnus formula over water surface
%
% 2017-01-30 MFB
%


function Td = vmr2dewpoint(vmr, pressure)

% Magnus formula constants
a = 6.112; % hPa
b = 17.62; % 1/1
c = 243.12; % 'Celsius'

pressure = pressure / 100. ; % convert Pa to hPa

e = vmr .* pressure; % partial H2O pressure by Dalton's law

Td = log(e/a) * c ./ (b - log(e/a));
Td = Td + 273.15; % convert to Kelvin

end