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
    
    if any( d == G(i).DIMS )
      if ~isfield( G, gname )
        error( sprintf( '%s is missing in G', gname ) );
      end
      l = length(G.(gname));
    else
      l = 1;
    end
  
    if l ~= size(G.DATA,d)
      fprintf( '\nG.DIMS          :' );      
      fprintf( ' %d', G.DIMS );
      fprintf( '\nSize of G.DATA  :' );
      fprintf( ' %d', size(G.DATA) );
      fprintf( '\nLength of %s : %d\n\n', gname, l );
      error( sprintf( ...
          'Inconsistency between G.DIMS, %s or G(%d).DATA (see above).',...
                      gname, i ) ); 
    end
  end
end

