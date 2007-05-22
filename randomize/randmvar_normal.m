% RANDMVAR_NORMAL  Random multivariate normal distributed data
%
%    Creates a set of random vectors fulfilling multivariate normal
%    statistics. The statistics to fulfill is defined by giving the
%    mean vector, standard deviations and the correlation matrix.
%
%    See also *randmvar_normal2*.
%
% FORMAT   X = randmvar_normal( x, si, C, n )
%        
% OUT   X    Random data [length(x) x n].
% IN    x    Mean vector.
%       si   Standard deviations. Vector with same length as *x*, a scalar
%            or empty. In the scalar case, this value is applied for all 
%            positions. 
%       C    Correlation matrix. 
%       n    Number of realisations to generate.

% 2005-05-20   Created by Patrick Eriksson.


function X = randmvar_normal(x,si,C,n)


%= Check input
%
min_nargin( 4, nargin );
%
if ~isvector(x) 
  error('Input argument *x* must be a vector.');
end
%
if ~( length(si) == 1  |  length(si) == length(x) )
  error( ...
  'Input argument *si* must be a scalar or a vector with same length as *x*.');
end
%
if ndims(C) > 2  |  size(C,1) ~= size(C,2) 
  error('Input argument *C* must be a square matrix.');
end
%
if length(x) ~= size(C,1) 
  error('Mismatch in size between *x* and *S*.');
end
%
if ~isscalar(n)  |  ~iswhole(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end

% Check if C really is a correlation matrix (must be positive definite):
covmat_test(C);

% To get real random results we should reset the random seed. 
randn('state',sum(100*clock));


if length(si) > 1
  si = vec2col( si );
end

S = (si*si') .* C; 

X = repmat(vec2col(x),1,n) + chol(S)'*randn(length(x),n);