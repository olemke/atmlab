% QARTS2CFILE   Builds a control file for ARTS
%
%    Creates a control file matching the settings in a Qarts structure.
%    The control file is provided as cell array of strings. This means
%    that the output can be combined with other control file pieces
%    by combining their string arrays. The final control file is
%    created by *qtool*.
%    
%    The control file structure is determined by putting different 'parts'
%    together, following the format: parts = {'tgs','load_atm','save_atm'}
%
%    Defined parts are:
%       start
%       stokes
%       load_atm
%       save_atm
%       load_abs
%       calc_abs
%       init_rte
%       calc_rte
%       save_y
%       stop
%
%    Sorry, the Q fields needed for each part is not listed here.
%    See the code.
%
%    Output is stored in files placed in *tmpdir*, with names identical
%    the WSV name and extension '.xml' (e.g. y.xml).
%
% FORMAT   S = qarts2cfile( Q, parts, tmpdir [, do_save] )
%        
% OUT   S       String cell array that can be passed to qtool.
% IN    Q       Qarts structure
%       parts   Control file parts to include. See further above.
%       tmpdir  Temporary folder where calculations will be performed.
% OPT   do_save If 0 no data is stored to files and only a control
%               file is created. Default is 1.

% 2004-09-08   Created by Patrick Eriksson.


function S = qarts2cfile( Q, parts, tmpdir, do_save )

if nargin < 4
  do_save = 1;
end


qcheck( @qarts, Q );

S = {};

for i = 1 : length(parts)

T = [];

switch parts{i}

case 'start'
  %
  T{1} = [ '# Control file created (at least partly) by Atmlab function ', ...
           'qarts2cfile' ];
  T{2} = 'Main{';
  T{3} = 'output_file_formatSetAscii{}';

case 'stokes'
  %
  rqre_scalar( 'Qarts field STOKES_DIM', Q.STOKES_DIM, 1, 4 );
  %
  T{1} = sprintf( 'IndexSet(stokes_dim){%d}', Q.STOKES_DIM );

