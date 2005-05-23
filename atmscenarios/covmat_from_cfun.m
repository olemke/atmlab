% COVMAT_FROM_CFUN   Correlation function based covariance matrix
%
%    This function sets up a covariance matrix from defined correlation 
%    function. The correlation function is specified by giving a functional
%    form (such as exponential decreasing) and correlation lengths. The
%    correlation length is throughout defined as the distance where the 
%    correlation has dropped to exp(-1). For off-diagonal values, the 
%    correlation length is averaged between the two involved positions.
%
%    For larger matrices and longer correlation lengths the obtained matrix 
%    can fail to be positive definitive. To ensure a positive definitive,
%    set the *test* flag.
%
% FORMAT   S = covmat_from_cfun( xp, Std, cfun, [Cl, cco, test] )
%        
% OUT   S     The covariance matrix
% IN    xp    The data abscissa.
%       Std   Standard deviations. Given as a two vector matrix. First column
%             holds position in same unit as *xp*. The second column is the 
%             standard deviation at the postions of the first column. These
%             values are then interpolated to *xp*.
%             If set to [], unit standard deviation is assumed and the output
%             corresponds to the correlation matrix.
%       cfun  Correlation function. Possible choices are
%              'dia' : Diagonal matrix. Any given correlation is neglected.
%              'lin' : Linearly decreasing (down to zero).
%              'exp' : Exponential decreasing (exp(-dx/cl)).
%              'gau' : Gaussian (normal) deceasing (exp(-(dx/cl))^2).
% OPT   Cl    Correlation lengths. Given as a column matrix as *Std*.
%             Must be given for all *cfun* beside 'dia'.
%       cco   Correlation cut-off. All values below this limit are set to 0. 
%       test  If set to true/1, the obtained matrix is checked to be positive
%             definite.

% 2005-05-20   Created by Patrick Eriksson.


function S = covmat_from_cfun(xp,Std,cfun,Cl,cco,test)


%= Default values
%
Cl_DEFAULT  = [1 1];
cco_DEFAULT = 0;
test_DEFAULT = false;
%
set_defaults;


%= Check input
%
min_nargin( 3, nargin );
%
if ~( isempty( Std )  &  size(Std,2) ~= 2 )
  error( 'Argument *Std* must be a matrix with 2 columns, or be empty.' );
end
%
if size(Cl,2) ~= 2
  error( 'Argument *Cl* must be a matrix with 2 columns.' );
end
%
if ~( isscalar( cco )  &  cco >= 0 )
  error( 'Argument *cco* must be a scalar >=0' );
end


n  = length( xp );


%= Handle diagonal matrices separately (note return)
%
if strcmp( lower(cfun), 'dia' )
  %
  S = speye( n, n );
  return
  %
end



%= Distance matrix
%
[X1,X2] = meshgrid( xp, xp );
D       = abs( X1 - X2 );


%= Correlation length matrix 
%
cl = interp1( Cl(:,1), Cl(:,2), xp );
[X1,X2] = meshgrid( cl, cl );
L       = ( X1 + X2 ) / 2;
%
clear X1 X2



%= Create correlation matrix
%
switch lower(cfun)

  case 'lin'
    %
    S = 1 - (1-exp(-1)) * ( D./L );
    S( find(S<0) ) = 0;

  case 'exp'
    %
    S = exp( -D./L );

  case 'gau'
    %
    S = exp( -(D./L).^2 );

  otherwise
    %
    error( sprintf('Unknown correlation function (%s)',cfun) );

end



%- Remove values below correlation cut-off limit and convert to sparse
%
if cco > 0
  S( find(abs(S) < cco )) = 0;
end
%
[i,j,s] = find( S );
S = sparse( i, j, s, n, n );



%- Include standard deviations
%
if ~isempty( Std )
  si = vec2col( interp1( Std(:,1), Std(:,2), xp ) );
  S = (si*si') .* S;
end



%- Test?
%
if test
  %
  [R,p] = chol( S );
  %
  if p
    error( 'Obtained matrix is not positive definite.' );
  end
  %
end