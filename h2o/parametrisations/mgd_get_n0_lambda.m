% MGD_GET_N0_LAMBDA  Sets MGD's n0 and la to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when
%  lambda and n0 are unknown, while the mass concentration, Ntot and other MGD
%  variables are known.
%
%  The PSD with respect to equivalent spherical diameter, de, is returned. If
%  this is liquid- or solid-equivalent de depends on the selection of *rho*.
%  See PH11 [Petty and Huang, JAS, 2011] for further details.
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  [n0,la] = mgd_get_n0_lambda(q,ntot,mu,gamma[,rho])
%
% OUT   n0   See *mgd_psd*.
%       la   See *mgd_psd*.
% IN    w    Particle mass concentration.
%       ntot Total number density (moment 0).
%       mu   See *mgd_psd*.
%       ga   See *mgd_psd*.
% OPT   rho  Reference density. Default is the density of water ice,
%            obtained as constants('DENSITY_OF_ICE').

% 2014-??-??   A first version by Bengt Rydberg
% 2015-06-12   Adopted to new set of MGD functions by Patrick Eriksson.

function [n0,la] = mgd_get_n0_lambda(w,ntot,mu,ga,varargin)
%
[rho] = optargs( varargin, { constants('DENSITY_OF_ICE') } );


[w,ntot,mu,ga,rho] = scalars_vectors2same_size( w, ntot, mu, ga, rho );


npsd = length(w);
la   = zeros( npsd, 1 );
n0   = zeros( npsd, 1 );

% Lambda determined by ratio between Ntot and w:
%    Ntot/w = (gfun0/la^p0) / (a0*gfun3/la^p3)
for i = 1 : npsd
  a0    = rho(i) * pi / 6;
  p0    = ( mu(i) + 1 ) / ga(i);
  p3    = ( mu(i) + 4 ) / ga(i);
  gfun0 = gamma( p0 );
  gfun3 = gamma( p3 );
  la(i) = ( ( ntot(i) * a0 * gfun3 ) / ( w(i) * gfun0 ) ).^(ga(i)/3);
  % Eq 17 in PH11
  n0(i) = ( ntot(i) * ga(i) * la(i)^p0 ) / gfun0;  
end
