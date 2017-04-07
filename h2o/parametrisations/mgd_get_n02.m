% MGD_GET_N02  Sets MGD's n0 to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when n0
%  is unknown, while the mass concentration and other MGD variables are known.
%
%  This version assumes that the size grid is dg (see function
%  *particle_de2dg*). Particle mass is calculated as a*dg^b
%
%  If your size grid is de, use *mgd_get_lambda*
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  n02 = mgd_get_n0(w,mu,la,ga,a,b)
%
% OUT   n0   See *mgd_psd*.
% IN    w    Particle mass concentration.
%       mu   See *mgd_psd*.
%       la   See *mgd_psd*.
%       ga   See *mgd_psd*.
%       a    See above.
%       b    See above.

% 2015-04-07   Created by Patrick Eriksson.

function n0 = mgd_get_n02(w,mu,la,ga,a,b)

[w,mu,la,ga,a,b] = scalars_vectors2same_size( w, mu, la, ga, a, b );


npsd = length(w);
n0   = zeros( npsd, 1 );

for i = 1 : npsd
  % Eq 31 in PH11
  p     = ( mu(i) + b(i) + 1 ) / ga(i);
  n0(i) = ( w(i) * ga(i) * la(i)^p ) / ( a * gamma( p ) );
end
