% GF_GRID_CONVERT   Conversion of grid unit for gformat data
%
%    This function allows a change of grid unit. Basically an interface to
%    *gridconvert*. See that function for further specification of *precs*,
%    *mapfun*, and *postcs*.
%
%    The conversion is performed only for items of G where *dim* is part of
%    used dimensions (defined by field DIMS).
%
%    To convert a pressure grid to increasing "pressure decades":
%       G = gf_grid_convert( D, G, 1, 0, @log10, 1 );
%    The reversed conversion is:
%       G = gf_grid_convert( D, G, 1, 1, @pow10 );
%
% FORMAT   G = gf_grid_convert( D, G, dim, precs, mapfun, postcs )
%        
% OUT   G   Transformed gformat data.
% IN    D   Gformat definition structure
%       G   Original gformat data.
% OPT   dim      Data dimension for which grid shall be converted.
%                Default is 1.
%       precs    See *gridconvert*. Defult is false.
%       mapfun   See *gridconvert*. Default is [].
%       postcs   See *gridconvert*. Defult is false.

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_grid_convert( D, G, dim, precs, mapfun, postcs )

%- Default values
%
dim_DEFAULT    = 1;
precs_DEFAULT  = 0;
mapfun_DEFAULT = [];
postcs_DEFAULT = 0;
%
set_defaults;


%- Check input
%
rqre_datatype( 'struct', D );
rqre_datatype( 'struct', G );
rqre_field( D, 'DIM', 0 );
rqre_field( G, 'DIMS', 0 );
rqre_scalar( 'input argument *dim*', dim, 1 );
if D.DIM < dim
  error( 'Value of *dim* must be in range [1,D.DIM].' );
end
rqre_bool( 'input argument *precs*', precs );
rqre_bool( 'input argument *postcs*', postcs );
%
if ~isempty(mapfun)  &  ~isa( mapfun, 'function_handle' )
  error( 'Input *mapfun* must be empty or a function handle.' );
end




gridname = sprintf( 'GRID%d', dim );
  

for ig = 1 : length( G )

  if any( dim == G(ig).DIMS )
    
    G(ig).(gridname) = gridconvert( G(ig).(gridname), precs, mapfun, postcs );
    
  end
  
end

