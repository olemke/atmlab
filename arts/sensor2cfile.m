% SENSOR2CFILE   Builds a control file part for ARTS sensor response
%
%    This is like a smaller version of *qarts2cfile* aimed at creating the 
%    sensor response part of the control file. It creates a control file 
%    part matching the settings in a Qarts sensor structure. 
%    
%    This function is called by *qarts2cfile* to create the part related to
%    the calculation of the sensor response. The function also assumes that
%    at least one sensor part is included, if no sensor is present this
%    should be dealt with in *qarts2cfile*.
%    
%    The control file structure is determined by the fields in the sensor 
%    structure. By setting fields connected to a certain sensor parts
%    to a MATLAB variable or filename that sensor part is included in the 
%    response.
%
%    To see what fields are connected to which sensor part, see the ARTS
%    online help.
%
%    To calculate the sensor response use runtype 'sensor' in *qarts*.

% FORMAT   [S, fold2IF] = sensor2cfile( H )
%
% OUT   S       String cell array that can be passed to qtool.
% IN    H       Qarts sensor structure
%       tmpdir  Temporary folder where calculations will be performed.

% 2005-01-26   Created by Mattias Ekström.


function S = sensor2cfile( H, tmpdir )

% Check that all fields are present
qcheck( @qarts_sensor, H );

% Check that some fields have valid values
if (H.SENSOR_NORM~=0 & H.SENSOR_NORM~=1)
  error('The field *SENSOR_NORM* in the sensor structure can only be 0 or 1.')
end
if (H.ANTENNA_DIM~=1 & H.ANTENNA_DIM~=2)
  error('The field *ANTENNA_DIM* in the sensor structure must be 1 or 2.')
end

% Check for obligatory sensor fields
oblig_fields = {'SENSOR_NORM', 'ANTENNA_DIM', 'MBLOCK_ZA_GRID'};
if (H.ANTENNA_DIM==2)
  oblig_fields{length(oblig_fields)+1} = 'MBLOCK_AA_GRID';
end

for it=1:length(oblig_fields)
  if isnan(H.(oblig_fields{it}))
    error(['The field *' oblig_fields{it} ...
           '* in the sensor structure must be set.'])
  end
end

% Find out sensor structure
parts{1} = 'init';
if isdefined( H, {'ANTENNA_DIAGRAM','ANTENNA_LOS'} )
  parts{length(parts)+1} = 'antenna';
end
if isdefined( H, {'SENSOR_ROT'} )
  parts{length(parts)+1} = 'rotation';
end
if isdefined( H, {'SENSOR_POL'} )
  parts{length(parts)+1} = 'polarsation';
end
if isdefined( H, {'LO','SIDEBAND_FILTER'} )
  parts{length(parts)+1} = 'mixer';
end
if isdefined( H, {'F_BACKEND','CHANNEL_RESPONSE'} )
  parts{length(parts)+1} = 'backend';
end
% If multiple LO are given exchange 'mixer' and 'backend' for 'multimixer'
if (strmatch('mixer',char(parts)) & ...
    strmatch('backend',char(parts)) & ...
    length(H.LO)>1 )
  parts = rmfield( parts, {'mixer' 'backend'} );
  parts{length(parts)+1} = 'multimixer';
end
parts{length(parts)+1} = 'close';
    
% Start writing to structure 'S'             
S = {};

for it = 1 : length(parts)

T = [];

switch parts{it}

case 'init'
  T{1} = ['# Sensor part created by Atmlab function sensor2cfile'];
  T{2} = ['AntennaSet' num2str(H.ANTENNA_DIM) 'D{}'];
  T{3} = file_or_data( 'mblock_za_grid', 'Vector', H.MBLOCK_ZA_GRID, tmpdir );
  if H.ANTENNA_DIM==2
    T{4} = file_or_data( 'mblock_aa_grid', 'Vector', H.MBLOCK_AA_GRID, tmpdir );
  else
    T{4} = ['# No azimuthal measurement block angle grid loaded'];
  end
  T{5} = ['IndexSet(sensor_norm){' num2str(H.SENSOR_NORM) '}'];
  T{6} = 'sensor_responseInit{}';
  
case 'antenna'
  T{1} = file_or_data( 'antenna_los', 'Matrix', H.ANTENNA_LOS, tmpdir );
  T{2} = file_or_data( 'antenna_diagram', 'ArrayOfArrayOfMatrix', ...
                       H.ANTENNA_DIAGRAM, tmpdir );
  T{3} = 'sensor_responseAntenna1D{}';
  
case 'rotation'
  T{1} = file_or_data( 'sensor_rot', 'Vector', H.SENSOR_ROT, tmpdir );
  T{2} = 'sensor_responseRotation{}';

case 'polarisation'
  T{1} = file_or_data( 'sensor_pol', 'Matrix', H.SENSOR_POL, tmpdir );
  T{2} = 'sensor_responsePolarisation{}';
    
case 'mixer'
  T{1} = file_or_data( 'lo', 'Vector', H.LO, tmpdir );
  T{2} = file_or_data( 'matrix_1', 'Matrix', H.SIDEBAND_FILTER, tmpdir );
  T{3} = 'sensor_responseMixer(matrix_1){}';

case 'backend'
  T{1} = file_or_data( 'f_backend', 'Vector', H.F_BACKEND, tmpdir );
  T{2} = file_or_data( 'arrayofmatrix_1', 'Matrix',H.CHANNEL_RESPONSE,tmpdir);
  T{3} = 'sensor_responseBackend(arrayofmatrix_1){}';
  
case 'multimixer'
  T{1} = file_or_data( 'lo', 'Vector', H.LO, tmpdir );
  T{2} = file_or_data( 'matrix_1', 'Matrix', H.SIDEBAND_FILTER, tmpdir );
  T{3} = file_or_data( 'f_backend', 'Vector', H.F_BACKEND, tmpdir );
  T{4} = file_or_data( 'arrayofmatrix_1', 'Matrix',H.CHANNEL_RESPONSE,tmpdir);
  T{5} = file_or_data( 'sensor_pol', 'Matrix', H.SENSOR_POL, tmpdir );
  T{6} = 'sensor_responseBackend(matrix_1,arrayofmatrix_1){}';
  
case 'close'
  T{1} = '# End of sensor part';

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = { S{:} T{:} };

end


%------------------------------------------------------------------------------
function ok = isdefined( H, fields )
  ok = 1;
  for it=1:length(fields)
    if isnan(H.(fields{it}))
      ok = 0;
    end
  end
return

function s = file_or_data( artsvar, datatype, qvalue, tmpdir )
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if ~isstruct( qvalue )  &  isnan( qvalue )
      fprintf('\nNaN found for %s.\n\n', artsvar );
      error('See above');
    end
    filename = fullfile( tmpdir, [artsvar,'.xml'] );
    xmlStore( filename, qvalue, datatype );
    s = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  s = sprintf('ReadXML(%s){"%s"}', artsvar, filename );
return
