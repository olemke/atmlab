% PARTICLE_DE2DG   Converts equivalent spherical to geometrical diameter
%
%    This function converts dg to de assuming that the mass is related to 
%    geometrical dimension, dg, as:
%       mass = a * dg^b. 
%
%    The mass effective size, de, is related to particle mass as 
%       mass = rho * pi * de^3 / 6
%    
%    The arguments *a* and *b* should be in SI units. For example, solid ice 
%    has a = 480 and b = 3.
%
%    The nomenclature used here follows Petty and Huang, JAS [2011].
%
% FORMAT [dg,mass,dde_ddg] = particle_de2dg(de,a,b,rho)
% 
% OUT   dg      Geometrical dimensions matching *de*.
%       mass    Particle mass.
%       dde_ddg Factor to convert PSDs from de to dg base. This factor
%               is dDe/dDg.  
% IN    de      Values of equivalent spherical diameters.
%       a       Constant in Dg-mass relationship, see above.
%       b       Constant in Dg-mass relationship, see above.
% OPT   rho     Particle density. Default is the standard value for water 
%               ice, see constants.m.

% 2014-11-08 Patrick Eriksson


function [dg,mass,dde_ddg] = particle_de2dg(de,a,b,rho)
%
if nargin < 4
  rho = constants( 'DENSITY_OF_ICE' );
end

mass = rho * pi * de.^3 / 6;

dg = power( mass/a, 1/b );

if nargout > 2
  dde_ddg = power( 6*a/(pi*rho), 1/3 ) * b/3 * power( dg, b/3-1 );
end