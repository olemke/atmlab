function rho = water_vapor_density(p, T, w)
% WATER_VAPOR_DENSITY water vapor density rho
%
%       water vapor density or absolute humidity is the ratio of 
%       the mass of water vapor to the volume occupied by the moist air
%
% FORMAT   rho = water_vapor_density(p, T, w)
%        
% OUT   rho  density [kg/m3]
% IN    p   air pressure [kPa], P can be a scalar or a vector
%       w   mixing ratio [], 	w can be a scalar or a vector
%       T   temperature  [K],	T can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

Rd = constants( 'GAS_CONST_DRY_AIR' ); % gass constant for dry air in J.kg-1.K-1
Rm =  Rd .* ( 1 + 0.6 .* w);
rho = p ./ (Rm .* T);

  
