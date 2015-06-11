% MGD_GET_LAMBDA  Sets MGD's lambda to match constraints 
%
%  See *mgd_psd* for a defintion of MGD. This function handles the case when
%  lambda is unknown, while the mass concentration and other MGD variables are
%  known. 
%
%  The mass of the particles is parameterised as
%     m(d_g) = a * d_g ^b 
%  where d_g is geometric diameter (in the nomenclature of PH11).
%  The defaults for *a* and *b* match spherical water droplets.
%
%  See PH11 [Petty and Huang, JAS, 2011] for further details.
%
%  All input arguments can be scalars or tensor1 (as in e.g. *mgd_moment*).
%  That is, a number of *la* can be determined in one function call.
%
% FORMAT  la = mgd_get_parameters(q,ntot,mu,gamma[,a,b])
%
% OUT   la   See *mgd_psd*.
%       a    As the input argument or default value. 
%       b    As the input argument or default value.
% IN    w    Particle mass concentration.
%       n0   See *mgd_psd*.
%       mu   See *mgd_psd*.
%       ga   See *mgd_psd*.
% OPT   a    Mass-dimension relationship parameter, see above.
%            Default = constants('DENSITY_OF_WATER')*pi/6
%       b    Mass-dimension relationship parameter, see above.
%            Default = 3.

% 2015-06-11   Created by Patrick Eriksson.

function [la,a,b] = mgd_get_lambda(w,n0,mu,ga,varargin)
%
[a,b] = optargs( varargin, { constants('DENSITY_OF_WATER')*pi/6, 3 } );


[w,n0,mu,ga,a,b] = scalars_vectors2same_size( w, n0, mu, ga, a, b );


npsd = length(w);
la    = zeros( npsd, 1 );

% Using Eq 31 in PH11
for i = 1 : npsd
  p     = mu(i) + b + 1;
  la(i) = ( a * n0(i) * gamma( p / ga(i) ) / ( ga(i) * w(i) ) )^(1/p);
end
