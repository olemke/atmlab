% GFIN_ARTSXML   Import of arts XML GriddedField data to gformat 
%
%    Imports data having the arts xml GriddedField format.  If *type* is given,
%    all fields of G will be filled. Otherwise some will be left empty.
%
%    To start a new gformat data structure, input *D* and *G* as empty.
% 
%    If *D* is not empty, the consistency between input and existing data 
%    will be checked (as far as possible). This check demands that grid names
%    and units are completely identical (if not empty on any side).
%
%    The data will be imported to the first N dimensions, where N is dimesnion
%    of file data.
%
%    If file holds ArrayOfGriddedFieldX, one G element is created
%    for each array element.
%
% FORMAT   [G,D] = gfin_artsxml( D, G, file [, name, type ] )
%        
% OUT   G       G with imported data appended.
%       D       Gformat definition structure.
% IN    D       Gformat definition structure. Can be empty. 
%       G       Original gformat data. Can be empty. 
%       file    Name of file to read.
% OPT   name    Name of data. Will replace with is read from file if not
%               empty. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr_field' : volume mixing ratio field
%                  't_field'   : temperature (atmospheric) field
%                  'z_field'   : altitude (atmospheric) field

% 2008-09-25   Created by Patrick Eriksson.

function [G,D] = gfin_artsxml( D, G, file, name, type )


%- Default values
%
name_DEFAULT = [];
type_DEFAULT = [];
%
set_defaults;


X = xmlLoad( file );


%- X is a struct array, not a cell array. The case length(X)==1 must then
%- be handled separately
%
if length(X) == 1
  [G,D] = gfin_artsxml_sub( D, G, file, X, name, type );
else  
  for i = 1 : length(X)
    [G,D] = gfin_artsxml_sub( D, G, file, X{i}, name, type );
  end
end


%- Check read data
%
gf_check( D, G );


return
%-----------------------------------------------------------------------


function [G,D] = gfin_artsxml_sub( D, G, file, X, name, type )


%- Add user provided data (using some "false" fields)
%
if ~isempty( name )
  X.name = name;
end
%
if isempty( type )
  X.GRIDUNITS  = { [], [], [], [], [], [] };
  X.DATAUNIT   = [];  
elseif strcmp( lower(type), 'vmr_field' )
  X.gridnames  = { 'Pressure', 'Latitude', 'Longitude' };
  X.GRIDUNITS  = { 'Pa', 'deg', 'deg' };
  X.dataname   = 'Volume mixing ratio';
  X.DATAUNIT   = '-';
elseif strcmp( lower(type), 't_field' )
  X.gridnames  = { 'Pressure', 'Latitude', 'Longitude' };
  X.GRIDUNITS  = { 'Pa', 'deg', 'deg' };
  X.dataname   = 'Temperature';
  X.DATAUNIT   = 'K';
elseif strcmp( lower(type), 'z_field' )
  X.gridnames  = { 'Pressure', 'Latitude', 'Longitude' };
  X.GRIDUNITS  = { 'Pa', 'deg', 'deg' };
  X.dataname   = 'Altitude';
  X.DATAUNIT   = 'm';
else
  error(' Unknown selection for *type*.' );  
end



%- Create D or check consistency with D
%
dims_in = length( X.grids );
%
if isempty( D )
  %
  D.DIM = dims_in;
  %
  for d = 1 : dims_in
    gname = sprintf( 'GRID%d_NAME', d );
    D.(gname) = X.gridnames{d};
    gname = sprintf( 'GRID%d_UNIT', d );
    D.(gname) = X.GRIDUNITS{d};;
  end
  %
  D = orderfields( D );
else
  %
  if dims_in > D.DIM 
    s = 'D.DIM lower than dimension of file data';
    error(sprintf( '%s (%d and %d, respectively).', s, D.DIM, dims_in ) );
  end
  %
  for d = 1 : dims_in
    if ~isempty( X.gridnames{d} ) 
      gname = sprintf( 'GRID%d_NAME', d );
      if ~strcmp( D.(gname), X.gridnames{d} )
        s = sprintf('Different data type for input dimension %d!\n',d);
        s = sprintf('%s  file data type    : %s\n', s, X.gridnames{d} );
        s = sprintf('%s  gformat data type : %s', s, D.(gname) );
        error( s );
      end
    end
    if ~isempty( X.DATAUNIT ) 
      gname = sprintf( 'GRID%d_UNIT', d );
      if ~strcmp( D.(gname), X.GRIDUNITS{d} )
        s = sprintf('Different data unit for input dimension %d!\n',d);
        s = sprintf('%s  file data unit    : %s\n', s, X.GRIDUNITS{d} );
        s = sprintf('%s  gformat data unit : %s', s, D.(gname) );
        error( s );
      end
    end
  end
end


%- Append data to G
%
i = length(G) + 1;
%
G(i).NAME   = X.name;
G(i).DIMS   = 1:dims_in;  
G(i).SOURCE = file;
%
G(i).DATA      = X.data;
G(i).DATA_NAME = X.dataname;
G(i).DATA_UNIT = X.DATAUNIT;
%
for d = 1 : dims_in
  gname = sprintf( 'GRID%d', d );
  G(i).(gname) = X.grids{d};
end


%- Sort if new G
%
if length(G) == 1
  G = orderfields( G );
end