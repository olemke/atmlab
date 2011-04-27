% REGRID  Change of rectangular grid in 1D to 5D
%
%    Conversion of data between two multi-dimensional rectangular
%    grids. Basically an interface to interp1 and interpn. In addition, the
%    function considers the atmlab setting EXTRAP to allow extrapolation. EXTRAP
%    must be set to true or false. 
%
%    The grids of the data to be interpolated (*A*) are packed into the vector
%    array *agrids*. Grids for interpolated data are packed in the same in
%    *newgrids*. The length of these grids determine the size of *B*. 
%
%    All grids must be sorted in ascending order (demand of interpn).
%
%    With EXTRA true, it is accepted to make an extrapolation also for trailing
%    singleton dimensions, which corresponds to that *newgrids* contain more
%    grids than *agrid*.
%
%    The Atmlab convention of that 1D objects (including grids) are column
%    vectors is here strictly followed.
%
%    For point interpolation, see accompanying function *interpd*.
%
% FORMAT   B = regrid(agrids,A,newgrids[,iopt])
%        
% OUT   B          Interpolated data.
% IN    agrids     Grids of A, as an array of vectors.
%       A          Data to be interpolated.
%       newgrids   Grids for interpolation, as an array of vectors.
%       iopt       Interpolation option. See *interpn*. Default is 'linear'.

% 2006-08-22   Created by Patrick Eriksson.


function B = regrid(agrids,A,newgrids,iopt)
%  
if nargin < 4, iopt = 'linear'; end
warning( ['This function has been renamed to *gridinterp*, and this ',...
          'version will be removed. Please change your code.']);
                                                                          %&%
                                                                          %&%
%- Check input                                                            %&%
%                                                                         %&%
rqre_nargin( 3, nargin )                                                  %&%
rqre_datatype( agrids, @iscell );                                         %&%
rqre_datatype( A, @isnumeric );                                           %&%
rqre_datatype( newgrids, @iscell );                                       %&%
indim  = length(agrids);
outdim = length(newgrids);
if dimens(A) > length(agrids)                                             %&%
  error( 'Dimensionality of A is higher than number of given grids.' );   %&%
end                                                                       %&%
if outdim < indim                                                         %&%
  error('There can not be fewer grids in *newgrids* than in *agrids*.');  %&%
end                                                                       %&%
for d = 1 : indim                                                         %&%
  rqre_datatype( agrids{d}, @istensor1, 'Grids in *agrids*' );            %&%
  rqre_gridmatch( A, d, agrids{d}, true );                                %&%
  rqre_datatype( newgrids{d}, @istensor1, 'Grids in *newgrids*' );        %&%
end                                                                       %&%

%--- Extrapolation switch
%                                                                         %&%
atmlab( 'require', {'EXTRAP'} );                                          %&%
%
extrap = atmlab( 'EXTRAP' );
%                                                                         %&%
rqre_datatype( extrap, @isboolean );                                      %&%


%- Check a or determine a's effective dimensions
%
if extrap    % Ignore singleton dimensions
  dims = find( size( A ) > 1 );
  A    = getdims( A, dims );
else
  if outdim ~= indim                                                      %&%
    error( ['With EXTRAP false, the number of grids in *newgrids* ',...   %&%
                                    'and *agrids* must be the same.'] );  %&%
  end                                                                     %&%
  asize = size( A );                                                      %&%
  if length(asize) < outdim  ||  any( asize(1:outdim)==1 )                %&%
    error( ['With EXTRAP false there can not be any singleton ',...       %&%
                                              'dimmensions in *A*.'] );   %&%
  end                                                                     %&%
  dims = 1:outdim;
end

dim = length( dims );

if dim == 0
  %
  B = A;
  
elseif dim == 1
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
  else
    xi = newgrids{dims(1)};
  end
  %                                                                     %&%
  if isempty(xi)                                                        %&%
    error('Empty grid found in *newgrid* for non-singleton dimension.');%&%
  end                                                                   %&%
  %
  B = interp1( agrids{dims(1)}, A, xi, iopt );

