% ARTS_COVMAT   Creates covariance matrix for a single retrieval quantity
%
%   Converts specification data to a covariance matrix. The covariance is
%   described by the structure *D*, where different format options exist.
%   The format is selected by the common field *FORMAT*. 
%
%   The function treats retrieval quantities individually. Thus it only
%   returns covmat matrices to incorporate along the diagonal of the complete 
%   covmat matrix.
%
%   Correlation up to 3 dimensions are handled. The dimensions are here 
%   denoted as 1, 2 and 3, in order to be general. The physical meaning
%   of these dimensions differ. For e.g. gas species they correspond to
%   pressure/altitude, latitude and longitude. For atmospheric data
%   *dtype* shall be set to 'atm', which result in that log10(p)
%   is used as vertical coordinate (assumed to be dim 1). All pressure
%   grids are converted (including e.g. CL1_GRID1). A consequence is that
%   correlation lengths shall be given in pressure decades. For the
%   Earth's atmosphere one pressure decade is roughly 16 km.
%
%   FORMAT == 'param'
%      ---
%      The covariance is here specified in a parameterised way. Values are
%      calculated as S(i,j) = si(i)*si(j)*c1(i,j)*c2(i,j)*c3(i,j),
%      where si(i) is the standard deviation at point i, c1(i,j) is
%      the dim1-correlation between point i and j, etc. 
%      Correlation structures are seperated in each dimension (c1, c2 and c3).
%      This means that only the distance in dimension 1 is considered when
%      calculating c1 etc. Correlation lengths can then specified seperately
%      for each dimension. The correlation for dimensions not included is set
%      to 1.
%      Correlation structures are specified by a function and correlation 
%      lengths. The correlation length is the distance where the correlation
%      has dropped to exp(-1). These lengths are averaged between the two
%      involved positions. For example, the exponential correlation function
%      is 
%         c(i,j) = exp(-abs(x(i)-x(j))/((cl(i)+cl(j))/2))
%      where x and cl is the position and correlation length, respectively.
%      Remaining correlation functions are implemented in corresponding 
%      manner.
%      Setting SI, CL1, CL2 or CL3 to a scalar is shorthand for a constant
%      standard deviation/correlation length. No grids need to be specified
%      in this case. Otherwise, SI, CL1, CL2 and CL3 are interpolated
%      linearly to selected retrieval positions (no extrapolation).
%      No checks of size are done. Inconsistency in size between variables 
%      will result in error from interpolation functions.
%      ---
%      SI         A priori standard deviation. Dimensionality must match *dim*.
%                 Dimension order (dim1,dim2,dim3). 
%      SI_GRID1   Grid of SI in dimension 1. 
%      SI_GRID2   Grid of SI in dimension 1. Not needed if *dim* < 2.
%      SI_GRID3   Grid of SI in dimension 1. Not needed if *dim* < 3.
%      CCO        Correlation cut-off value. All correlation values, c,
%                 -CCO < x < CCO are set to zero. This in order to avoid
%                 non-significant correlation and make the covariance matrix
%                 as sparse as possible.
%      CFUN1      Correlation function in dimension 1. The options exist:
%                  'drc'  Dirac. No correlation. The correlation
%                         length is of no importance here.
%                         Note that this applies only in the considered
%                         dimension.
%                  'lin'  Linearly decreasing to 0 (tenth function).
%                  'exp'  Exponential.
%                  'gau'  Gaussian. 
%      CL1        Correlation length along dimension 1.
%      CL1_GRID1  As corresponding grid for SI.
%      CL1_GRID2  As corresponding grid for SI.
%      CL1_GRID3  As corresponding grid for SI.
%      CFUN2      All fields below as for corresponding field for dim 1.
%      CL2        
%      CL2_GRID1  
%      CL2_GRID2  
%      CL2_GRID3  
%      CFUN3
%      CL3        
%      CL3_GRID1  
%      CL3_GRID2  
%      CL3_GRID3  
%
%   FORMAT == 'file'
%      Not yet implemented.
%
% FORMAT   S = arts_covmat(dim,D,grid1,grid2,grid3,dtype)
%              or
%          S = arts_covmat(dim,D,J,dtype)
%
% OUT   S       Covariance matrix.
% IN    dim     Dimensionality.
%       D       Specification data.
%       grid1   Retrieval grid in dimension 1.
%       J       In this argument pattern, this argument shall be an
%               ArrayOfVectors, where first vector is used as grid1 etc.
% OPT   grid2   Retrieval grid in dimension 2. Not needed if *dim* < 2.
%       grid3   Retrieval grid in dimension 3. Not needed if *dim* < 3.
%       dtype   Type of data. Only specified option so far is 'atm'. See
%               above for details. Default is [].

