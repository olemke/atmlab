% MGD_MOMENT   The k:th moment of modified gamma distributions
%
%   Analytical calculation of moments of MGDs. See *mgd_psd* for a defintion
%   of MGD.
%
%   Multiple PSDs and/or moments are handled. This is achieved by setting one
%   or several of *k*, *n0*, *mu*, *la* and *ga* to a vector (must be a column
%   vectors). If several are vectors, they must have the same length. A PSD is
%   generated for each combination. If one variable is the same for all
%   combinations, that variable can be set to a scalar.
%
%   For example, to calculate moment 0, 1 and 3, for fixed (scalar) MGD
%   variables, do:
%      m = mgd_moment([0 1 3]',n0,mu,la,ga)
%
% FORMAT m = mgd_moment(k,n0,mu,la,ga)
%
% OUT   m    Calculated moment(s),
% IN    k    The moment(s) to calculate.
%       n0   See *mgd_psd*.
%       mu   See *mgd_psd*.
%       la   See *mgd_psd*.
%       ga   See *mgd_psd*.

% 2015-06-11   Created by Patrick Eriksson

function m = mgd_moment(k,n0,mu,la,ga)
  
[k,n0,mu,la,ga] = scalars_vectors2same_size( k, n0, mu, la, ga );

npsd = length(n0);
m    = zeros( 1, npsd );

for i = 1 : npsd
  
  if (mu(i)+1)/ga(i) <= 0
    error( '(mu+1)/ga must be > 0.' );
  end
  
  % Eq 17 in PH11
  p    = ( mu(i) + k(i) + 1 ) / ga(i);
  m(i) = n0(i) * gamma( p ) / ( ga(i) * la(i)^p );  
end