function X = randgen_free_distfun(P,C,n)


%= Check input
%
min_nargin( 3, nargin );
%
if ~iscell(P)
  error('Input argument *P* must be a cell array.');
end
%
if ndims(C) > 2  |  size(C,1) ~= size(C,1) 
  error('Input argument *C* must be a square matrix.');
end
%
if length(P) ~= size(C,1) 
  error('Mismatch in size between *P* and *C*.');
end
%
if ~isscalar(n)  |  ~isinteger(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end
%
if nargin < 4
  interpmeth = 'linear';
end


lxm = length(P);

%= Generate cases with normal distribution and unit std dev
%
X = randgen_normal( zeros(lxm,1), C, n );

%= Transform to cumulative values
%
Xc = erf( X/sqrt(2) )/2 + 0.5;

%= Map to uniform distribution
%
for i = 1:lxm
  %
  if P{i}.distfun(1,2) ~= 0
    error( sprintf('Distribution function %d does not start with 0',i) );
  end
  if P{i}.distfun(end,2) ~= 1
    error( sprintf('Distribution function %d does not end with 1',i) );
  end
  %
  if isfield( P{i}, 'interpmeth' )
    imethod = P{i}.interpmeth
  else
    imethod = 'linear';
  end
  %
  X(i,:) = interp1( P{i}.distfun(:,2), P{i}.distfun(:,1), Xc(i,:), imethod );
  %
  if isfield( P{i}, 'datalims' )
    X(i,find(X(i,:)<P{i}.datalims(1))) = P{i}.datalims(1);
    if length(P{i}.datalims) > 1
      X(i,find(X(i,:)>P{i}.datalims(2))) = P{i}.datalims(2);
    end
  end
  %
end
