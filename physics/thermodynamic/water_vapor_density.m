function vd = water_vapor_density(rh, T, p)
% WATER_VAPOR_DENSITY calculates water vapor density vd
%
%       water vapor density or absolute humidity is the ratio of 
%       the mass of water vapor to the volume occupied by the moist air
%
% FORMAT   vd = water_vapor_density(rh, T, p)
%        
% OUT   vd  density [kg/m3]
% IN    rh  relative humidity [%, rh > 0], it can be a scalar or a vector
%       T   air temperature [K], it can be a scalar or a vector
%       p   air pressure [Pa], it can be a scalar or a vector
% EXAMPLE:
%       vd = water_vapor_density(50, 298, 100000)
%       vd = 0.0012
%
% ACCURACY: WATER_VAPOR_DENSITY calculates vapor density according to 
%           thermodynamic functions without any assumptions.
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 18, Eq.: 2.23 and 2.24
%
% 2009-08-15   Created by Isaac Moradi.

% check the size of inputs
if length(rh) ~= length(T) || length(rh) ~= length(p)
    disp('Input vectors of the function ''water_vapor_density'' must have the same size');
    vd = nan;
    return;
end

% set constants
Rd = constants( 'GAS_CONST_DRY_AIR' ); % gass constant for dry air in J.kg-1.K-1

% calculate mixing ratio
r = water_vapor_mixing_ratio(rh, T, p);

% calculate water vapor density
Rm =  Rd .* ( 1 + 0.6 .* r);
vd = (p./1000) ./ (Rm .* T);

  
