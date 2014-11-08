% PARTICLE_DMAX2DE   Converts maximum dimension to mass effective size 
%
%    This function converts dmax to de assuming that the mass is related to 
%    maximum dimension, dmax, as:
%       m = a * dmax^b. 
%
%    The mass effective size, de, is related to particle mass as 
%       m = pi * de^3 / 6
%    
%    The arguments *a* and *b* should be in SI units. For example, solid ice 
%    has a = 480 and b = 3.
%
% FORMAT de = particle_dmax2de(dmax,a,b,rho)
% 
% OUT   de      Mass equivalent diameters matching *dmax*
% IN    dmax    Values of maximum dimensions.
%       a       Constant in Dmax-mass relationship, see above.
%       b       Constant in Dmax-mass relationship, see above.
% OPT   rho     Particle density. Default is the standard value for water 
%               ice, see constants.m.

% 2014-11-08 Patrick Eriksson


function de = particle_dmax2de(dmax,a,b,rho)
%
if nargin < 4
  rho = constants( 'DENSITY_OF_ICE' );
end

mass = a * dmax.^b;

de = power( mass*6/(pi*rho), 1/3 );
