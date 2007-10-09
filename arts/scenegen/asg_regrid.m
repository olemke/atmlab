% ASG_REGRID   Re-gridding of data based on ASG settings
%
%    The following ASG fields are considered:
%       ATMOSPHERE_DIM
%       P_GRID
%       LAT_GRID
%       LON_GRID
%
%    The data are re-gridded to match P_GRID, LAT_GRID and LON_GRID. 
%    These grids must be set before calling this function (that is, scalar
%    input is not allowed as for *asg_atmgrids*).
%
%    Interpolation in pressure is performed after conversion to pressure
%    decades. 
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


%- Basic check of input
%
qcheck( @asg, A );



%- Create a template G for re-gridding 
%
% And convert to pressure decades for pressure diemsnion
%
if a_surface
  if any( [G(:).dim] ~= A.ATMOSPHERE_DIM-1 )
    error( ['One or several items in *G* has a dimensionality that is ' ...
            'inconsistent with A.ATMOSPHERE_DIM for a surface.'] );
  end

  Gtmplt.dim   = A.ATMOSPHERE_DIM - 1;

  if A.ATMOSPHERE_DIM == 1
    return  % Nothing to do
  end
  if A.ATMOSPHERE_DIM >= 2
    Gtmplt.grid1 = A.LAT_GRID;
  end
  if A.ATMOSPHERE_DIM >= 3
    Gtmplt.grid2 = A.LON_GRID;
  end

else
  if any( [G(:).dim] ~= A.ATMOSPHERE_DIM )
    error( ['One or several items in *G* has other dimensionality than ' ...
            'A.ATMOSPHERE_DIM.'] );
  end

  Gtmplt.dim   = A.ATMOSPHERE_DIM;

  Gtmplt.grid1 = -log10( A.P_GRID ); 
  G            = gf_grid_convert( G, 1, 0, @log10, 1 );

  if A.ATMOSPHERE_DIM >= 2
    Gtmplt.grid2 = A.LAT_GRID;
  end
  if A.ATMOSPHERE_DIM >= 3
    Gtmplt.grid3 = A.LON_GRID;
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

