% PARTICLE_DE2DMAX   Converts mass effective size to maximum dimension
%
%    This function converts de to dmax assuming that the mass is related to 
%    maximum dimension, dmax, as:
%       m = a * dmax^b. 
%
%    The mass effective size, de, is related to particle mass as 
%       m = pi * de^3 / 6
%    
%    The arguments *a* and *b* should be in SI units. For example, solid ice 
%    has a = 480 and b = 3.
%
% FORMAT dmax = particle_de2dmax(de,a,b,rho)
% 
% OUT   dmax    Maximum dimensions matching *de*
% IN    de      Values of mass equivalent diameters.
%       a       Constant in Dmax-mass relationship, see above.
%       b       Constant in Dmax-mass relationship, see above.
% OPT   rho     Particle density. Default is the standard value for water 
%               ice, see constants.m.

% 2014-11-08 Patrick Eriksson


function dmax = particle_de2dmax(de,a,b,rho)
%
if nargin < 4
  rho = constants( 'DENSITY_OF_ICE' );
end

mass = rho * pi * de.^3 / 6;

dmax = power( mass/a, 1/b );