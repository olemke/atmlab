% GF_DIMCROP   Remove trailing singleton dimensions
%
%    In short, the data are set to G.DIM = newdim and not used grids are
%    removed.
%
%    There is an error if any dimension of G.DATA that is removed not have
%    size 1. 
%
%    The function is "vectorised". That is, can be called as
%      G(2:3) = gf_regrid( G(2:3), ...
%
% FORMAT   G = gf_dimcrop( G, newdim )
%
% OUT   G      Re-grided gformat data.
% IN    G      Original gformat data.
%       newdim New dimension of data

% 2015-01-15   Created by Patrick Eriksson.

function G = gf_dimcrop( G, newdim )
%
if atmlab('STRICT_ASSERT')
  rqre_datatype( G, @isgformat );
  rqre_alltypes( newdim, {@istensor0,@iswhole} );
  rqre_in_range( newdim, 0 );
  %
  for i = 1 : length( G )
    for d = newdim+1  : G(i).DIM
      if size( G(i).DATA, d ) > 1
        error( sprintf( ...
            'You tried to remove a non-singleton dimension for G(%d)',i) );
      end
    end
  end
end
    

for d = newdim+1  : G(i).DIM
  name1 = sprintf( 'GRID%d', d );
  name2 = sprintf( '%s_NAME', name1 );
  name3 = sprintf( '%s_UNIT', name1 );
  G     = rmfield( G, { name1, name2, name3 } );
end

[G.DIM] = deal( newdim );

