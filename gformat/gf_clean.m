% GF_CLEAN   Removes grid data for not used dimensions
%
%    Removes unnecessary data (that is, grid data for dimensions not used).
%
% FORMAT   G = gf_clean( G )
%        
% OUT   G   Cleaned data.
% IN    G   Original data.

% 2007-05-14   Created by Patrick Eriksson.

function G = gf_clean(G)
  

d = max( [G.dim] );
 
ready = 0;
  
while ~ready
    
  d = d + 1;
  
  gname = sprintf( 'grid%d', d );

  if isfield( G(1), gname )
    G = rmfield( G, { gname, [gname,'_name'], [gname,'_unit'] } );
  else
    ready = 1;
  end
  
end