% 2006-08-21   Created by Patrick Eriksson.


function S = arts_covmat(dim,D,grid1,grid2,grid3,dtype)


%--- Check input
%
min_nargin( 3, nargin );
rqre_scalar( 'dim', dim, 1, 3 );
rqre_datatype( 'struct', D );
%
if iscell( grid1 )
  if nargin > 3
    dtype = grid2;
    if nargin > 4
      error('To many input arguments for argument pattern 2.');
    end
  else
    dtype = [];
  end
  J = grid1;
  grid1 = J{1};   
  if dim >= 2
    grid2 = J{2};   
    if dim == 3
      grid3 = J{3};   
    end
  end
elseif isvector( grid1 )
  min_nargin( 2+dim, nargin );
  rqre_datatype( 'vector', grid1 );
  if dim >= 2
    rqre_datatype( 'vector', grid2 );
    if dim == 3
      rqre_datatype( 'vector', grid3 );
    end
  end
  if nargin < 6
    dtype = [];
  end
else
  error('Unknown type of input argument 3.');
end



%--- Unit conversions
%
if ~isempty(dtype)
  if strcmp(dtype,'atm')
    if ~strcmp( D.FORMAT, 'param' )
      error( ['Atmospheric unit conversion so far only handled for ',...
                                                     'parameterised format.']);
    end
    grid1 = log10(grid1);
    if isfield(D,'SI_GRID1'),  D.SI_GRID1  = log10(D.SI_GRID1);   end
    if isfield(D,'CL1_GRID1'), D.CL1_GRID1 = log10(D.CL1_GRID1);  end
    if isfield(D,'CL2_GRID1'), D.CL2_GRID1 = log10(D.CL2_GRID1);  end
    if isfield(D,'CL3_GRID1'), D.CL3_GRID1 = log10(D.CL3_GRID1);  end
  else
    error(sprintf('Unknown option for *dtype* (%s).',dtype));
  end
end


%--- Determine "x, y and z" position for each point
%
x  = vec2col(grid1);
%
if dim >= 2
  x = repmat( x, length(grid2), 1 );
  y = repmat( vec2row(grid2), length(grid1), 1 );
  y = y(:);
  if dim == 3
    x = repmat( x, length(grid3) );
    y = repmat( y, length(grid3) );
    z = repmat( vec2row(grid3), length(grid1)*length(grid2), 1 );
    z = z(:);
  end
end
%
n = length(x);



