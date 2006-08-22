% ARTS_X2FIELD  Conversion from state vector to data field
%
%    The function converts state vector values to a field. In the first format
%    option the data is just reshaped to the expected n-d array corresponding
%    to the retrieval grids.
%
%    In the second case the data are also regrided. The function considers
%    the ARTS definition of Jacobians, which says that the base function
%    for end points extends to infinity. This corresponds to an extrapolation
%    where the end point values are used outside range covered by the
%    retrieval grid.
%
% FORMAT   field = arts_x2field(dim,rgrid1,rgrid2,rgrid3,x)
%            or
%          field = arts_x2field(dim,rgrid1,rgrid2,rgrid3,x,grid1,grid2,grid3])
%        
% OUT   field    Obtained data field.
% IN    dim      Data dimensionality. Up to 3D is handled.
%       rgrid1   Retrieval grid in dimension 1.
%       rgrid2   Retrieval grid in dimension 2. Can be empty if dim=1.
%       rgrid3   Retrieval grid in dimension 3. Can be empty if dim<=2.
%       x        Part of state vector to regrid to *field*.
% OPT   grid1    New grid in dimension 1.
%       grid2    New grid in dimension 2. Only needed if dim >= 2.
%       grid3    New grid in dimension 3. Only needed if dim == 3.

% 2006-08-22   Created by Patrick Eriksson.


function field = arts_x2field( dim, rgrid1, rgrid2, rgrid3, x, grid1, grid2, grid3 )


%--- Some input checks
%
min_nargin( 5, nargin );
%
rqre_scalar( 'dim', dim, 1, 3 );
rqre_datatype( 'vector', rgrid1 );



%--- Just reshape
%
if nargin == 5

  if dim == 1
    field = vec2col( x );
  elseif dim == 2
    rqre_datatype( 'vector', rgrid2 );
    field = reshape( x, length(rgrid1), length(rgrid2) );
  elseif dim == 2
    rqre_datatype( 'vector', rgrid2 );
    rqre_datatype( 'vector', rgrid3 );
    field = reshape( x, length(rgrid1), length(rgrid2), length(rgrid3) );
  end

  return   % --->



%--- Regrid, including "ARTS jacobian extrapolation"
%
else

  rqre_datatype( 'vector', grid1 );

  %- 1D
  if dim == 1

    [rgrid1,f1,l1] = expand_grid( rgrid1, grid1 );

    if ~isempty(f1)  |  ~isempty(l1)
      x = [ x(f1); vec2col(x); x(l1) ];   % x as row vector accepted !
    end 

    field = regrid( x, rgrid1, grid1, 'linear' ); 

  elseif dim == 2

    rqre_datatype( 'vector', rgrid2 );
    rqre_datatype( 'vector', grid2 );

    x = reshape( x, length(rgrid1), length(rgrid2) );

    [rgrid1,f1,l1] = expand_grid( rgrid1, grid1 );
    [rgrid2,f2,l2] = expand_grid( rgrid2, grid2 );

    if ~isempty(f1)  |  ~isempty(l1)  |  ~isempty(f2)  |  ~isempty(l2)
      x = [ x(f1,f2) x(f1,:) x(f1,l2); 
            x(:,f2)  x       x(:,l2); 
            x(l1,f2) x(l1,:) x(l1,l2) ];
    end 

    field = regrid( x, rgrid1, grid1, rgrid2, grid2, 'linear' ); 

  end

end


%------------------------------------------------------------------------------

function [rgrid,f,l] = expand_grid( rgrid, grid )
  %
  % *rgrid* is expanded to cover range of *grid*. The output arguments
  % *f* and *l* can be used to expand the data to be interpolated following
  % the usage at the end of this function.
  %
  n1 = length( grid );
  n2 = length( rgrid );
  %
  % Increasing vector
  if grid(2) > grid(1)
    if grid(1) < rgrid(1)
      f = 1;
    else
      f = [];
    end 
    if grid(n1) > rgrid(n2)
      ll = n1; l = n2;
    else
      ll = []; l = [];
    end 
  % Decreasing vector
  else
    if grid(1) > rgrid(1)
      f = 1;
    else
      f = [];
    end 
    if grid(n1) < rgrid(n2)
      ll = n1; l = n2;
    else
      ll = []; l = [];
    end 
  end
  %
  if ~isempty(f)  |  ~isempty(l)
    rgrid = [ grid(f); vec2col(rgrid); grid(ll) ];
  end
  %
return