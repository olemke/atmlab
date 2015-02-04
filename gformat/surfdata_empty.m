% SURFDATA_EMPTY   Creates an empty and minimal surfdata structure
%
%    The returned structure has the minimal set of fields for the selected
%    dimensionality. Most fields are set to be empty. Exceptions:
%
%       DIM is set to *dim* 
%
%       TYPE is set to 'surfdata'.
%    
%       Grid names and grid units are set as described in *issurfdata*,
%       beside GRID3_NAME that is set to '?'.
%
% FORMAT   G = surfdata_empty( [ dim ] )
%        
% OUT   G     Created atmlab structure.
% OPT   dim   Dimensionality. Default is 0. Max is 4.

% 2014-08-26   Created by Bengt Rydberg.

function G = surfdata_empty( dim )
%
if nargin < 1  |  isempty(dim)
  dim = 0;
end
 
G           = gf_empty( dim );
G.TYPE      = 'surfdata';

% If dim iswhole etc. is checked by gf_empty, but we need to check:
if atmlab('STRICT_ASSERT') & ( dim<0 | dim>4 )
  error( 'Input argument must be between 0 and 4.' );
end




% Any changes here must be described in header of *isatmdata* !!!
  
grid_names  = { 'Latitude', 'Longitude', '?', 'Hour' };
grid_units  = { 'deg', 'deg', '', '' };

for d = 1 : dim
  G = gf_set_grid( G, d, [], grid_names{d}, grid_units{d} );
end

