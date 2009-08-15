function Te = equivalent_temperature(T, w)
% EQUIVALENT_TEMPERATURE    equivalent temperature Te
%
%    Temperature a sample of moist air would obtain if all
%    the moisture were condensed out at constant pressure
%    (i.e. latent heat converted to sensible heat). 
%
% FORMAT    Te = equivalent_temperature(T, w)
%        
% OUT   Te  equivalent temperature [K]
% IN    w   mixing ratio [],  it can be a scalar or a vector
%       T   temperature [K],  it can be a scalar or a vector
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%
% 2009-08-15   Created by Isaac Moradi.

cp = constants( 'SPECIFIC_HEAT_CONST_PRES' ); % specific heat at constant pressure J.kg-1.K-1
L = constants( 'LATENT_HEAT_VAPORIZATION' ); % latent heat of vaporization J.kg-1

Te = T + L .* w ./ cp;            
