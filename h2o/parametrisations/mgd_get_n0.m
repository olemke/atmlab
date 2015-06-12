% MGD_GET_N0  Sets MGD's n0 to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when n0
%  is unknown, while the mass concentration and other MGD variables are known.
%
%  The PSD with respect to equivalent spherical diameter, de, is returned. If
%  this is liquid- or solid-equivalent de depends on the selection of *rho*.
%  See PH11 [Petty and Huang, JAS, 2011] for further details.
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  la = mgd_get_n0(q,ntot,mu,gamma[,rho])
%
% OUT   n0   See *mgd_psd*.
% IN    w    Particle mass concentration.
%       mu   See *mgd_psd*.
%       la   See *mgd_psd*.
%       ga   See *mgd_psd*.
% OPT   rho  Reference density. Default is the density of water ice,
%            obtained as constants('DENSITY_OF_ICE').

% 2015-06-12   Created by Patrick Eriksson.

function n0 = mgd_get_n0(w,mu,la,ga,varargin)
%
[rho] = optargs( varargin, { constants('DENSITY_OF_ICE') } );


[w,mu,la,ga,rho] = scalars_vectors2same_size( w, mu, la, ga, rho );


npsd = length(w);
n0   = zeros( npsd, 1 );

for i = 1 : npsd
  % Eq 31 in PH11
  a0    = rho(i) * pi / 6;
  p     = ( mu(i) + 4 ) / ga(i);
  n0(i) = ( w(i) * ga(i) * la(i)^p ) / ( a0 * gamma( p ) );
end
