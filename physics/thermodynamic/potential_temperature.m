function theta = potential_temperature(T, es, p, rh) 
% POTENTIAL_TEMPERATURE potential temperature theta
%
%   theta The temperature that an unsaturated parcel of dry air would have
%   if brought adiabatically and reversibly from its initial state to a
%   standard pressure, p0, typically 100 kPa 
%   (REF: http://amsglossary.allenpress.com/glossary/)
%
% FORMAT    theta = potential_temperature(T, es, p, rh)
%        
% OUT   theta   potential temperature [K]
% IN    p   air pressure [kPa], it can be a scalar or a vector
%       es  saturation vapor pressure [kPa], it can be a scalar or a vector
%       T   temperature [K], it can be a scalar or a vector
%       rh  relative humidity [%], it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

cp=constants('SPECIFIC_HEAT_CONST_PRESSURE');
cv=constants('SPECIFIC_HEAT_CONST_VOLUME');
k = (cp - cv) / cp; % c is specific heat at constant pressure and volume
ws = mixing_ratio(es, p);
w = rh .* ws;
k_m = k .* (1 - 0.2 .* w);
theta = T .* power((100 ./ p), k_m);      
        
