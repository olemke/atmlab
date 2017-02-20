%% function NedR = NedT2NedR(NedT, Tref, nu)
%  This function can convert noise equivalent temperature (NedT) to noise
%  equivalent radiance (NedR). 
%  
%  IN:  NedT    noise equivalent temperature in Kelvin. NedT can be a
%               vector. 
%       Tref    reference temperature, often used 270 or 280 Kelvin
%       nu      wavenumber in cm^-1. Nu can be a vector. 
%  OUT: NedR    noise equivalent radiance in si units W/(m^2 sr m-1)
% 
% NedR ist the product of NedT and the partial derivative of the Planck 
% function by temperature at the reference temperature. 
%
% Created: Aug 26th, 2016 MFB

function NedR = NedT2NedR(NedT, Tref, nu)

planckc = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');
c1 = planckc * speed_light / boltzmann;

% general formula from http://ncc.nesdis.noaa.gov/data/planck.html
% the derivative of planck and the adaptation to cm-1 is MFB's work

nu = nu .* 100;     % convert cm^-1 to m^-1

dBdT =  2* planckc^2 * speed_light^3/boltzmann .* (nu.^4 ./ Tref.^2) .*...
        exp(c1 .*nu ./ Tref) ./ (exp(c1 .*nu ./ Tref) -1).^2;

NedR = dBdT .* NedT;
end