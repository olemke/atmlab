function theta_w = wet_bulb_potential_temp(Tc, p, w) 
%  WET_BULB_POTENTIAL_TEMP wet bulb potential temperature
%
%   wet-bulb potential temperature—(Also called pseudo wet-bulb potential
%   temperature.) The temperature an air parcel would have if cooled from
%   its initial state adiabatically to saturation, and thence brought to 
%   1000 mb by a moist-adiabatic process. This temperature is conservative
%   with respect to reversible adiabatic changes. 
%   (REF: http://amsglossary.allenpress.com/glossary/)
%
% FORMAT   theta_w = wet_bulb_potential_temp(Tc, p, w) 
%        
% OUT   theta_w  wet bulb potential temperature [K]
% IN    Tc  isentropic condensation temperature [K]
%           it can be a scalar or a vector
%       p   air pressure [kpa]
%           it can be a scalar or a vector
%       w   mixing ratio []
%           it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

cp=constants('SPECIFIC_HEAT_CONST_PRESSURE');
cv=constants('SPECIFIC_HEAT_CONST_VOLUME');
k = (cp - cv) / cp; 

k_m = k .* (1 - 0.2 .* w);
theta_w = Tc .* power((100 ./  p), k_m);

        