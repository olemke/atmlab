function X = randgen_normal(xm,S,n)


%= Check input
%
min_nargin( 3, nargin );
%
if ~isvector(xm)  |  size(xm,2) > 1
  error('Input argument *xm* must be a column vector.');
end
%
if ndims(S) > 2  |  size(S,1) ~= size(S,1) 
  error('Input argument *S* must be a square matrix.');
end
%
if length(xm) ~= size(S,1) 
  error('Mismatch in size between *xm* and *S*.');
end
%
if ~isscalar(n)  |  ~isinteger(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end



X = repmat(xm,1,n) + chol(S)'*randn(length(xm),n);