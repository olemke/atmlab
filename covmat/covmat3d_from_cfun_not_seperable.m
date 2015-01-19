% COVMAT3D_FROM_CFUN_not_seperable   Correlation function based covariance
% matrix for 1D-3D for nonseperable dimensions.
%
%
%   Converts specification data to a covariance matrix for nonseparable dimensions. 
%   The covariance is described by the structure *D*. The function is more general than
%   *covmat_partstat_corr* (for dimensions <= 3D), but is (much) slower,
%   particularly for higher data dimensions or long data grids. 
%
%   Correlation up to 3 dimensions are handled. The dimensions are here 
%   denoted as 1, 2 and 3, in order to be general. The physical meaning
%   of these dimensions differ. For e.g. gas species they correspond to
%   pressure/altitude, latitude and longitude. 
%
%   The data are assumed to be stored with dimension 1 as innermost "loop",
%   dimension 2 next etc. For 3D case, the data order is as follows:
% 
%       [(x1,y1,z1) (x2,y1,z2) ...(xn,y1,z1) (x1,y2,z) ... (x1,y1,z2) ...]'
%
%   Correlation structures are specified by a function and correlation 
%   lengths. The correlation length is the distance where the correlation
%   has dropped to exp(-1). These lengths are averaged between the two
%   involved positions. For example, the exponential correlation function
%   is 
%      c(i,j) = exp(-abs(x(i)-x(j))/((cl(i)+cl(j))/2))
%   where x and cl is the position and correlation length, respectively.
%   Correlation lengths can then specified seperately for each dimension. 
%   However, the type of correlation function MUST BE THE SAME, or drc in all
%   dimensions. The correlation for dimensions not included is set to 1.
%
%   The correlation between two elements are calculated in the following
%   way for each of the three correlation functions:
%
%   lin: c(i,j) = (1-exp(-1))*sqrt((dx1/cx1)^2+(dx2/cx2)^2+(dx3/cx3)^2),
%   gau: c(i,j) = exp(-sqrt((dx1/cx1)^4+(dx2/cx2)^4+(dx3/cx3)^4),
%   exp: c(i,j) = exp(-sqrt((dx1/cx1)^2+(dx2/cx2)^2+(dx3/cx3)^2),
%
%   where dx is the distance between the two point in each dimension, and
%   cx the mean correlation length of the two points in that dimension. 
%
%   Remaining correlation functions are implemented in corresponding 
%   manner.
%   Setting SI, CL1, CL2 or CL3 to a scalar is shorthand for a constant
%   standard deviation/correlation length. No grids need to be specified
%   in this case. Otherwise, SI, CL1, CL2 and CL3 are interpolated
%   linearly to selected retrieval positions (no extrapolation).
%   No checks of size are done. Inconsistency in size between variables 
%   will result in error from interpolation functions.
%
%   Recognised fields of D are:
%   ---
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
%      CL1        Correlation length along dimension 1. Size as for SI.
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
% FORMAT   S = covmat3d_from_cfun(dim,D,grid1[,grid2,grid3])
%
% OUT   S       Covariance matrix.
% IN    dim     Dimensionality.
%       D       Specification data.
%       grid1   Retrieval grid in dimension 1.
% OPT   grid2   Retrieval grid in dimension 2. Not needed if *dim* < 2.
%       grid3   Retrieval grid in dimension 3. Not needed if *dim* < 3.

% 2015-01-15   Created by Ole Martin Christensen.


function S = covmat3d_from_cfun_not_seperable(dim,D,grid1,grid2,grid3)
                                                                          %&%
                                                                          %&%
%--- Simple checks of input                                               %&%
%                                                                         %&%
rqre_nargin( 3, nargin );                                                 %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                              %&%
rqre_in_range( dim, 1, 3 );                                               %&%
rqre_datatype( D, @isstruct );                                            %&%
%                                                                         %&%
if nargin ~= 2+dim                                                        %&%
  error( ...                                                              %&%
  'Dimensionality (*dim*) and number of input arguments do not match.');  %&%
end                                
                                                                          %&%
%Check if all cfuns are the same or drc                                   %&%
cfun_to_use = 'drc';                                                      %&%
if ~strcmp(D.CFUN1,'drc')                                                 %&%
    cfun_to_use = D.CFUN1;                                                %&%
end                                                                       %&%
if dim > 1                                                                %&%
    if ~strcmp(D.CFUN2,'drc') & ~strcmp(cfun_to_use,'drc')                %&%
     if ~strcmp(D.CFUN2,cfun_to_use)                                        %&%
        error('To use non-seperable covariance matrices, correlation functions must be the same in all dimensions'); %&%
     else                                                                 %&%
        cfun_to_use = D.CFUN2;                                            %&%
     end                                                                  %&%
    end                                                                   %&%
end                                                                       %&%
if dim > 2                                                                %&%
    if ~strcmp(D.CFUN3,'drc') & ~strcmp(cfun_to_use,'drc')                %&%
     if ~strcmp(D.CFUN3,cfun_to_use)                                        %&%
        error('To use non-seperable covariance matrices, correlation functions must be the same in all dimensions');        %&%
     end                                                                  %&%
    end                                                                   %&%
end                                                                       %&%
%   


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



%--- Correlation part
%
C = 1;
%
%- x-dimension
if strcmp( D.CFUN1, 'drc' )
  clx = repmat( 0, n, 1 );
else 
  if isscalar( D.CL1 )
    clx = repmat( D.CL1, n, 1 );
  else
    if dim == 1
      clx = interpd( x, D.CL1, D.CL1_GRID1, 'linear' );
    elseif dim == 2
      clx = interpd( [x,y], D.CL1, D.CL1_GRID1, D.CL1_GRID2, 'linear' );
    else
      clx = interpd( [x,y,z], D.CL1, D.CL1_GRID1, D.CL1_GRID2, D.CL1_GRID3,...
                                                                  'linear' );
    end
    if any( isnan(clx) )
      error( ['NaN obtained for dim1 correlation length. ',...
              'Probably caused by extrapolation at re-gridding.'] )
    end
  end
end
%
%- y-dimension
if dim >= 2
  if strcmp( D.CFUN2, 'drc' )
    cly = repmat( 0, n, 1 );
  else 
    if isscalar( D.CL2 )
      cly = repmat( D.CL2, n, 1 );
    else
      if dim == 2
        cly = interpd( [x,y], D.CL2, D.CL2_GRID1, D.CL2_GRID2, 'linear' );
      else
        cly = interpd( [x,y,z], D.CL2, D.CL2_GRID1, D.CL2_GRID2, ...
                                                     D.CL2_GRID3, 'linear' );
      end
      if any( isnan(cly) )
        error( ['NaN obtained for dim2 correlation length. ',...
                'Probably caused by extrapolation at re-gridding.'] )
      end
    end
  end
end
%
%- z-dimension
if dim == 3
  if strcmp( D.CFUN3, 'drc' )
    clz = repmat( 0, n, 1 );
  else 
    if isscalar( D.CL3 )
      clz = repmat( D.CL3, n, 1 );
    else
      clz = interpd( [x,y,z], D.CL3, D.CL3_GRID1, D.CL3_GRID2, ...
                                                     D.CL3_GRID3, 'linear' );
    end
    if any( isnan(clz) )
      error( ['NaN obtained for dim3 correlation length. ',...
              'Probably caused by extrapolation at re-gridding.'] )
    end
  end
end

switch dim
    case 1
        C = make_cmatrix_1d( x, clx, D.CFUN1 );
    case 2
        C = make_cmatrix_2d( x, y, clx, cly, D.CFUN1, D.CFUN2 );
    case 3
        C = make_cmatrix_3d( x, y, z, clx, cly, clz, D.CFUN1, D.CFUN2, D.CFUN3 );
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


return

%------------------------------------------------------------------------------


function C = make_cmatrix_1d( x, cl, cfun )
  %
  n = length( x );
  C = eye( n, n );
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


function C = make_cmatrix_2d( x, y, clx, cly, cfunx, cfuny )
  %
  n = length( x );
  C = eye( n, n );
  if ~strcmp(cfunx,'drc')
      cfun = cfunx;
  elseif ~strcmp(cfuny,'drc')
      cfun = cfuny;
  else
      cfun = 'drc';
  end
  
  if strcmp( cfun, 'drc' )
    for row=1:(n-1)
      for col=(row+1):n
        if x(row) == x(col) && y(row) == y(col)
          C(row,col) = 1; 
          C(col,row) = 1;
        end
      end
    end
  
  
  %
  elseif strcmp( cfun, 'lin' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        
        c = 1 - (1-exp(-1)) * sqrt((x_cl)^2 +(y_cl)^2) ;
        if c>0 
          C(row,col) = c; 
          C(col,row) = c;
        end
      end
    end

  elseif strcmp( cfun, 'exp' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        
        c = exp(-sqrt((x_cl)^2 + (y_cl)^2));
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  elseif strcmp( cfunx, 'gau' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        
        c = exp(-sqrt((x_cl)^4 + (y_cl)^4));
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  else
     error(sprintf('Unknown selection for correlation function (%s).',cfun));
  end
  %
return


function C = make_cmatrix_3d( x, y, z, clx, cly, clz, cfunx, cfuny, cfunz )
  %
  n = length( x );
  C = eye( n, n );
  if ~strcmp(cfunx,'drc')
      cfun = cfunx;
  elseif ~strcmp(cfuny,'drc')
      cfun = cfuny;
  elseif ~strcmp(cfunz,'drc')
      cfun = cfunz;
  else
      cfun = 'drc';
  end
  
  if strcmp( cfun, 'drc' )
    for row=1:(n-1)
      for col=(row+1):n
        if x(row) == x(col) && y(row) == y(col) && z(row) == z(col)
          C(row,col) = 1; 
          C(col,row) = 1;
        end
      end
    end
  
  
  %
  elseif strcmp( cfunx, 'lin' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        colzmean = (cly(row)+cly(col))/2; %mean correlation length

        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        dz = y(row)-y(col); %distance

        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        z_cl = dz./colzmean; %y normalized with correlation length
        if isnan(z_cl) %To take into acount drc in one dimension
            z_cl = 0;
        end

        c = 1 - (1-exp(-1)) * sqrt((x_cl)^2 +(y_cl)^2 + (z_cl)^2) ;
        if c>0 
          C(row,col) = c; 
          C(col,row) = c;
        end
      end
    end

  elseif strcmp( cfunx, 'exp' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        colzmean = (cly(row)+cly(col))/2; %mean correlation length

        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        dz = y(row)-y(col); %distance

        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        z_cl = dz./colzmean; %y normalized with correlation length
        if isnan(z_cl) %To take into acount drc in one dimension
            z_cl = 0;
        end
        
        c = exp(-sqrt((x_cl)^2 + (y_cl)^2 + (z_cl)^2));
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  elseif strcmp( cfunx, 'gau' )
    for row=1:(n-1)
      for col=(row+1):n
        colxmean = (clx(row)+clx(col))/2; %mean correlation length
        colymean = (cly(row)+cly(col))/2; %mean correlation length
        colzmean = (clz(row)+clz(col))/2; %mean correlation length

        dx = x(row)-x(col); %distance
        dy = y(row)-y(col); %distance
        dz = z(row)-z(col); %distance

        x_cl = dx./colxmean; %x normalized with correlation length
        if isnan(x_cl) %To take into acount drc in one dimension
            x_cl = 0;
        end
        y_cl = dy./colymean; %y normalized with correlation length
        if isnan(y_cl) %To take into acount drc in one dimension
            y_cl = 0;
        end
        z_cl = dz./colymean; %y normalized with correlation length
        if isnan(z_cl) %To take into acount drc in one dimension
            z_cl = 0;
        end
        
        c = exp(-sqrt((x_cl)^4 + (y_cl)^4 + (z_cl)^4));
        C(row,col) = c; 
        C(col,row) = c;
      end
    end

  else
     error(sprintf('Unknown selection for correlation function (%s).',cfun));
  end
  %
return