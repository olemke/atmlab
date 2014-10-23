function r_c = critical_radius_ice(T,S)
%  R_CRIT compute the critical radius for ice droplet
%
% Compute the critical radius, which is the smallest radii for a particle to
% exist under the input conditions.   The expression is for ice particles.
% The code is adapted from Mark Hervigs IDL code for PMCs.
%
% FORMAT    r_c = r_crit(T,S)
%        
% OUT   r_c  critical_radius [m]
% IN    T   temperature [K]
%       S   saturation ratio
%      
%
% Reference: Rapp & Thomas [JASTP, 2006]
%            
%            and
%
%            A short course in cloud physics (Chapter VI, Formation of cloud
%            droplets); 1996, By: R. R. Rogers and M. M. Yau
%            page: 84, Eq.: 6.2
%
% 2014-10-10   Created by Ole Martin Christensen.
%
%
s_tention_ice = 0.122;              % surface tension of ice in the presence of air [J/m2]
rho_ice = 0.93e3;                   % Ice density [kg/m3]
k = constants('BOLTZMANN_CONST');   %boltzmanns constant
R = constants('GAS_CONST_WATER_VAPOR');
mol_mass_h2o = 18;                  % Molecular mass of water [g/mol]
mass_h2o = mol_mass_h2o/constants('AVOGADRO');


 r_c = 2 * s_tention_ice / (R * T * rho_ice * log(S) ); 
%