elseif dim == 2
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
    yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
  else
    xi = newgrids{dims(1)};
    yi = newgrids{dims(2)};
  end
  %                                                                     %&%
  if isempty(xi)|isempty(yi)                                            %&%
    error('Empty grid found in *newgrid* for non-singleton dimension.');%&%
  end                                                                   %&%
  %
  [xi,yi] = ndgrid( xi, yi );
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, A, xi, yi, iopt ); 

elseif dim == 3
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
    yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
    zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
  else
    xi = newgrids{dims(1)};
    yi = newgrids{dims(2)};
    zi = newgrids{dims(3)};
  end
  %                                                                     %&%
  if isempty(xi)|isempty(yi)|isempty(zi)                                %&%
    error('Empty grid found in *newgrid* for non-singleton dimension.');%&%
  end                                                                   %&%
  %
  [xi,yi,zi] = ndgrid( xi, yi, zi );
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
                                                      A, xi, yi, zi, iopt ); 

elseif dim == 4
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
    yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
    zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
    ui = handle_expand( agrids{dims(4)}, newgrids{dims(4)} );
  else
    xi = newgrids{dims(1)};
    yi = newgrids{dims(2)};
    zi = newgrids{dims(3)};
    ui = newgrids{dims(4)};
  end
  %                                                                     %&%
  if isempty(xi)|isempty(yi)|isempty(zi)|isempty(ui)                    %&%
    error('Empty grid found in *newgrid* for non-singleton dimension.');%&%
  end                                                                   %&%
  %
  [xi,yi,zi,ui] = ndgrid( xi, yi, zi, ui );
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, ...
               agrids{dims(3)}, agrids{dims(4)}, A, xi, yi, zi, ui, iopt ); 

elseif dim == 5
  %
  if extrap
    xi = handle_expand( agrids{dims(1)}, newgrids{dims(1)} );
    yi = handle_expand( agrids{dims(2)}, newgrids{dims(2)} );
    zi = handle_expand( agrids{dims(3)}, newgrids{dims(3)} );
    ui = handle_expand( agrids{dims(4)}, newgrids{dims(4)} );
    vi = handle_expand( agrids{dims(5)}, newgrids{dims(5)} );
  else
    xi = newgrids{dims(1)};
    yi = newgrids{dims(2)};
    zi = newgrids{dims(3)};
    ui = newgrids{dims(4)};
    vi = newgrids{dims(5)};
  end
  %                                                                     %&%
  if isempty(xi)|isempty(yi)|isempty(zi)|isempty(ui)|isempty(vi)        %&%
    error('Empty grid found in *newgrid* for non-singleton dimension.');%&%
  end                                                                   %&%
  %
  [xi,yi,zi,ui,vi] = ndgrid( xi, yi, zi, ui, vi );
  %
  B = interpn( agrids{dims(1)}, agrids{dims(2)}, agrids{dims(3)}, ...
               agrids{dims(4)}, agrids{dims(5)}, A, xi, yi, zi, ui, vi, iopt ); 

else                                                             %&%
  error( 'Interpolation above 5D is not handled.' );             %&%
end


%- Post-processing for EXTRAP
%
if extrap  &  dim < outdim
  % Make extrapolation for A's singleton dimensions
  map = ones( 1, max([2 outdim]) ); % Repmat demands at least two values
  lg  = ones( 1, max([2 outdim]) ); 
  for d = 1 : outdim
    lg(d) = max([ 1 length( newgrids{d} ) ] );  % The 1 to handle empty grids
    if ~any( dims == d )  &  lg(d) > 1          % for singleton dimensions
      map(d) = length( newgrids{d} );
    end
  end
  if any( map > 1 )
    B = repmat( B, map );
  end

  % Full dimension is not obtained above for some cases of singleton
  % dimensions. Fixed by a reshape
  bsize = size(B);  
  if length(bsize) < length(lg)  |  any( bsize ~= lg )
    B = reshape( B, lg );
  end
end

return



%---
function xi = handle_expand(x,xi)
  %
  v1 = min( x );
  i1 = find( xi<v1 );
  %
  v2 = max( x );
  i2 = find( xi>v2 );
  %
  if ~isempty(v1) 
    xi(i1) = v1;
  end
  %
  if ~isempty(v2) 
    xi(i2) = v2;
  end
  %
return