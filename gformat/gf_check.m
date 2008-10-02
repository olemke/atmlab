% GF_CHECK   Simple check of fdata consistency of gformat data
%
%    It is checked if grids exist and that grids and DATA match in size.
%
% FORMAT   gf_check( D, G )
%        
% IN    D       Gformat definition structure.
%       G       Gformat data. 

% 2008-10-01   Created by Patrick Eriksson.

function gf_check( D, G )
  

for i = 1:length(G)

  for d = 1 : D.DIM
    gname = sprintf( 'GRID%d', d );
  
    if ~isfield( G, gname )
      error( sprintf( '%s is missing in G', gname ) );
    end
  
    if length(G.(gname)) ~= size(G.DATA,d)
      fprintf( '\nSize of G.DATA  :' );
      fprintf( ' %d', size(G.DATA) );
      fprintf( '\nLength of %s : %d\n\n', gname, length(G.(gname)) );
      error( sprintf('Size mismatch between %s and G(%d).DATA (see above).',...
                      gname, i ) ); 
    end
  end
end

