function w = mixing_ratio(e, p)  
% MIXING_RATIO    mixing ration w
%
%   w mixing ratio is the ratio of kilograms of water vapour, mw, 
%   per kilogram of dry air, md, at a given pressure.
%
% FORMAT    w = mixing_ratio(e, p)
%        
% OUT   w   mixing ratio []
% IN    p   air pressure [kPa, Pa, ...], it can be a scalar or a vector
%       e   water vapor pressure [same unit as p], it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR'); 
w = eps .* e ./ (p - e);  
  