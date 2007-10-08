% GF_GRID_UNION   Finds the union of all grids. 
%
%    The function is suitable to find a common grid for re-interpolation,
%    that ensures that no features are lost in any profile. The comp
%
%    Each dimension is treated seperately. For example, the grid union for
%    dimension 2 is grids{2}. Only dimensions common for complete G array are
%    considered. It is up to the user to ensure that all elements in the array
%    has same physical dimensions (thta is, that all grid1 are of same type
%    etc.).
%
% FORMAT   grids = gf_grid_union(G)
%        
% OUT   grids   Joined grids, as a cell array of vectors
% IN    G       Gridded data.

% 2007-05-15   Created by Patrick Eriksson.

function grids = gf_grid_union(G)


%- Consider only common dimensions, if would differ
%
dims = min( [G.dim] );
 

for d = 1 : dims
  
  grids{d} = [];
  
  for i = 1 : length(G)
    grids{d} = [ grids{d}; getfield( G(i), sprintf('grid%d',d) ) ];
  end
  
  grids{d} = unique( grids{d} );
  
end
