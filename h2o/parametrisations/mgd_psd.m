% MGD_PSD   Modified gamma distribution particle size distributions
%
%   The MGD distribution is
%     n(x) = n0 * x.^mu * exp( -lambda * x.^gamma ) 
%
%   See Petty and Huang, JAS, (2011) for a detailed discussion of MGD.
%
%   Multiple PSDs can be generated, by setting one or several of *n0*, *mu*,
%   *la* and *ga* to a vector (must be a column vectors). If several are
%   vectors, they must have the same length. A PSD is generated
%   for each combination. If one variable is the same for all combinations,
%   that variable can be set to a scalar.
% 
% FORMAT n = mgd_psd(x,n0,mu,la,ga)
%
% OUT   n    Particle size distribution(s). Number of rows follows *x*, 
%            while number of columns follows max length of the remaining
%            input arguemnts.
% IN    x    Size, area or mass grid.
%       n0   See above.
%       mu   See above.
%       la   See above.
%       ga   See above.

% 2015-06-11   Created by Patrick Eriksson


function n = mgd_psd(x,n0,mu,la,ga)
  
rqre_datatype( x, @istensor1 );

[n0,mu,la,ga] = scalars_vectors2same_size( n0, mu, la, ga );

l    = length(x);
npsd = length(n0);
n    = zeros( l, npsd );

% Check for special cases. Should be numerically more stable. And quicker?
for i = 1 : npsd
  if (mu(i)+1)/ga(i) <= 0
    error( '(mu+1)/ga must be > 0.' );
  end
  if ga(i) == 1
    if mu(i) == 0
      % Exponential distribution
      n(:,i) = n0(i) * exp( -la(i)*x );
    else
      % Gamma distribution
      n(:,i) = n0(i) * x.^mu(i) .* exp( -la(i)*x );
    end 
  else      
    % Complete MGD
    n(:,i) = n0(i) * x.^mu(i) .* exp( -la(i)*x.^ga(i) );
  end  
end