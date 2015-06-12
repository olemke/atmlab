% PARTICLE_DG2DE   Converts geometrical to equivalent spherical diameter
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
% FORMAT [de,mass,ddg_dde] = particle_dg2de(dg,a,b,rho)
% 
% OUT   de      Equivalent spherical diameters matching *dg*.
%       mass    Particle mass.
%       ddg_dde Factor to convert PSDs from dg to de base. This factor
%               is dDg/dDe.  
% IN    dg      Values of geomtrical dimensions.
%       a       Constant in Dg-mass relationship, see above.
%       b       Constant in Dg-mass relationship, see above.
% OPT   rho     Particle density. Default is the standard value for water 
%               ice, see constants.m.

% 2014-11-08 Patrick Eriksson


function [de,mass,ddg_dde] = particle_dg2de(dg,a,b,rho)
%
if nargin < 4
  rho = constants( 'DENSITY_OF_ICE' );
end

mass = a * dg.^b;

de = power( mass*6/(pi*rho), 1/3 );

if nargout > 2
  ddg_dde = 1 ./ ( power( 6*a/(pi*rho), 1/3 ) * b/3 * power( dg, b/3-1 ) );
end