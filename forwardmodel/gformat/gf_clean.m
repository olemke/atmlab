% GF_CLEAN   Removes grid for not used dimensions
%
%    Removes unnecessary data. That is, grid data for dimensions not used.
%   
% FORMAT   G = gf_clean( D, G )
%        
% OUT   G   Cleaned gformat data.
% IN    D   Gformat definition structure
%       G   Original gformat data.

% 2007-10-17   Created by Patrick Eriksson.

function G = gf_clean(D,G)


%- Check input
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );


for ig = 1 : length(G)
  
  for id = 1 : D.DIM
    
    if ~any( id == G(ig).DIMS)
      
      G(ig).(sprintf('GRID%d',id)) = [];
    
    end
  end
end
