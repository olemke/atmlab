% GF_GRID_CONVERT   Conversion of grid unit
%
%    This function allows a change of grid unit. The conversion of a grid g
%    can be expressed as:
%
%       g = -(postcs~=1) * mapfun( -(precs~=1)*g )
%
%    To convert a pressure grid to increasing "pressure decades":
%       gf_grid_convert( p_grid, [], 0, @log10, 1 )
%    The reveresed conversion is:
%       gf_grid_convert( p_grid, [], 1, @pow10 )
%
% FORMAT   G = gf_grid_convert( G [, dim, precs, mapfun, postcs] )
%        
% OUT   G        Data with converted grid.
% IN    G        Original data. Either in g-format or as a plain vector.
% OPT   dim      Data dimension for which grid shall be converted.
%                Default is 1.
%       precs    Change sign before applying *mapfun*. Defult is false.
%       mapfun   Mapping function. No mapping if empty, which is default.
%       postcs   Change sign after applying *mapfun*. Defult is false.

% 2007-05-15   Created by Patrick Eriksson.


function G = gf_grid_convert( G, dim, precs, mapfun, postcs )

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
if ~isempty(mapfun)  &  ~isa( mapfun, 'function_handle' )
  error( 'Input *mapfun* must be empty or a finction handle.' );
end


%- Handle ordinary vectors
%
vecopt = 0;
%
if isvector(G)  & isnumeric(G)
  vecopt  = 1;
  dim     = 1;
  g       = G;
  G       = [];
  G.grid1 = g;
  G.dim   = 1;
end

gridname = sprintf('grid%d',dim);
  
for i = 1 : length( G )

  if G(i).dim < dim
        error( sprintf( 'Selected dimension too high for G(%d).', i ) );
  end

  g = G(i).(gridname);
  
  if precs
    g = -g;
  end
  
  if ~isempty( mapfun )
    g = mapfun( g );
  end

  if postcs
    g = -g;
  end
    
  G(i).(gridname) = g;
  
end


if vecopt
  g = G.grid1;
  G = [];
  G = g;
end