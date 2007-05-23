function S = covmat_seperable_corrcoef(si,varargin)

if length(varargin) < 1
  error( 'At least one correlation matrix must be given.' )
end

n = 1;
%
for i = 1 : length(varargin)
  if ~( dimens(varargin{i})~=2 | size(varargin{i},1)==size(varargin{i},2) )
    error( sprintf( 'Correlation matrix %d is not a square matrix', i ) );
  end
  n = n * size(varargin{i},1);
end
%
if ~( isscalar(si)  |  n == length(si) )
  error( ...
   'Inconsistency between length of *si* and sizes of correlation matrices.' );
end


S = varargin{1};

for i = 2 : length(varargin)

  nold = size( S, 1 );
  nnew = size( varargin{i}, 1 );
  
  [irow0,icol0,s0] = find( S );
  %
  ns          = length( s0 );
  irow        = repmat( irow0, nnew^2, 1 );
  icol        = repmat( icol0, nnew^2, 1 );
  s           = repmat( s0, nnew^2, 1 );  

  for ir = 1:nnew
    for ic = 1:nnew
      %
      ind_s   = (1:ns) + ((ic-1)*nnew+ir-1)*ns;
      %
      irow(ind_s) = irow0 + (ir-1)*nold;
      icol(ind_s) = icol0 + (ic-1)*nold;
      s(ind_s)    = varargin{i}(ir,ic) * s0;
    end
  end
  
  ind = find(s);

  S = sparse( irow(ind), icol(ind), s(ind), nold*nnew, nold*nnew );  
  
end


