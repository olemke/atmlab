% GF_GRID_UNION   Finds the union of all grids. 
%
%    The function is suitable to find a common grid for re-interpolation,
%    that ensures that no features are lost in any profile.
%
%    Dimensions to consider are selected by *dims*. Each of these dimensions is
%    treated seperately. For example, the grid union for dimension
%    corresponding to element 2 of *dims* is grids{2}. Items of G for which
%    the selected dimension is not active, are automatically skipped.
%
% FORMAT   grids = gf_grid_union(D,G,dims)
%        
% OUT   grids   Joined grids, as a cell array of vectors
% IN    D       Gformat definition structure
%       G       Original gformat data.
%       dims    Data dimensions to consider, as a vector of integers.


% 2007-05-15   Created by Patrick Eriksson.

function grids = gf_grid_union(D,G,dims)


%- Some basic checks
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );
%  
if any( dims < 1  |  dims > D.DIM )
  error( 'All elements in *dims* must be in range [1,D.DIM]' );
end


for id = 1 : length( dims )
  
  grids{id} = [];
  
  gridname = sprintf( 'GRID%d', dims(id) );
  
  for ig = 1 : length(G)
    
    if any( G(ig).DIMS == dims(id) ) 
    
      grids{id} = [ grids{id}; vec2col( getfield( G(ig), gridname ) ) ];
    
    end
  
  end

  grids{id} = unique( grids{id} );

end
