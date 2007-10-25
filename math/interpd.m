% INTERPD  Interpolation of 1D, 2D or 3D data
%
%    Interpolation of data to a set of positions. Basically an interface to 
%    interp1, interp2 and interp3, with the attempt to avoid some of the 
%    confusion around naming/order of dimensions in standard Matlab functions.
%
%    The data is assumed to have dimensions: A(x,y,z)
%    Grids for dimensions not used must be left out.
%
%    The function considers the atmlab setting EXTRAP.
%
%    For "regridding", see accompanying function *regrid*.
%
% FORMAT   B = interpd( pos, A, x [, y, z, iopt] )
%        
% OUT   B      Interpolated data.
% IN    pos    Matrix where each row gives position of new point as (x,y,z).
%       A      Data to be interpolated.
%       x      Grid in dimension 1.
%       y      Grid in dimension 2.
%       z      Grid in dimension 3.
% OPT   iopt   Interpolation option. See e.g. *interp2*. Default is 'linear'.

% 2007-05-22   Created by Patrick Eriksson.


function B = interpd(pos,A,x,y,z,iopt)


%- Check input
%
rqre_datatype( 'numeric', pos );
%
rqre_datatype( 'numeric', A );
%
rqre_datatype( 'vector', x );
%
if length(x) ~= size(A,1)
  fprintf('Mismatch in size between *x* and *A*.\n');
  fprintf('Note that *A* must be a COLUMN vector for 1D.\n');
  fprintf('\nx = \n');
  disp(x);
  fprintf('A = \n');
  disp(A)
  error('See above');
end
%
dim = size(pos,2);
%
if nargin < 2+dim
  error( 'Too few input arguments.' );
elseif nargin > 3+dim
  error( 'Too many input arguments.' );
end
%
if dimens(A) > dim
  error('Mismatch in dimension between *pos* and *A*.');
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
  end

  B = interp1( x, A, pos, imethod );

elseif dim == 2

  rqre_datatype( 'vector', y );

  if length(y) ~= size(A,2)
    error('Mismatch in size between *y* and *A*.');
  end

  if nargin == 5
    imethod = z;
  end

  if atmlab( 'EXTRAP' )
    [A,x,y] = expand2inf( A, x, y );
  end

  B = interp2( y, x, A, pos(:,2), pos(:,1), imethod ); 

elseif dim == 3

  rqre_datatype( 'vector', y );
  rqre_datatype( 'vector', z );

  if length(y) ~= size(A,2)
    error('Mismatch in size between *y* and *A*.');
  end
  if length(z) ~= size(A,3)
    error('Mismatch in size between *z* and *A*.');
  end

  if nargin == 6
    imethod = iopt;
  end
  
  if atmlab( 'EXTRAP' )
    [A,x,y,z] = expand2inf( A, x, y, z );
  end

  B = interp3( y, x, z, A, pos(:,2), pos(:,1), pos(:,3), imethod ); 

end