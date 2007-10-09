% ASG_REGRID   Re-gridding of data based on ASG settings
%
%    Re-grids the input data. New grids depend on the following ASG
%    fields:
%       P_GRID
%       LAT_GRID
%       LON_GRID
%
%    If any of these grids are set to a scalar, a grid is created by taking the
%    union of all corresponding grids in G (by *gf_grid_union*). The given
%    scalar value is used as minimum distance between grid points (see input
%    argument *mindx* in *gridthinning*). Note unit here for P_GRID (see 
%    below).
%
%    Otherwise, given values are taken as pre-defined grid. These grids must
%    accordingly have a length >=2, that is also a demand of ARTS.
%
%    Interpolation and grid unions are performed after conversion to pressure
%    decades. Scalar P_GRID is also given in pressure decades.
%
% FORMAT   G = asg_regrid( A, G [,a_surface] )
%        
% OUT   G           Re-gridded data.
% IN    A           Settings for arts scene generator.
%       G           Data (in gformat).
% OPT   a_surface   Set to true if G contains "surface data" (e.g. data for
%                   r_geoid and z_surface).

% 2007-10-08   Created by Patrick Eriksson


function G = asg_regrid(A,G,a_surface)

if nargin < 3
  a_surface = false;
end


%- Basic check of A
%
qcheck( @asg, A );


%- Extract A settings
%
dim = A.ATMOSPHERE_DIM;
%
if a_surface
  if dim == 0
    return     % Nothing to do
  end
  if dim >= 2
    grid1 = A.LAT_GRID;
  end
  if dim >= 3
    grid2 = A.LON_GRID;
  end
else
  if dim >= 1
    grid1 = A.P_GRID;
    %
    % Convert to pressure decades
    G = gf_grid_convert( G, 1, 0, @log10, 1 );
    if length(grid1) > 1
      grid1 = -log10( grid1 );
    end
  end
  if dim >= 2
    grid2 = A.LAT_GRID;
  end
  if dim >= 3
    grid3 = A.LON_GRID;
  end
end



%- Set template structure
%
grids = [];
%
Gtmplt.dim = dim;
%
for id = 1 : dim
    
  switch id
    
   case 1
    %
    if length( grid1 ) == 1
      grids        = gf_grid_union(G);
      Gtmplt.grid1 = gridthinning( grids{1}, grid1 );
   else
      Gtmplt.grid1 = grid1;
    end
    %
    Gtmplt.grid1 = vec2col( Gtmplt.grid1 );

   case 2
    %
    if length( grid2 ) == 1
      if isempty(grids)
        grids      = gf_grid_union(G);
      end
      Gtmplt.grid2 = gridthinning( grids{2}, grid2 );
    else
      Gtmplt.grid2 = grid2;
    end
    %
    Gtmplt.grid2 = vec2col( Gtmplt.grid2 );

   case 3
    %
    if length( grid3 ) == 1
      if isempty(grids)
        grids      = gf_grid_union(G);
      end
      Gtmplt.grid3 = gridthinning( grids{3}, grid3 );
    else
      Gtmplt.grid3 = grid3;
    end
    %
    Gtmplt.grid3 = vec2col( Gtmplt.grid3 );
    
  end
end


    
%- Do regridding
%
G = gf_regrid( G, Gtmplt, 'linear' );



%- Convert back from pressure decades
%
if ~a_surface
  G = gf_grid_convert( G, 1, 1, @pow10 );
end

