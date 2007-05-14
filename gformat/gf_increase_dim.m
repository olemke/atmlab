% GF_INCREASE_DIM   Increase dimension 
%
%    Existing data are repeated to fill added dimensions. Grid size, name
%    and unit for added dimensions are taken from *Gtmplt*.
%
% FORMAT   G = gf_increase_dim( G, newdim, Gtmplt )
%        
% OUT   G        Expanded data.
% IN    G        Original data.
%       newdim   New dimension.
%       Gtmplt   Grid data for new dimensions are taken from (first element of
%                this structure. 

% 2007-05-14   Created by Patrick Eriksson.


function G = gf_increase_dim( G, newdim, Gtmplt )

  
if Gtmplt(1).dim < newdim 
  error( 'Dimension of template data (Gtmplt) lower than *newdim*' );
end

for i = 1 : length(G)

  mapdata = ones( 1, newdim );
  
  for d = G(i).dim+1 : newdim

    % Copy grid data
    gname = sprintf( 'grid%d', d );

    G(i).(gname)           = getfield( Gtmplt(1), gname );
    G(i).([gname,'_name']) = getfield( Gtmplt(1), [gname,'_name'] );
    G(i).([gname,'_unit']) = getfield( Gtmplt(1), [gname,'_unit'] );

    mapdata(d) = length( getfield( Gtmplt(1), gname ) );
  end

  G(i).dim  = newdim;
  G(i).data = repmat( G(i).data, mapdata );
end
