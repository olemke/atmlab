% MGD_GET_PARAMETER  returns modified gamma distribution
%                    parameters given some of them
%
%  a modified gamma distribution can be written as
%  n(x) = N0 * x^mu * exp( -lambda * x^gamma)     (1)
%  and is often used to represent cloud particle
%  size or mass distribution, in that case
%  n(x) has units of [#/m^3/m] or [#/m^3/kg], respectively .
%
%  Particle size/mass distributions in clouds 
%  describe the concentration of particles as
%  function of some size/mass parameter, typically by:
%  * n_g(D_g) where D_g is some geometric size of the particle or
%  * n_e(D_e) where D_e is a mass equivalent sphere diameter 
%  or the concentration of particles can be
%  expressed as function of particle masses:
%  * n_m(m) where m is the particle mass.
%
%  The integral (0th moment) gives Ntot [#/m^3],
%  the total number concentration of particles,
%  in all of the above cases.
% 
%  The first moment of n_m(m) gives the cloud
%  mass concentration (q) [kg/m^3].
% 
%  This is not the case for n_g and n_e.
%  The mass of cloud particles are often
%  parameterised as
%  m(d_g) = a * d_g ^b                          (2)
%  The integral of n_g(d_g)*m(d_g) (b:th moment) gives than 
%  the cloud mass concentration (q) [Kg/m^3].
% 
%  MGD_GET_PARAMETERS returns the N0 and lambda parameters
%  of a modified gamma distribution given
%  q, Ntot, mu, gamma, a, and b defined above.
%  For the particle mass distribution case a=1 and b=1.
%
% FORMAT
%
%  [N0,lambda] = mgd_get_parameters(q,Ntot,a,b,mu,gamma)
%
% OUT
%        N0       modified gamma distribution parameter (see eq. 1)
%        lambda   modified gamma distribution parameter (see eq. 1)
%
% IN     q        cloud mass concentration
%        Ntot     total number concentration
%        mu       modified gamma distribution parameter (see eq. 1)
%        gamma    modified gamma distribution parameter (see eq. 1)
%                 default = 1;
%        a        mass-dimension relationship parameter (see eq. 2)
%                 default = 1;
%        b        mass-dimension relationship parameter (see eq. 2)
%                 default = 1;
% Example usage:
%
% %predined mgd parameters
% mu     = 2; 
% gamma  = 1; 
% %given parameters from a climate model
% Ntot   = 10000; % number of particles [#/m^3]
% q      = 1e-3; %ice water content [kg/m3]
% % m(Dg)=a*Dg^b [kg];
% a      = 206*1e-3;
% b      = 2.25;
% [N0,lambda] = mgd_get_parameter(q,Ntot,mu,g,a,b)
% 
% 

function [N0,lambda] = mgd_get_parameters(q,Ntot,mu,g,a,b)

if nargin==3;
  g = 1;
  a = 1;
  b = 1;
end

if nargin==4;
  a = 1;
  b = 1;
end

% now find lambda and N0
ga     = (mu + b + 1)/g;
gb     = (mu + 1)/g;
g1     = gamma( ga );
g2     = gamma( gb );

lambda = ( (Ntot * a * g1) / (q * g2) ) ^ (g / b);

N0     = (Ntot * g / g2 ) * lambda ^ (gb);  

