% GF_DECREASE_DIM   Decrease dimension of gformat data
%
%    The data are cropped based on pattern provided by *ind*. 
%
%    The vector *ind* represents index for each data dimension (in *G*). For
%    data dimensions to remove, the index for the position to keep is
%    given. For dimensions to keep, NaN is given. 
%
%    For example,
%       Gnew = gf_decrease_dim( G, [1 NaN NaN] )
%    converts 3D data to 2D, where the slice corresponding to position 1 of
%    dimension 1 is kept.
%
% FORMAT   Gnew = gf_decrease_dim( G, ind )
%        
% OUT   Gnew  Cropped data.
% IN    G     Original data.
%       ind   Cropping pattern. See above.

% 2007-10-09   Created by Patrick Eriksson.

function Gnew = gf_decrease_dim( G, ind )
  

olddims = find( isnan(ind) );          % Which old dimensions to keep
newdim  = length( olddims );           % New dimensionality
lnew    = ones( 1, max([newdim,2]) );  % Data size for dimensions to
                                       % keep. Used for reshape, that demends
                                       % at least 2 values  

for ig = 1 : length(G)

  Gnew(ig).name      = G(ig).name;
  Gnew(ig).source    = G(ig).source;
  Gnew(ig).dim       = newdim;
  Gnew(ig).data_name = G(ig).data_name;
  Gnew(ig).data_unit = G(ig).data_unit;
  
  %- Copy grids
  %
  for id = 1 : newdim
    %
    gnew = sprintf( 'grid%d', id );
    gold = sprintf( 'grid%d', olddims(id) );
    %
    Gnew(ig).(gnew)           = getfield( G(ig), gold );
    Gnew(ig).([gnew,'_name']) = getfield( G(ig), [gold,'_name'] );
    Gnew(ig).([gnew,'_unit']) = getfield( G(ig), [gold,'_unit'] );
  end

  %- Handle G(ig).data
  %
  inew = 0;
  %
  for id = 1 : length(ind)
    if isnan(ind(id))
      inew       = inew + 1;  
      lnew(inew) = size(G(ig).data,id);
      ii{id}     = colon(1,lnew(inew));
    else
      ii{id}     = ind(id);
    end
  end
  %
  Gnew(ig).data = reshape( G(ig).data(ii{:}), lnew );
  
end

%- Sort fields
%
Gnew = orderfields( Gnew );