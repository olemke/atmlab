% GF_GET_GRID   Gets gformat grid data
%
%    The fields GRIDx, GRIDx_NAME and GRIDx_UNIT can be extracted with the
%    function, where x is *dim*.
%
% FORMAT   G = gf_set_grid( G, dim, grid [, name, unit ] )
%        
% OUT   grid  Grid.
%       name  Grid name.
%       unit  Grid unit.
% IN    G     A gformat structure.
%       dim   Dimension.

% 2010-01-06   Created by Patrick Eriksson.

function [grid,name,unit] = gf_get_grid( G, dim )
                                                                %&%
rqre_nargin( 2, nargin );                                       %&%
rqre_datatype( G, @isstruct );                                  %&%
rqre_alltypes( dim, {@istensor0,@iswhole} );                    %&%
rqre_in_range( dim, 1 );                                        %&%


bname = sprintf( 'GRID%d', dim );

rqre_field( G, bname );                                         %&%
grid = G.(bname);
  
if nargout >= 2
  fname = [ bname, '_NAME' ]; 
  rqre_field( G, fname );                                       %&%
  name = G.(fname);
  if nargout >= 2
    fname = [ bname, '_UNIT' ]; 
    rqre_field( G, fname );                                     %&%
    unit = G.(fname);
  end
end
