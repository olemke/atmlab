% GRIDDEDFIELD2GF   CREATES A STANDARD GFORMAT OF A GRIDDED FIELD
%
%
% Takes inn a arts GriddedField format and creates a simple Gformat 
% structure of it. 
%
% NOTE: To import directly from an xml file use gf_artsxml instead
%
% FORMAT   G = griddedfield2gf( GF [, name, type ] )
%        
% OUT   G       Gformat structure
% IN    GF      Arts GriddedField structure
% OPT   name    Name of data. Will replace with is read from file if not
%               empty. Default is [].
%       type    Type of data. Default is []. Recognised options are
%                  'vmr_field' : volume mixing ratio field
%                  't_field'   : temperature (atmospheric) field
%                  'z_field'   : altitude (atmospheric) field

% 2011-02-09   Created by Ole Martin Chritensen.

function G = griddedfield2gf( GF, name, type )
                                                                   %&%
rqre_nargin( 1, nargin );                                          %&%
if length(GF) == 1                                                 %&%
    rqre_datatype( GF, @isstruct, 'Data in *file*' );              %&%
    rqre_field( GF, {'name','grids','gridnames','data','dataname'},... %&%
                                               'GriddedField' );   %&%
else
    for i=1:length(GF)
        rqre_datatype( GF{i}, @isstruct, 'Data in *file*' );           %&%
        rqre_field( GF{i}, {'name','grids','gridnames','data','dataname'},... %&%
                                               'GriddedField' );   %&%
    end
end
%                                                                  %&%
if nargin < 2
  name = [];
else                                                               %&%
  rqre_datatype( name, {@isempty,@ischar} );                       %&%
end
%                                                                  %&%
if nargin < 3
  type = [];
else                                                               %&%
  rqre_datatype( type, {@isempty,@ischar} );                       %&%
end


%- X is a struct array, not a cell array. The case length(X)==1 must then
%- be handled separately
%
G = [];
%
if length(GF) == 1
  G = gfin_artsxml_sub( G, GF, GF, name, type );
else  
  for i = 1 : length(GF)
    G = gfin_artsxml_sub( G, GF, GF{i}, name, type );
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
  elseif strcmp( lower(type), 'vmr_field' )
    T.TYPE       = 'atmdata';
    T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
    T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
    T.dataname   = 'Volume mixing ratio';
    T.DATAUNIT   = '-';
  elseif strcmp( lower(type), 't_field' )
    T.TYPE       = 'atmdata';
    T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
    T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
    T.dataname   = 'Temperature';
    T.DATAUNIT   = 'K';
  elseif strcmp( lower(type), 'z_field' )
    T.TYPE       = 'atmdata';
    T.gridnames  = { 'Pressure', 'Latitude', 'Longitude', [], 'Hour' };
    T.GRIDUNITS  = { 'Pa', 'deg', 'deg', '', '' };
    T.dataname   = 'Altitude';
    T.DATAUNIT   = 'm';
  else                                                               %&%
    error(' Unknown selection for *type*.' );                        %&%
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