% MGD_GET_LAMBDA2  Sets MGD's lambda to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when
%  lambda is unknown, while the mass concentration and other MGD variables are
%  known. 
%
%  This version assumes that the size grid is dg (see function
%  *particle_de2dg*). Particle mass is calculated as a*dg^b
%
%  If your size grid is de, use *mgd_get_lambda*
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  la = mgd_get_lambda2(w,n0,mu,ga,a,b)
%
% OUT   la   See *mgd_psd*.
% IN    w    Particle mass concentration.
%       n0   See *mgd_psd*.
%       mu   See *mgd_psd*.
%       ga   See *mgd_psd*.
%       a    See above.
%       b    See above.

% 2017-04-07   Created by Patrick Eriksson.

function la = mgd_get_lambda2(w,n0,mu,ga,a,b)

[w,n0,mu,ga,a,b] = scalars_vectors2same_size( w, n0, mu, ga, a, b );


npsd = length(w);
la   = zeros( npsd, 1 );

for i = 1 : npsd
  % Using Eq 31 in PH11
  p     = ( mu(i) + b(i) + 1 ) / ga(i);
  la(i) = ( a * n0(i) * gamma( p ) / ( ga(i) * w(i) ) )^(1/p);
end
