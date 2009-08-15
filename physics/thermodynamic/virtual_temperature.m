function Tv = virtual_temperature(T, w)
% VIRTUAL_TEMPERATURE virtual temperature
%
%   Temperature that dry air would have to attain in order to 
%   has the same density as the moist air at the same pressure
%
% FORMAT   Tv = virtual_temperature(T, w)
%        
% OUT   Tv  virtual temperature [K]
% IN    T   temperature [K], it can be a scalar or a vector
%       w   mixing ratio [], it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR'); 

Tv = T .* (1 + w ./ eps) ./ (1 + w);            

        
   