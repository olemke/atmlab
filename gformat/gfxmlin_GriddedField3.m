% GFXMLIN_GRIDDEDFIELD3   Import of XML GriddedField3 data to gformat 
%
%    Imports data having the arts xml GriddedField3 format. Imports either
%    directly from file, or from corresponding matlab structure. 
%
%    If no format is specified (that is, empty D and G), D is set to match 
%    the definition of the GriddedField3 type:
%       D.DIM        = 3;
%       D.GRID1_NAME = 'Pressure';
%       D.GRID1_UNIT = 'Pa';
%       D.GRID2_NAME = 'Latitude';
%       D.GRID2_UNIT = 'deg';
%       D.GRID3_NAME = 'Longitude';
%       D.GRID3_UNIT = 'deg';
%
% FORMAT   G = gfxmlin_GriddedField3( D, G, data, name, type, dims )
%        
% OUT   G       Imported data.
%       D       Gformat definition structure.
% IN    D       Gformat definition structure. Can be empty. See above.
%       G       Original gformat data. Can be empty. See above.
%       data    Data, or name on xml file to read.
% OPT   name    Name of data. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr' : volume mixing ratio
%                  't'   : temperature
%                  'z'   : altitude
%       dims    Dimensions corresponding to pressure, latitude and
%               longitude. If not given, an attempt to determine these
%               dimensions from grid names in D is made. 

% 2007-05-14   Created by Patrick Eriksson.


function [G,D] = gfxmlin_GriddedField3( D, G, data, name, type, dims )
  

%- Default values
%
if isempty(D)
  D.DIM        = 3;
  D.GRID1_NAME = 'Pressure';
  D.GRID1_UNIT = 'Pa';
  D.GRID2_NAME = 'Latitude';
  D.GRID2_UNIT = 'deg';
  D.GRID3_NAME = 'Longitude';
  D.GRID3_UNIT = 'deg';
  G            = [];
end
%
name_DEFAULT = [];
type_DEFAULT = [];
dims_DEFAULT = [];
%
set_defaults;


%- Determine dims, if not specified
%
if D.DIM < 3
  error( 'D.DIM must be >= 3 to accommodate data of type GriddedField3.' ); 
end
%
if isempty( dims )
  dims = [ 0 0 0 ];
  for id = 1 : D.DIM
    gname = lower( D.(sprintf('GRID%d_NAME',id)) );
    if strncmp( gname, 'pressure', 8 )
      dims(1) = id;
    elseif strncmp( gname, 'latitude', 8 )
      dims(2) = id;
    elseif strncmp( gname, 'longitude', 8 )
      dims(3) = id;
    end
  end
  if any( dims == 0 )
    error( [ 'Automatic setting of *dims* failed. Pressure, latitude or ',...
             'longitude was nof found among the grid names.' ] );
  end
else
  if length(dims) ~= 3  | any( diff(dims) < 1 ) 
    error( ['Input argument *dims* must be a vector length 3 sorted in ',...
            'ascending order with no dimensions repeated.'] );
  end
end


%- "Load" data
%
if ischar( data )
  [G.SOURCE] = deal( data );
  data          = xmlLoad( data );
else
  [G.SOURCE] = deal( 'Matlab data' );
end
%
[G.NAME] = deal( name );



%- What is dimensionality of loaded data
%
dims = dims( 1 : dimens( data.data ) );
%
[G.DIMS] = deal( dims );


%- Reshape map
%
n = ones( 1, D.DIM );
%
for id = 1 : length( dims )
  n(dims(id)) = size( data.data, id );
end


%- Copy data
%
[G.DATA] = deal( reshape(data.data, n ) );


%- Data name and unit
%
if isempty( type ) 
  G.DATA_NAME  = '?';
  G.DATA_UNIT  = '?';
elseif strcmp( lower(type), 'vmr' )
  G.DATA_NAME  = 'Volume mixing ratio';
  G.DATA_UNIT  = '-';
elseif strcmp( lower(type), 't' )
  G.DATA_NAME  = 'Temperature';
  G.DATA_UNIT  = 'K';
elseif strcmp( lower(type), 'z' )
  G.DATA_NAME  = 'Altitude';
  G.DATA_UNIT  = 'm';
else
  error(' Unknown selection for *type*.' );  
end


%- Include grids
%
for id = 1 : length(dims)

  gname = sprintf( 'GRID%d', dims(id) );
  
  if id == 1
    [G.(gname)] = deal( data.p_grid );
  elseif id == 2
    [G.(gname)] = deal( data.lat_grid );
  elseif id == 3
    [G.(gname)] = deal( data.lon_grid );
  end
end