case 'load_atm'
  %
  rqre_scalar( 'Qarts field ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
  rqre_bool( 'Qarts field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
  %
  T{1} = sprintf( 'gas_speciesSet{[%s]}', arts_tgs_cnvrt(Q.GAS_SPECIES) );
  T{2} = sprintf( 'AtmosphereSet%dD{}', Q.ATMOSPHERE_DIM );
  T{3} = file_or_data( 'p_grid', 'Vector', Q.P_GRID, tmpdir, do_save );
  if Q.ATMOSPHERE_DIM >= 2
    T{4} = file_or_data( 'lat_grid', 'Vector', Q.LAT_GRID, tmpdir, do_save );
  else
    T{4} = '# No latitude grid loaded';
  end
  if Q.ATMOSPHERE_DIM == 3
    T{5} = file_or_data( 'lon_grid', 'Vector', Q.LON_GRID, tmpdir, do_save );
  else
    T{5} = '# No longitude grid loaded';
  end
  %
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'Qarts field RAW_ATMOSPHERE', Q.RAW_ATMOSPHERE );
    T{6} = sprintf('AtmRawRead{"%s"}', Q.RAW_ATMOSPHERE );
    T{7} = 'AtmFieldsCalc{}';
  else
    T{6} = file_or_data( 't_field', 'Tensor3', Q.T_FIELD, tmpdir, do_save );
    T{7} = file_or_data( 'z_field', 'Tensor3', Q.Z_FIELD, tmpdir, do_save );
    T{8} = file_or_data( 'vmr_field', 'Tensor4', Q.VMR_FIELD, tmpdir, do_save);
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_field', tmpdir );
  T{2} = add_savefile( 'z_field', tmpdir );
  T{3} = add_savefile( 'vmr_field', tmpdir );

case 'load_abs'
  %
  T{1} = file_or_data( 'f_grid', 'Vector', Q.F_GRID, tmpdir, do_save );
  T{2} = file_or_data( 'gas_abs_lookup', 'GasAbsLookup', Q.GAS_ABS_LOOKUP, ...
                                                             tmpdir, do_save );
  T{3} = 'gas_abs_lookupAdapt{}';

case 'calc_abs'
  T{1} = [ 'AgendaSet(scalar_gas_absorption_agenda)', ...
                                       '{abs_scalar_gasExtractFromLookup{}}' ];
  T = add_agenda( T, 'opt_prop_gas_agenda', ...
              { 'ext_matInit{}', 'abs_vecInit{}', Q.OPT_PROP_GAS_AGENDA{:} } );

case 'init_rte'
  %
  if ~isnan( Q.R_GEOID )  &  isscalar( Q.R_GEOID )
    T{1} = sprintf( 'r_geoidSpherical{%e}', Q.R_GEOID );
  else
    T{1} = file_or_data( 'r_geoid', 'Matrix', Q.R_GEOID, tmpdir, do_save );
  end
  if ~isnan( Q.Z_SURFACE )  &  isscalar( Q.Z_SURFACE )
    T{2} = sprintf('MatrixSetTakingSizeFromMatrix(z_surface,r_geoid){%.3f}',...
                                                                 Q.Z_SURFACE );
  else
    T{2} = file_or_data( 'z_surface', 'Matrix', Q.Z_SURFACE, tmpdir, do_save );
  end
  %
  T = add_agenda( T, 'surface_agenda', Q.SURFACE_AGENDA );
  T = add_agenda( T, 'i_space_agenda', Q.I_SPACE_AGENDA );
  T = add_agenda( T, 'ppath_step_agenda', Q.PPATH_STEP_AGENDA );
  if ~isnan( Q.REFR_INDEX_AGENDA )
    T = add_agenda( T, 'refr_index_agenda', Q.REFR_INDEX_AGENDA );
  end
  T = add_agenda( T, 'rte_agenda', {'RteEmissionStd{}'} );
  i = length(T) + 1;
  T{i} = file_or_data( 'sensor_pos', 'Matrix', Q.SENSOR_POS, tmpdir, do_save );
  i    = i + 1;
  T{i} = file_or_data( 'sensor_los', 'Matrix', Q.SENSOR_LOS, tmpdir, do_save );
  i    = i + 1;
  T{i} = 'sensorOff{}';
  i    = i + 1;
  T{i} = 'cloudboxOff{}';

case 'calc_rte'
  %
  T{1} = 'RteCalc{}';

case 'save_y'
  %
  switch upper( Q.Y_UNIT )
    case '1'
      T{1} = '# No conversion to K';
    case 'RJ'
      T{1} = 'VectorToTbByRJ(y,y){}';
    case 'PLANCK'
      T{1} = 'VectorToTbByPlanck(y,y){}';
    otherwise
      error( sprintf( 'Unrecognised choice for Q.Y_UNIT (%s).', Q.Y_UNIT ) );
  end
  T{2} = add_savefile( 'y', tmpdir );

case 'stop'
  %
  T{1} = '} # Main';
  T{2} = ' ';

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = [ S T ];

end


%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpdir, do_save )
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if ~isstruct( qvalue )  &  isnan( qvalue )
      fprintf('\nNaN found for %s.\n\n', artsvar );
      error('See above');
    end
    filename = fullfile( tmpdir, [artsvar,'.xml'] );
    if do_save
      xmlStore( filename, qvalue, datatype );
    end
    s = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  s = sprintf('ReadXML(%s){"%s"}', artsvar, filename );
return


function s = add_savefile( artsvar, tmpdir )
  filename = fullfile( tmpdir, [ artsvar, '.xml' ] ); 
  s = sprintf('WriteXML(%s){"%s"}', artsvar, filename );
return


function T = add_agenda( T, agenda, strarray );
  i = length(T) + 1;
  T{i} = sprintf( 'AgendaSet(%s){', agenda );
  n = length( strarray );
  for j = (i+1) : (i+n)
    T{j} = sprintf( '   %s', strarray{j-i} );
  end
  T{i+n+1} = '}';
return
