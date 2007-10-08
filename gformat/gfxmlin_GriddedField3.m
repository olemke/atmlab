% GFXMLIN_GRIDDEDFIELD3
%
%    Imports data having the arts xml GriddedField3 format. Imports either
%    directly from file, or from corresponding matlab structure. 
%
% FORMAT   G = gfxmlin_GriddedField3( data [, name, type] )
%        
% OUT   G          Imported data.
% IN    data       Data, or name on xml file to read.
% OPT   name       Name of data. Default is [].
%       type       Type of data. Default is []. Recognised options are
%                     'vmr' : volume mixing ratio
%                     't'   : temperature
%                     'z'   : altitude

% 2007-05-14   Created by Patrick Eriksson.


function G = gfxmlin_GriddedField3( data, name, type )
  

if nargin < 2
  name = [];
end

if nargin < 3
  type = [];
end
  
if ischar( data )
  G.source = data;
  data = xmlLoad( data );
else
  G.source = 'Matlab data';
end

G.name       = name;
G.dim        = dimens( data.data );
G.data       = data.data;

if isempty( type ) 
  G.data_name  = '?';
  G.data_unit  = '?';
elseif strcmp( lower(type), 'vmr' )
  G.data_name  = 'Volume mixing ratio';
  G.data_unit  = '-';
elseif strcmp( lower(type), 't' )
  G.data_name  = 'Temperature';
  G.data_unit  = 'K';
elseif strcmp( lower(type), 'z' )
  G.data_name  = 'Altitude';
  G.data_unit  = 'm';
else
  error(' Unknown selection for *type*.' );  
end

G.grid1      = data.p_grid;
G.grid1_name = 'Pressure';
G.grid1_unit = 'Pa';

G.grid2      = data.lat_grid;
G.grid2_name = 'Latitude';
G.grid2_unit = 'deg';

G.grid3      = data.lon_grid;
G.grid3_name = 'Longitude';
G.grid3_unit = 'deg';

G = orderfields( G );