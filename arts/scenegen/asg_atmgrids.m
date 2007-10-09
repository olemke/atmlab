% ASG_ATMGRIDS   Automatic selectio of the atmospheric grids
%
%    The following ASG fields are considered:
%       ATMOSPHERE_DIM
%       P_GRID
%       LAT_GRID
%       LON_GRID
%
%    If any of these grids are set to a scalar, a grid is created by taking the
%    union of all corresponding grids in G (by *gf_grid_union*). The given
%    scalar value is used as minimum distance between grid points (see input
%    argument *mindx* in *gridthinning*). 
%
%    The unit for scalar P_GRID is pressure decades. Normal values should
%    accordingly be in the order of 0.01 (roughly equal to 200/16e3).
%
% FORMAT   A = asg_atmgrids( A, G )
%        
% OUT   A   As input *A* but with P_GRID, LAT_GRID and LON_GRID possibly 
%           modified.
% IN    A   Settings for arts scene generator.
%       G   Data (in gformat).

% 2007-10-09   Created by Patrick Eriksson


function A = asg_atmgrids( A, G )

  
%- Basic check of A and G
%
qcheck( @asg, A );
%
if any( [G(:).dim] ~= A.ATMOSPHERE_DIM )
  error( ['One or several items in *G* has other dimensionality than ' ...
          'A.ATMOSPHERE_DIM.'] );
end


grids = [];


%- P_GRID
%
if isnan( A.P_GRID )
  error( 'NaN found for A.P_GRID' );
end
%
if isscalar( A.P_GRID )
  grids    = gf_grid_union( G );  % Comes as increasing vector
  grids{1} = flipud( vec2col( grids{1} ) );
  A.P_GRID = 10.^[-gridthinning( -log10(grids{1}), A.P_GRID )];
elseif isvector( A.P_GRID )
  %
else
  error( 'A.P_GRID must be a scalar or a vector.' );
end


%- LAT_GRID
%
if A.ATMOSPHERE_DIM >= 2
  if isnan( A.LAT_GRID )
    error( 'NaN found for A.LAT_GRID' );
  end
  %
  if isscalar( A.LAT_GRID )
    if isempty( grids )
      grids = gf_grid_union( G );
    end
    A.LAT_GRID = gridthinning( grids{1}, A.LAT_GRID );
  elseif isvector( A.LAT_GRID )
    %
  else
    error( 'A.LAT_GRID must be a scalar or a vector.' );
  end
end


%- LON_GRID
%
if A.ATMOSPHERE_DIM >= 3
  if isnan( A.LON_GRID )
    error( 'NaN found for A.LON_GRID' );
  end
  %
  if isscalar( A.LON_GRID )
    if isempty( grids )
      grids = gf_grid_union( G );
    end
    A.LON_GRID = gridthinning( grids{1}, A.LON_GRID );
  elseif isvector( A.LON_GRID )
    %
  else
    error( 'A.LON_GRID must be a scalar or a vector.' );
  end
end


  