%--- Parameterised covariance matrix ------------------------------------------
if strcmp( D.FORMAT, 'param' )

  %--- Correlation part
  %
  C = 1;
  %
  %- x-dimension
  if strcmp( D.CFUN1, 'drc' )
    cl = NaN;
  else 
    if isscalar( D.CL1 )
      cl = repmat( D.CL1, n, 1 );
    else
      if dim == 1
        cl = interpd( x, D.CL1, D.CL1_GRID1, 'linear' );
      elseif dim == 2
        cl = interpd( [x,y], D.CL1, D.CL1_GRID1, D.CL1_GRID2, 'linear' );
      else
        cl = interpd( [x,y,z], D.CL1, D.CL1_GRID1, D.CL1_GRID2, D.CL1_GRID3, ...
                                                                     'linear' );
      end
      if any( isnan(cl) )
        error( ['NaN obtained for dim1 correlation length. ',...
                'Probably caused by extrapolation at re-gridding.'] )
      end
    end
  end
  C = C .* make_cmatrix( x, cl, D.CFUN1 );
  %
  %- y-dimension
  if dim >= 2
    if strcmp( D.CFUN2, 'drc' )
      cl = NaN;
    else 
      if isscalar( D.CL2 )
        cl = repmat( D.CL2, n, 1 );
      else
        if dim == 2
          cl = interpd( [x,y], D.CL2, D.CL2_GRID1, D.CL2_GRID2, 'linear' );
        else
          cl = interpd( [x,y,z], D.CL2, D.CL2_GRID1, D.CL2_GRID2, ...
                                                       D.CL2_GRID3, 'linear' );
        end
        if any( isnan(cl) )
          error( ['NaN obtained for dim2 correlation length. ',...
                  'Probably caused by extrapolation at re-gridding.'] )
        end
      end
    end
    C = C .* make_cmatrix( y, cl, D.CFUN2 );
  end
  %
  %- z-dimension
  if dim == 3
    if strcmp( D.CFUN3, 'drc' )
      cl = NaN;
    else 
      if isscalar( D.CL3 )
        cl = repmat( D.CL3, n, 1 );
      else
        cl = interpd( [x,y,z], D.CL3, D.CL3_GRID1, D.CL3_GRID2, ...
                                                       D.CL3_GRID3, 'linear' );
      end
      if any( isnan(cl) )
        error( ['NaN obtained for dim3 correlation length. ',...
                'Probably caused by extrapolation at re-gridding.'] )
      end
    end
    C = C .* make_cmatrix( z, cl, D.CFUN3 );
  end


  %--- Apply correlation cut-off
  %
  if D.CCO > 0
    ind = find( C  &  abs(C) < D.CCO );
    %
    if isempty( ind )
      C(ind) = 0;
    end
  end


  %--- Include standard deviation
  %
  if isscalar( D.SI )
    si = repmat( D.SI, n, 1 );
  else
    if dim == 1
      si = interpd( x, D.SI, D.SI_GRID1, 'linear' );
    elseif dim == 2
      si = interpd( [x,y], D.SI, D.SI_GRID1, D.SI_GRID2, 'linear' );
    else
      si = interpd( [x,y,z], D.SI, D.SI_GRID1, D.SI_GRID2, D.SI_GRID3, ...
                                                                    'linear' );
    end
  end
  %
  if any( isnan(si) )
    error( ['NaN obtained for standard deviation. ',...
            'Probably caused by extrapolation at re-gridding.'] )
  end
  %
  S = (si * si') .* C;


  %--- Make sparse
  %
  S = sparse( S );


else   %-----------------------------------------------------------------------
   error(sprintf('Unknown covariance matrix specification format  (%s).', ...
                                                                  D.FORMAT ) );
end
return

%------------------------------------------------------------------------------


function C = make_cmatrix( x, cl, cfun )
  %
  n = length( x );
  C = speye( n, n );
  %
  if strcmp( cfun, 'drc' )
    for row=1:(n-1)
      for col=(row+1):n
        if x(row) == x(col)
          C(row,col) = 1; 
          C(col,row) = 1;
        end
      end
    end

  elseif strcmp( cfun, 'lin' )
    for row=1:(n-1)
      for col=(row+1):n
        c = 1 - 2 * (1-exp(-1)) * abs( (x(row)-x(col))/(cl(row)+cl(col)) );
        if c>0 
          C(row,col) = c; 
          C(col,row) = c;
        end
      end
    end

  elseif strcmp( cfun, 'exp' )
    for row=1:(n-1)
      for col=(row+1):n
        c = exp(-abs(x(row)-x(col))/((cl(row)+cl(col))/2));
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  elseif strcmp( cfun, 'gau' )
    for row=1:(n-1)
      for col=(row+1):n
        c = exp( -4 * ( (x(row)-x(col))/(cl(row)+cl(col)) )^2  );
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  else
     error(sprintf('Unknown selection for correlation function (%s).',cfun));
  end
  %
return