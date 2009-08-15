function Tw = wet_bulb_temperature(T, p, w)  
% WET_BULB_TEMPERATURE wet bulb temperature Tw
%
% Temperature to which air may be cooled by evaporating water
% into air at constant pressure. When water is evaporated,
% energy is added to the water. This energy comes at the
% expense of the dry air, which is cooled.
%
% FORMAT   Tw = wet_bulb_temperature(T, p, w)
%        
% OUT   Tw  wet bulb temperature [K]
% IN    T   temperature [K], it is scalar
%       p   air pressure [kpa], it is a scalar
%       w   mixing ratio [], it is scalar
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-06-08   Created by Isaac Moradi.

cp=constants('SPECIFIC_HEAT_CONST_PRES');
eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR'); 
L = constants( 'LATENT_HEAT_VAPORIZATION' ); 

A = 2.53e8; % kPa
B = 5.42e3; % K
Tw = T;            
Tw1 = Tw - 10;
while abs(Tw1 - Tw) > 0.5
    Tw1 = Tw;
    var1 = eps .* A .* exp(-B ./ Tw1) ./ p;
    var2 = L .* (var1 - w) ./ cp;
    Tw = T - var2;
end

        
