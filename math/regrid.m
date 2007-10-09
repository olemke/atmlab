% REGRID  Change of rectangular grid in 1D, 2D or 3D
%
%    Interpolation of data between two rectangular grids. Basically
%    an interface to interp1, interp2 and interp3, with the attempt to avoid
%    some of the confusion around naming/order of dimensions  in standard 
%    Matlab functions.
%
%    The data is assumed to have dimensions: A(x,y,z)
%
%    Grids for dimensions not used must be left out. That is, for 1D:
%      B = regrid(A,x,xi[,iopt])
%
%    The function considers the atmlab setting EXTRAP.
%
%    For "pure" interpolation, see accompanying function *interpd*.
%
% FORMAT   B = regrid(A,x,xi,y,yi,z,zi[,iopt])
%        
% OUT   B      Interpolated data.
% IN    A      Data to be interpolated.
%       x      Original x-grid.
%       xi     New x-grid. 
%       y      Original y-grid. Only to be included if A has dimension >= 2.
%       yi     New y-grid. Only to be included if A has dimension >= 2.
%       z      Original z-grid. Only to be included if A has dimension >= 3.
%       zi     New z-grid. Only to be included if A has dimension >= 3.
% OPT   iopt   Interpolation option. See e.g. *interp2*. Default is 'linear'.

% 2006-08-22   Created by Patrick Eriksson.


function B = regrid(A,x,xi,y,yi,z,zi,iopt)


%- Check input
%
rqre_datatype( 'numeric', A );
%
rqre_datatype( 'vector', x );
rqre_datatype( 'vector', xi );
%
if length(x) ~= size(A,1)
  error('Mismatch in size between *x* and *A*.');
end
%
dim = floor( (nargin-1)/2 );
%
if dimens(A) > dim 
  error( 'Dimension of A is higher than number of given grids.' );
end
%  
imethod = 'linear';


%--- Extrapolation switch defined
%
atmlab( 'require', {'EXTRAP'} );



if dim == 1

  if nargin == 4
    imethod = y;
  end

  if atmlab( 'EXTRAP' )
    [A,x] = expand2inf( A, x );
  elseif length(x) < 2
    error( ['Handling of scalar grids require that atmlab EXTRAP option ' ...
            'is activated'] );
  end

  B = interp1( x, A, vec2col(xi), imethod );

elseif dim == 2

  rqre_datatype( 'vector', y );
  rqre_datatype( 'vector', yi );

  if length(y) ~= size(A,2)
    error('Mismatch in size between *y* and *A*.');
  end

  if nargin == 6
    imethod = z;
  end

  [xi,yi] = ndgrid( xi, yi );

  if atmlab( 'EXTRAP' )
    [A,x,y] = expand2inf( A, x, y );
  elseif length(x) < 2  |  length(y) < 2
    error( ['Handling of scalar grids require that atmlab EXTRAP option ' ...
            'is activated'] );
  end

  B = interp2( y, x, A, yi, xi, imethod ); 

elseif dim == 3

  rqre_datatype( 'vector', y );
  rqre_datatype( 'vector', yi );
  rqre_datatype( 'vector', z );
  rqre_datatype( 'vector', zi );

  if length(y) ~= size(A,2)
    error('Mismatch in size between *y* and *A*.');
  end
  if length(z) ~= size(A,3)
    error('Mismatch in size between *z* and *A*.');
  end

  if nargin == 8
    imethod = iopt;
  end
  
  [xi,yi,zi] = ndgrid( xi, yi, zi );

  if atmlab( 'EXTRAP' )
    [A,x,y,z] = expand2inf( A, x, y, z );
  elseif length(x) < 2  |  length(y) < 2  |  length(z) < 2
    error( ['Handling of scalar grids require that atmlab EXTRAP option ' ...
            'is activated'] );
  end

  B = interp3( y, x, z, A, yi, xi, zi, imethod ); 

end