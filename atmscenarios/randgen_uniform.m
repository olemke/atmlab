function X = randgen_uniform(Xlims,C,n)


%= Check input
%
min_nargin( 3, nargin );
%
if ndims(Xlims) ~= 2  |  size(Xlims,2) ~= 2
  error('Input argument *Xlims* must be a matrix with two columns.');
end
%
if ndims(C) > 2  |  size(C,1) ~= size(C,1) 
  error('Input argument *C* must be a square matrix.');
end
%
if size(Xlims,1) ~= size(C,1) 
  error('Mismatch in size between *Xlims* and *C*.');
end
%
if ~isscalar(n)  |  ~isinteger(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end

lxm = size(Xlims,1);

%= Generate cases with normal distribution and unit std dev
%
Xn = randgen_normal( zeros(lxm,1), C, n );

%= Transform to cumulative values
%
C = 0.5*( 1 + erf( Xn/sqrt(2) );

%= Map to uniform distribution
%
c = [ 0 1 ];
X = zeros(size(Xn));
%
for i = 1:lxm
  %
  X(i,:) = interp1( c, Xlims(i,:), C(i,:) );
  %
end
