% GF_ARTSXML   Import of arts XML GriddedField data to gformat
%
%    Imports data having the arts xml GriddedField format. If *type* is given,
%    all fields of G will be filled. Otherwise some will be left empty.
%
%    If file holds ArrayOfGriddedFieldX, one G element is created
%    for each array element.
%
% FORMAT   G = gf_artsxml( file [, name, type ] )
%
% OUT   G       G with imported data appended.
% IN    file    Name of file to read.
% OPT   name    Name of data. Will replace with is read from file if not
%               empty. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr_field' : volume mixing ratio field
%                  't_field'   : temperature (atmospheric) field
%                  'z_field'   : altitude (atmospheric) field
%                  'mag_field' : magnetic field component
%                  'wind_field': wind field component

% 2008-09-25   Created by Patrick Eriksson.

function G = gf_artsxml( file, name, type )

if nargin<2
    name=[];
end
if nargin<3
    type=[];
end

strictAssert=atmlab('STRICT_ASSERT');

if strictAssert 
  rqre_nargin( 1, nargin );
  rqre_datatype( file, @ischar );
  rqre_datatype( name, {@isempty,@ischar} );
  rqre_datatype( type, {@isempty,@ischar} );
end


%- Load and check data
%
X = xmlLoad( file );
%
if strictAssert    
  rqre_datatype( X, @isstruct, 'Data in *file*' );
  rqre_field( X, {'name','grids','gridnames','data','dataname'}, ... 
                                                      'Data in *file*' );
end

%- X is a struct array, not a cell array. The case length(X)==1 must then
%- be handled separately
%
G = [];
%
if length(X) == 1
    G = gfin_artsxml_sub( G, file, X, name, type );
else
    for i = 1 : length(X)
        G = gfin_artsxml_sub( G, file, X{i}, name, type );
    end
end


return
%-----------------------------------------------------------------------

function G = gfin_artsxml_sub( G, file, X, name, type )

%- Add user provided data (using some "false" fields)
%
if ~isempty( name )
  X.name = name;
end
%
if isempty( type )
  T.TYPE       = 'unknown';
  T.gridnames  = { [], [], [], [], [], [], [], [] };
  T.GRIDUNITS  = { [], [], [], [], [], [], [], [] };
  T.dataname   = [];
  T.DATAUNIT   = [];
elseif strcmpi( type, 'vmr_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Volume mixing ratio';
  T.DATAUNIT   = '-';
elseif strcmpi( type, 't_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Temperature';
  T.DATAUNIT   = 'K';
elseif strcmpi( type, 'z_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'Altitude';
  T.DATAUNIT   = 'm';
elseif strcmpi( type, 'mag_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'a magnetic component';
  T.DATAUNIT   = 'T';
elseif strcmpi( type, 'wind_field' )
  T.TYPE       = 'atmdata';
  T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
  T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
  T.dataname   = 'A wind component';
  T.DATAUNIT   = 'm/s';
else 
  error( ['atmlab:' mfilename], ' Unknown selection for *type*.' ); 
end

%- Transfer to G (set only up to max "active" dimension)
%
GG.TYPE      = T.TYPE;
GG.NAME      = X.name;
GG.SOURCE    = file;
%
GG.DIM       = max( find( size(X.data) > 1 ) );
GG.DATA      = X.data;
if isempty( X.dataname )
  GG.DATA_NAME = T.dataname;
else
  GG.DATA_NAME = X.dataname;
end
GG.DATA_UNIT = T.DATAUNIT;
%
for d = 1 : GG.DIM
  if length(X.gridnames) < d  ||  isempty( X.gridnames{d} )
    GG = gf_set_grid( GG, d, vec2col(X.grids{d}), ...
                      T.gridnames{d}, T.GRIDUNITS{d} );
  else    
    GG = gf_set_grid( GG, d, vec2col(X.grids{d}), ...
                      X.gridnames{d}, T.GRIDUNITS{d} );
  end
end
%
if isempty( G )
  G         = GG;
else
  G(end+1) = GG;
end
return