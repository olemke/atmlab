% GFOUT_ARTSXML   Exports gformat data to arts XML GriddedField file 
%
%    Data structure is converted to arts xml correspondance and
%    xmlStore is called, where data type is determined automatically.
%    If length of G is > 1, and ArrayOfGriddedFieldX will ge generated.
%
%    Some information, such as units, will be lost.
%
% FORMAT   gfout_artsxml( D, G, file )
%        
% IN    D       Gformat definition structure.
%       G       Gformat data. 
%       file    Name of file to create.

% 2008-09-25   Created by Patrick Eriksson.

function gfout_artsxml( D, G, file )
  

%- Move data to structure matching GriddedField
%
for i = 1 :length(G)
  X{i}.name     = G(i).NAME;
  X{i}.dataname = G(i).DATA_NAME;
  
  X{i}.data = G(i).DATA;

  for d = 1 : D.DIM
    gname = sprintf( 'GRID%d', d );
    X{i}.grids{d} = G(i).(gname);
    gname = sprintf( 'GRID%d_NAME', d );
    X{i}.gridnames{d} = D.(gname);
  end

end


%- Store
%
dataformat = sprintf( 'GriddedField%d', D.DIM );
%
if length(G) > 1
  dataformat = [ 'ArrayOf', dataformat ]; 
end
%
xmlStore( file, X, dataformat );
