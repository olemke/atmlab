% MGD_GET_LAMBDA  Sets MGD's lambda to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when
%  lambda is unknown, while the mass concentration and other MGD variables are
%  known. 
%
%  This version assumes that the size grid is de (see function
%  *particle_de2dg*). Particle mass is calculated as rho*pi*de^3/6.
%
%  If your size grid is dg, use *mgd_get_lambda2*
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  la = mgd_get_lambda(w,n0,mu,ga[,rho])
%
% OUT   la   See *mgd_psd*.
% IN    w    Particle mass concentration.
%       n0   See *mgd_psd*.
%       mu   See *mgd_psd*.
%       ga   See *mgd_psd*.
% OPT   rho  Reference density. Default is the density of water ice,
%            obtained as constants('DENSITY_OF_ICE').

% 2015-06-11   Created by Patrick Eriksson.

function la = mgd_get_lambda(w,n0,mu,ga,varargin)
%
[rho] = optargs( varargin, { constants('DENSITY_OF_ICE') } );


[w,n0,mu,ga,rho] = scalars_vectors2same_size( w, n0, mu, ga, rho );


npsd = length(w);
la   = zeros( npsd, 1 );

for i = 1 : npsd
  % Using Eq 37 in PH11
  a0    = rho(i) * pi / 6;
  p     = ( mu(i) + 4 ) / ga(i);
  la(i) = ( a0 * n0(i) * gamma( p ) / ( ga(i) * w(i) ) )^(1/p);
end
