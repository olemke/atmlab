% GF_SET   Direct setting of gformat data
%
%    To insert the matrix A in G:
%      G = gf_Set( D, g_empty, {grid1,grid2}, A );
%
%    To set G to a scalar:
%      G = gf_set( D, g_empty, [], 1e3 );
%   
%    To insert the vector v in G along dimension 2:
%      G = gf_set( D, g_empty, grid2, v, 2 );
%
% FORMAT   G = gf_set( D, G, grids, data, dims )
%        
% OUT   G       Modified gformat data.
% IN    D       Gformat definition structure
%       G       Original gformat data.
%       grids   Grids corresponding to data, given as an array of vectors.
%               A single grid can also be given as a vector.
%       data    Data to be inserted.
% OPT   dims    Data dimensions corresponding to *data*. Default is 
%               to assign data to the n first data dimensions, where n is
%               the dimensionality of *data*.

% 2007-10-17   Created by Patrick Eriksson.

function G = gf_set( D, G, grids, data, dims )


%- Default values
%
dims_DEFAULT = [];
%
set_defaults;

  
%- Check input
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );
rqre_datatype( {'empty','vector','cell'}, grids );
rqre_datatype( 'numeric', data );
rqre_datatype( {'empty','vector'}, dims );


%- Handle different input versions
%
if ~isempty(grids)  &  isnumeric( grids )
  grids = { grids };
end
%
% *dims* handled below


%- Check dimensionalities
%
indim = length( grids ); 
%
if indim == 0
  if ~isscalar( data )
    error( 'No grids are given, but *data* is not a scalar.' );
  end
else
  for id = 1 : indim
    if size(data,id) ~= length(grids{id})
      error( sprintf( ...
         'Mismatch between *grids* and *data* for data dimension %d.', id ) );
    end
  end
end
%
if indim > D.DIM
  error( [ 'Input has a higher dimensionality than handled by present ',...
           'format (defined by *D*).' ] );
end
if isempty( dims )
  if indim == 0
    dims = [];
  else
    dims = 1 : indim;
  end
elseif any( diff(dims) < 1 )
  error( ['Input argument *dims* must be sorted in ascending order, ',...
          'with no dimensions repeated.'] );
elseif length(dims) ~= indim
  error( 'Mismatch between *grids* and *dims*.' );
end


%- Reshape map
%
n = ones( 1, D.DIM );
%
for id = 1 : length( grids )
  n(dims(id)) = length( grids{id} );
end


for ig = 1 : length(G)

  G(ig).DATA = reshape( data, n );
  G(ig).DIMS = dims;
  
  for id = 1 : length( grids )
    G(ig).(sprintf('GRID%d',dims(id))) = grids{id};
  end
  
end
