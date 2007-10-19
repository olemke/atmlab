% GF_INCREASE_DIM   Increase dimension of gformat data
%
%    Existing data are repeated to fill added dimensions. 
%
%    To e.g. expand 1D data to 2D, covering the range [-90 90], do
%       G = gf_increase_dim( D, G, 2, {[-90 90]} );
%
% FORMAT   G = gf_increase_dim( D, G, newdims, grids )
%        
% OUT   G         Expanded data.
% IN    D         Gformat definition structure
%       G         Original gformat data.
%       newdims   Data dimensions to be added, as a vector of integers.
%       grids     Grids for new dimensions. An array of vectors, with same
%                 length as *newdims*.

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_increase_dim( D, G, newdims, grids )


%- Check input
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );
rqre_datatype( 'vector', newdims );
rqre_datatype( 'cell', grids );
%
newdims = vec2row( newdims );
%
if max(newdims) > D.DIM
  error( 'You have selected a dimension (in *newdims*) above D.DIM.' );
end
%
if any( diff(newdims) < 1 )
  error( ['Input argument *newdims* must be sorted in ascending order, ',...
          'with no dimensions repeated.'] );
end
%
if length(newdims) ~= length(grids)
  error( 'Difference in length between *newdims* and *grids*.' );
end


for ig = 1 : length(G)

  if isempty(G(ig).DIMS)
    maxdim = 0;
  else
    maxdim = G(ig).DIMS(end); 
  end
  
  if maxdim >= newdims(1)
    error( sprintf( ['Not all new dimensions (*newdim*) above highest ',...
                     'value of G(%d).DIMS.'], ig ) ); 
  end
  
  %- Create mapdata and include grids
  %
  % The *mapdata* vector must start with 1, matching highest old dimension
  % if maxdim > 0.
  %
  if maxdim
    dimos = 1;  % Old >= 1D
  else
    dimos = 0;    % Old = 0D
  end 
  %  
  mapdata = ones( 1, newdims(end)-maxdim+dimos ); 

  
  for id = 1 : length(newdims)
    mapdata(newdims(id)-maxdim+dimos)     = length( grids{id} );
    G(ig).(sprintf('GRID%d',newdims(id))) = grids{id};
  end
  
  G(ig).DIMS = [ vec2row(G(ig).DIMS), newdims ];
  G(ig).DATA = repmat( G(ig).DATA, mapdata );

end
