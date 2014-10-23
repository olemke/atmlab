function k_term = kelvin_term(T,r)
%  KELVIN_TERM computes the kelvin term for equilibrium water vapour
%  pressure. The equilibrium pressure over a curved surface is then given 
%  by e(r) = e(inf)*kelvin_term.
%
%
% FORMAT    k_term = kelvin_term(T,r)
%        
% OUT   k_term              kelvin_term [-]
% IN    T                   temperature [K]
%       r                   radius of droplet[m]
%      
%            A short course in cloud physics (Chapter VI, Formation of cloud
%            droplets); 1996, By: R. R. Rogers and M. M. Yau
%            page: 84, Eq.: 6.1
%
% 2014-10-10   Created by Ole Martin Christensen.
%
%
s_tention_ice = 0.122;              % surface tension of ice in the presence of air [J/m2]
rho_ice = 0.93e3;                   % Ice density [kg/m3]
R = constants('GAS_CONST_WATER_VAPOR');


k_term = exp(2 * s_tention_ice / ( r * R * rho_ice * T));
%


