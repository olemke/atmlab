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
%       cloudbox
%       sensor
%       save_sensor
%       calc_rte
%       save_y
%       batch
%       stop
%
%    Sorry, the Q fields needed for each part is not listed here.
%    See the code.
%
%    Output is stored in files placed in *tmpdir*, with names identical
%    the WSV name and extension '.xml' (e.g. y.xml).
%
%    The parts to combine for some different  tasks can be obtained by 
%    this function, using the second format version below. In this case, 
%    there shall only be one input argument, and it shall be a plain string.
%
%    Defined options, of general interest, for *runtype* are:
%      'y':          Calculation of a single spectrum
%
%    More options exist but mainly for support of other functions.
%
%    In most of these cases there is a function to directly perform the
%    calculations, named as arts_"runtype", for example arts_y.
%
% FORMAT   S = qarts2cfile( Q, parts, tmpdir )
%
% OUT   S       String cell array that can be passed to qtool.
% IN    Q       Qarts structure
%       parts   Control file parts to include. See further above.
%       tmpdir  Temporary folder where calculations will be performed.
%
%             or
%
% FORMAT   parts = qarts2cfile( runtype )
%
% OUT   parts     As above
% IN    runtype   String describing type of calculation to perform.
%                 See further above.

% 2004-09-08   Created by Patrick Eriksson.


function S = qarts2cfile( Q, parts, tmpdir )


%--- Version returning parts --------------------------------------------------
%
if nargin == 1

  if ~ischar( Q )
    error( 'If number of arguments is 1, this argument must be a string' );
  end

  switch Q

  case 'get_atmfields'
    %
    S = { 'start', 'load_atm', 'save_atm', 'stop' };

  case 'y'
    %
    S = {'start', 'stokes', 'load_atm', 'load_abs', 'calc_abs', 'init_rte', ...
         'cloudbox', 'sensor', 'calc_rte', 'save_y', 'stop' };

  case 'batch'
    %
    S = {'start', 'stokes', 'load_atm', 'load_abs', 'calc_abs', 'init_rte', ...
         'cloudbox', 'sensor', 'batch', 'stop' };

  otherwise
    error( sprintf( 'Unknown run type (%s) was requested.', Q ) );
  end

  return

end



%--- Version returning string struture ----------------------------------------
%

qcheck( @qarts, Q );

S = {};

for i = 1 : length(parts)

T = [];

switch parts{i}

case 'start'
  %
  T{1} = [ '# Control file created by Atmlab function *qarts2cfile*' ];
  T{2} = 'Main{';
  T{3} = 'output_file_formatSetAscii{}';
  if Q.JACOBIAN_DO
    T{4} = 'jacobianInit{}';
  else
    T{4} = 'jacobianOff{}';
  end
  T{5} = 'abs_speciesInit{}';

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
  T{end+1} = sprintf( 'AtmosphereSet%dD{}', Q.ATMOSPHERE_DIM );
  T{end+1} = file_or_data( 'p_grid', 'Vector', Q.P_GRID, tmpdir );
  if Q.ATMOSPHERE_DIM >= 2
    T{end+1} = file_or_data( 'lat_grid', 'Vector', Q.LAT_GRID, tmpdir );
  end
  if Q.ATMOSPHERE_DIM == 3
    T{end+1} = file_or_data( 'lon_grid', 'Vector', Q.LON_GRID, tmpdir );
  end
  %
  %- Add gas species
  for i = 1 : length(Q.ABS_SPECIES)

    %- Jacobians or not?
    do_jac = 0;
    if Q.JACOBIAN_DO  &  ~isempty(Q.ABS_SPECIES_JAC)  &  ...
                                                length(Q.ABS_SPECIES_JAC) >= i
      rqre_field( Q.ABS_SPECIES_JAC{i}, 'DO' )
      if Q.ABS_SPECIES_JAC{i}.DO
        do_jac = 1;
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'METHOD' )
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'UNIT' )
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'P_GRID' )
      end
    end
    
    %- Write to cfile
    if ~do_jac
      T{end+1} = sprintf( 'abs_speciesAdd{[%s]}', ...
			  arts_tgs_cnvrt({Q.ABS_SPECIES{i}}) );
    else
      if Q.ATMOSPHERE_DIM < 2
        lat_grid = [];
      else
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'LAT_GRID' )
        lat_grid = Q.ABS_SPECIES_JAC{i}.LAT_GRID;
      end
      if Q.ATMOSPHERE_DIM < 3
        lon_grid = [];
      else
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'LON_GRID' )
        lon_grid = Q.ABS_SPECIES_JAC{i}.LON_GRID;
      end
      T{end+1} = file_or_data( 'vector_1', 'Vector', ...
          Q.ABS_SPECIES_JAC{i}.P_GRID, tmpdir, sprintf('gas%d_jac_p_grid',i) );
      T{end+1} = file_or_data( 'vector_2', 'Vector', ...
                           lat_grid, tmpdir, sprintf('gas%d_jac_lat_grid',i) );
      T{end+1} = file_or_data( 'vector_3', 'Vector', ...
                           lon_grid, tmpdir, sprintf('gas%d_jac_lon_grid',i) );

      T{end+1} = 'jacobianAddGas(vector_1,vector_2,vector_3){';
      T{end+1} = sprintf( '  species = %s', ...
                                          arts_tgs_cnvrt({Q.ABS_SPECIES{i}}) );
      T{end+1} = sprintf( '  method  = "%s"', ...
                                                 Q.ABS_SPECIES_JAC{i}.METHOD );
      T{end+1} = sprintf( '  unit    = "%s"', ...
                                                   Q.ABS_SPECIES_JAC{i}.UNIT );
      if strcmp( Q.ABS_SPECIES_JAC{i}.METHOD, 'analytical' )
         T{end+1} = '  dx = 0.0';
      elseif strcmp( Q.ABS_SPECIES_JAC{i}.METHOD, 'perturbation' )
        rqre_field( Q.ABS_SPECIES_JAC{i}, 'DX' )
        T{end+1} = sprintf( '  dx      = %.5e', Q.ABS_SPECIES_JAC{i}.DX );
      else
        error( sprintf('Unknown selection for ABS_SPECIES_JAC.METHOD (%s)',...
                                               Q.ABS_SPECIES_JAC{i}.METHOD ) );
      end
      T{end+1} = '}';
    end
  end
  %
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'Qarts field RAW_ATMOSPHERE', Q.RAW_ATMOSPHERE );
    rqre_bool( 'Qarts field RAW_ATM_EXPAND_1D', Q.RAW_ATM_EXPAND_1D );
    T{end+1} = sprintf('AtmRawRead{"%s"}', Q.RAW_ATMOSPHERE );
    if Q.RAW_ATM_EXPAND_1D
      T{end+1} = 'AtmFieldsCalcExpand1D{}';
    else
      T{end+1} = 'AtmFieldsCalc{}';
    end
  else
    T{end+1} = file_or_data( 't_field', 'Tensor3', Q.T_FIELD, tmpdir );
    T{end+1} = file_or_data( 'z_field', 'Tensor3', Q.Z_FIELD, tmpdir );
    T{end+1} = file_or_data( 'vmr_field', 'Tensor4', Q.VMR_FIELD, tmpdir);
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_field', tmpdir );
  T{2} = add_savefile( 'z_field', tmpdir );
  T{3} = add_savefile( 'vmr_field', tmpdir );

case 'load_abs'
  %
  T{1} = file_or_data( 'f_grid', 'Vector', Q.F_GRID, tmpdir );
  T{2} = 'abs_lookupInit{}';
  T{3} = file_or_data( 'abs_lookup', 'GasAbsLookup', Q.ABS_LOOKUP, tmpdir );
  T{4} = 'abs_lookupAdapt{}';

case 'calc_abs'
  T = add_agenda( T, 'abs_scalar_gas_agenda', ...
                                     { 'abs_scalar_gasExtractFromLookup{}' } );
  T = add_agenda( T, 'emission_agenda', Q.EMISSION_AGENDA );

case 'init_rte'
  %
  if ~isnan( Q.R_GEOID )  &  isscalar( Q.R_GEOID )
    T{1} = sprintf( 'r_geoidSpherical{%e}', Q.R_GEOID );
  else
    T{1} = file_or_data( 'r_geoid', 'Matrix', Q.R_GEOID, tmpdir );
  end
  if ~isnan( Q.Z_SURFACE )  &  isscalar( Q.Z_SURFACE )
    T{2} = 'ncolsGet( r_geoid ){}';
    T{3} = 'nrowsGet( r_geoid ){}';
    T{4} = sprintf('MatrixSet(z_surface){%.3f}', Q.Z_SURFACE );
  else
    T{2} = file_or_data( 'z_surface', 'Matrix', Q.Z_SURFACE, tmpdir );
  end
  %
  if iscellstr( Q.SURFACE_PROP_AGENDA )
    T = add_agenda( T, 'surface_prop_agenda', Q.SURFACE_PROP_AGENDA );
  end
  T = add_agenda( T, 'iy_space_agenda', Q.IY_SPACE_AGENDA );
  T = add_agenda( T, 'ppath_step_agenda', Q.PPATH_STEP_AGENDA );
  if iscellstr( Q.REFR_INDEX_AGENDA )
    T = add_agenda( T, 'refr_index_agenda', Q.REFR_INDEX_AGENDA );
  elseif ~isnan( Q.REFR_INDEX_AGENDA )
    error( 'Q.REFR_INDEX_AGENDA must either be NaN or cell array of strings.');
  end
  T = add_agenda( T, 'rte_agenda', Q.RTE_AGENDA );
  T{end+1} = file_or_data( 'sensor_pos', 'Matrix', Q.SENSOR_POS, tmpdir );
  T{end+1} = file_or_data( 'sensor_los', 'Matrix', Q.SENSOR_LOS, tmpdir );
  %
  if Q.JACOBIAN_DO  &  ~isempty(Q.POINTING_JAC)
      rqre_field( Q.POINTING_JAC, 'SENSOR_TIME' )
      rqre_field( Q.POINTING_JAC, 'DZA' )
      rqre_field( Q.POINTING_JAC, 'POLY_ORDER' )
  
      T{end+1} = file_or_data( 'sensor_time', 'Vector', ...
                 Q.POINTING_JAC.SENSOR_TIME, tmpdir );
      T{end+1} = 'jacobianAddPointing{';
      T{end+1} = sprintf( '  dza        = %g', ...
                                               Q.POINTING_JAC.DZA );
      T{end+1} = sprintf( '  poly_order = %d', ...
                                                 Q.POINTING_JAC.POLY_ORDER );
      T{end+1} = '}';
  end
  %
  T = add_wsms( T, 'PRE_RTE_WSMS', Q.PRE_RTE_WSMS );

case 'cloudbox'
  %
  if isstruct( Q.CLOUDBOX )
    T = cloudbox2cfile( Q, tmpdir );
    T = add_agenda( T, 'opt_prop_gas_agenda', ...
              { 'ext_matInit{}', 'abs_vecInit{}', Q.OPT_PROP_GAS_AGENDA{:} } );
  elseif isnan( Q.CLOUDBOX )  |  Q.CLOUDBOX == 0 
    T{1} = 'cloudboxOff{}';
  else
    error( 'Unknown selection for Q.CLOUDBOX.' );
  end

case 'sensor'
  %
  if ischar(Q.SENSOR_RESPONSE) | issparse(Q.SENSOR_RESPONSE)
    T{1} = file_or_data( 'sensor_response', 'Sparse', ...
                         Q.SENSOR_RESPONSE, tmpdir );
  elseif iscellstr(Q.SENSOR_RESPONSE) 
    T = Q.SENSOR_RESPONSE;
  elseif isstruct(Q.SENSOR_RESPONSE) 
    T = sensor2cfile( Q.SENSOR_RESPONSE, tmpdir );
  elseif isnan(Q.SENSOR_RESPONSE)  |  Q.SENSOR_RESPONSE == 0 
    T{1} = 'sensorOff{}';
  else
    error( 'Unrecognised choice for Q.SENSOR_RESPONSE.' );
  end
  
case 'save_sensor'
  %
  T{1} = add_savefile( 'sensor_response', tmpdir );
  T{2} = add_savefile( 'sensor_response_f', tmpdir );
  
case 'calc_rte'
  %
  if Q.JACOBIAN_DO
    %
    T{end+1} = 'jacobianClose{}'; 
    %
  end
  %
  %= Special solution for DOIT
  if isstruct(Q.CLOUDBOX)  &  strcmp( upper(Q.CLOUDBOX.METHOD), 'DOIT' )
    T{end+1} = 'CloudboxGetIncoming{}';
    T{end+1} = 'DoitInit{}';
    if ~Q.CLOUDBOX.METHOD_PRMTRS.I_REINIT
      T{end+1} = 'IndexSet(f_index){0}';
      T{end+1} = 'doit_i_fieldSetClearsky{}';
    end
    T{end+1} = 'ScatteringDoit{}';
    %
  end
  %
  T{end+1} = 'RteCalc{}';
  %
  if Q.JACOBIAN_DO
    T{end+1} = 'jacobianCalc{}'; 
  end

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
  %
  if isstruct( Q.CLOUDBOX )  &  strcmp(upper(Q.CLOUDBOX.METHOD),'MC')
    if ~isnan( Q.SENSOR_RESPONSE )   
      T{3} = 'mc_errorApplySensor{}';
    else
      T{3} = '';
    end
    switch upper( Q.Y_UNIT )
      case '1'
        T{4} = '# No conversion to K';
      case { 'RJ', 'PLANCK' }
        T{4} = 'VectorToTbByRJ(mc_error,mc_error){}';
    end
    T{5} = add_savefile( 'mc_error', tmpdir );
  end
  %
  if Q.JACOBIAN_DO
  %
    switch upper( Q.Y_UNIT )
      case '1'
        T{end+1} = '# No conversion to K';
      case 'RJ'
        T{end+1} = 'MatrixToTbByRJ(jacobian,jacobian){}';
      case 'PLANCK'
        error(...
       'Planck Tb means a non-linear conversion, not suitable for jacobians.');
    end
    T{end+1} = add_savefile( 'jacobian', tmpdir );
    T{end+1} = add_savefile( 'jacobian_quantities', tmpdir );
    T{end+1} = add_savefile( 'jacobian_indices', tmpdir );
  end

case 'batch'
  %
  if ~isstruct( Q.BATCH )
    error( 'Batch calculations can only be described by a structure.' )
  end
  %
  T = batch2cfile( Q, tmpdir );

case 'stop'
  %
  T{1} = '} # Main';

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end


S = { S{:} T{:} };

end



%------------------------------------------------------------------------------
% Smaller help functions
%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpdir, nonDefFileId )
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if iscell( qvalue )
      if isempty( qvalue )
        fprintf('\n%s is empty.\n\n', artsvar );
        error('See above');
      end
    else
      if ~isstruct( qvalue )  &  isnan( qvalue )
        fprintf('\nNaN found for %s.\n\n', artsvar );
        error('See above');
      end
    end
    if nargin >= 5
      filename = fullfile( tmpdir, [nonDefFileId,'.xml'] );
    else
      filename = fullfile( tmpdir, [artsvar,'.xml'] );
    end
    xmlStore( filename, qvalue, datatype );
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


function T = add_agenda( T, agenda, strarray )
  if ~( iscellstr( strarray )  |  isempty( strarray ) )
    error( ...
        sprintf('The field %s must be specified as cell array of strings.', ...
                                                             upper(agenda) ) );
  end
  T{end+1} = sprintf( 'AgendaSet(%s){', agenda );
  for j = 1 : length(strarray)
    T{end+1} = sprintf( '   %s', strarray{j} );
  end
  T{end+1} = '}';
return


function T = add_wsms( T, field, strarray )
  if iscellstr( strarray )
    for j = 1 : length(strarray)
      T{end+1} = sprintf( '%s', strarray{j} );
    end
  else
    if ~isnan( strarray )
      error( ...
        sprintf('The field %s must be specified as cell array of strings.', ...
                                                                     field ) );
    end
  end
return


function ok = isdefined( H, fields )
  ok = 1;
  for it=1:length(fields)
    if iscell(H.(fields{it}))
      if isempty(H.(fields{it}))
        ok = 0;
      end
    elseif isnan(H.(fields{it}))
      ok = 0;
    end
  end
return



%------------------------------------------------------------------------------
% cloudbox2cfile
%------------------------------------------------------------------------------

function T = cloudbox2cfile( Q, tmpdir )

%= Check that all fields are present
%
qcheck( @qarts_cloudbox, Q.CLOUDBOX );

%= Some basic checks
if Q.ATMOSPHERE_DIM == 2
  error( 'Scattering is not defined for 2D.' );
elseif Q.ATMOSPHERE_DIM < 3  &  strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
  error( 'MC can only be applied for 3D.' );
end

T = [];

%= Agendas for scattering properties 
%
T = add_agenda( T, 'spt_calc_agenda', {'opt_prop_sptFromMonoData{}'} );
T = add_agenda( T, 'opt_prop_part_agenda', ...
     {'ext_matInit{}','abs_vecInit{}','ext_matAddPart{}','abs_vecAddPart{}'} );

%= Cloudbox
%
if isvector(Q.CLOUDBOX.LIMITS)  &  ~any(isnan( Q.CLOUDBOX.LIMITS ))
  if length(Q.CLOUDBOX.LIMITS) ~= 2*Q.ATMOSPHERE_DIM
    error( ...
    'Length of Q.CLOUDBOX.LIMITS does not match atmospheric dimensionality.' );
  end 
  if length(Q.CLOUDBOX.LIMITS) < 6
     limits = Q.CLOUDBOX.LIMITS;
     Q.CLOUDBOX.LIMITS = zeros(1,6);
     Q.CLOUDBOX.LIMITS(1:length(limits)) = limits;
  end
  T{end+1} = 'cloudboxSetManuallyAltitude{';
  T{end+1} = sprintf('   z1   = %.3f', Q.CLOUDBOX.LIMITS(1) );
  T{end+1} = sprintf('   z2   = %.3f', Q.CLOUDBOX.LIMITS(2) );
  T{end+1} = sprintf('   lat1 = %.3f', Q.CLOUDBOX.LIMITS(3) );
  T{end+1} = sprintf('   lat2 = %.3f', Q.CLOUDBOX.LIMITS(4) );
  T{end+1} = sprintf('   lon1 = %.3f', Q.CLOUDBOX.LIMITS(5) );
  T{end+1} = sprintf('   lon2 = %.3f', Q.CLOUDBOX.LIMITS(6) );
  T{end+1} = '}';
else
  error('Not valid specification Q.CLOUDBOX.LIMITS.');
end

%= Particle field and single scattering data
%
if (iscellstr(Q.CLOUDBOX.PND_FIELD) && ...
    iscellstr(Q.CLOUDBOX.SCAT_DATA))
  if (length(Q.CLOUDBOX.PND_FIELD) == length(Q.CLOUDBOX.SCAT_DATA)) 
    T{end+1} = 'ParticleTypeInit{}';
    for i = 1 : length(Q.CLOUDBOX.PND_FIELD)
      T{end+1} = 'ParticleTypeAdd{';
      T{end+1} = sprintf('   filename_scat_data =  "%s"', ...
			 Q.CLOUDBOX.SCAT_DATA{i} );
      T{end+1} = sprintf('   filename_pnd_field =  "%s"', ...
			 Q.CLOUDBOX.PND_FIELD{i} );
      T{end+1} = '}';
    end
    % 
  elseif (length(Q.CLOUDBOX.SCAT_DATA) == 1 && ...
	  length(Q.CLOUDBOX.PND_FIELD) > 1)
    
    T{end+1} = 'ParticleTypeAddAll{';
    T{end+1} = sprintf('   filename_scat_data =  "%s"', ...
		     Q.CLOUDBOX.SCAT_DATA{i} );
    T{end+1} = sprintf('   filename_pnd_field =  "%s"', ...
		       Q.CLOUDBOX.PND_FIELD{i} );
    T{end+1} = '}';   
    %
  else
    error(['Scattering data (Q.SCAT_DATA) or particle number density' ...
	   '(Q.PND_FIELD) is wrong. The safest option is to give' ...
	   ' filenames of the single scattering data and the' ...
	   ' corresponding particle number density fields.']);
  end
  T{end+1} = 'pnd_fieldCalc{}';
end



%= DOIT / MC
%
if strcmp( upper(Q.CLOUDBOX.METHOD), 'DOIT' )
  %
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'N_ZA_GRID', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'N_AA_GRID', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'ZA_GRID_OPT_FILE', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'SCAT_ZA_INTERP', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'EPSILON', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'I_REINIT', 0 );
  
  if (~iswhole(Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID) | ...
      ~iswhole(Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID))
    error(['The parameter N_ZA_GRID and N_AA_GRID must be given as',...
	   ' integer values.']);
  end
  
  if (~ischar(Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE))
    error(['The field ZA_GRID_OPT_FILE is not a string. It must be' ...
	                     ' empty (""), if equidistant grids should be used.']);
  end
 
  if (~(strcmp(Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP, 'linear') | ...
     strcmp(Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP, 'polynomial')))
    error(['Unknown interpolation method. ',... 
                              'SCAT_ZA_INTERP can be linear or polynomial.']);
  end
  
  if length(Q.CLOUDBOX.METHOD_PRMTRS.EPSILON) < Q.STOKES_DIM
   error('Length of Q.CLOUDBOX.METHOD_PRMTRS.EPSILON must be >= Q.STOKES_DIM');
  end
   
  T{end+1} = 'DoitAngularGridsSet{';
  T{end+1} = sprintf('   N_za_grid = %d', Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID );
  T{end+1} = sprintf('   N_aa_grid = %d', Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID );
  T{end+1} = sprintf('   za_grid_opt_file = "%s"', ...
                                   Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE );
  T{end+1} = '}';
  
  T{end+1} = sprintf('doit_za_interpSet{interp_method = "%s"}', ...
		     Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP );

  if Q.CLOUDBOX.METHOD_PRMTRS.I_REINIT
    T = add_agenda( T, 'doit_mono_agenda', ...
          { 'DoitScatteringDataPrepare{}', ...
            'doit_i_fieldSetClearsky{}', ...
            'doit_i_fieldIterate{}',...
            'DoitCloudboxFieldPut{}' } );
  else
    T = add_agenda( T, 'doit_mono_agenda', ...
          { 'DoitScatteringDataPrepare{}', ...
            'doit_i_fieldIterate{}',...
            'DoNothing(scat_i_p,scat_i_p){}',...
            'DoNothing(scat_i_lat,scat_i_lat){}',...
            'DoNothing(scat_i_lon,scat_i_lon){}',...
            'DoitCloudboxFieldPut{}' } );
  end
  T = add_agenda( T, 'pha_mat_spt_agenda', { ...
      'pha_mat_sptFromDataDOITOpt{}' });
  
  if (isempty(Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE))
    T = add_agenda( T, 'doit_scat_field_agenda', { 'doit_scat_fieldCalc{}' ...
		   } );
  else
    T = add_agenda( T, 'doit_scat_field_agenda', ...
                                             { 'doit_scat_fieldCalcLimb{}' } );
  end
  
  T = add_agenda( T, 'doit_rte_agenda', ...
		  { sprintf('doit_i_fieldUpdateSeq%dD{}',Q.ATMOSPHERE_DIM) } );
  T = add_agenda( T, 'doit_conv_test_agenda', { ...
      sprintf('doit_conv_flagAbsBT{[%s]}', ...
      vector2commalist(Q.CLOUDBOX.METHOD_PRMTRS.EPSILON(1:Q.STOKES_DIM)) ) } );
  T = add_agenda( T, 'iy_cloudbox_agenda', { 'DoNothing(ppath, ppath){}',...
          'DoNothing(rte_pos,rte_pos){}', 'DoNothing(rte_los,rte_los){}', ...
          'iyInterpCloudboxField{}' } );

elseif strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
  %
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'STD_ERR', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_TIME', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_ITER', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'INCOMING_LOOKUP', 0 );
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'Z_FIELD_IS_1D', 0);
  rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'MC_SEED', 0 );
  %
  if Q.CLOUDBOX.METHOD_PRMTRS.INCOMING_LOOKUP
    T{end+1} = file_or_data( 'mc_incoming', 'SLIData2', ...
                            Q.CLOUDBOX.METHOD_PARAMS.INCOMING_LOOKUP, tmpdir );
  end
  %
  T{end+1} = 'IndexSet(f_index){value=0}';
  T{end+1} = 'scat_data_monoCalc{}';
  %
  if Q.CLOUDBOX.METHOD_PRMTRS.MC_SEED < 0
    T{end+1} = 'MCSetSeedFromTime{}';
  else
    T{end+1} = sprintf( 'IndexSet(mc_seed){%d}', ...
                                            Q.CLOUDBOX.METHOD_PRMTRS.MC_SEED );
  end
  %
  T{end+1} = 'AgendaSet(iy_cloudbox_agenda){';
  T{end+1} = '   ScatteringMonteCarlo{';
  T{end+1} = sprintf('     std_err  = %d', Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR );
  T{end+1} = sprintf('     max_time = %d', Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME );
  T{end+1} = sprintf('     max_iter = %d', Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER );
  T{end+1} = sprintf('     incoming_lookup = %d', ...
                                    Q.CLOUDBOX.METHOD_PRMTRS.INCOMING_LOOKUP );
  T{end+1} = sprintf('     z_field_is_1D = %d', ...
                                      Q.CLOUDBOX.METHOD_PRMTRS.Z_FIELD_IS_1D );
  T{end+1} = '   }';
  T{end+1} = '}';

else
  error( 'Unknown choice for Q.CLOUDBOX.METHOD.' );
end



%------------------------------------------------------------------------------
% sensor2cfile
%------------------------------------------------------------------------------

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
  parts{length(parts)+1} = 'polarisation';
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
  error(sprintf('Unknown action (%s) was requested.',parts{it}));
end

S = { S{:} T{:} };

end



%------------------------------------------------------------------------------
% batch2cfile
%------------------------------------------------------------------------------

function T = batch2cfile( Q, tmpdir )

B = Q.BATCH;

%= Check that all fields are present
%
qcheck( @qarts_batch, B );

%= Other data checks
%
if ~iscell( B.DATA )
  error('Q.BATCH.DATA must be a structure array.');
end
%
rqre_scalar( 'Q.BATCH.N', B.N, 1 );

T = [];
A = [];

num_wsv_nr = zeros(8,1);
int_wsv_nr = zeros(2,1);

for i = 1:length(B.DATA)
  rqre_field( B.DATA{i}, 'TYPE', 0 );
  rqre_char( sprintf('Q.BATCH{%d}.TYPE',i), B.DATA{i}.TYPE );
  rqre_field( B.DATA{i}, 'WSV', 0 );
  rqre_char( sprintf('Q.BATCH{%d}.WSV',i), B.DATA{i}.WSV );
  rqre_field( B.DATA{i}, 'X', 0 );
  
  if size(B.DATA{i}.X,1) < B.N 
    error(sprintf('Q.BATCH.DATA{%d}.X contains fewer cases than Q.BATCH.N',i));
  end

  [dim,datatype] = arts_datatypes( B.DATA{i}.TYPE );
  wsv_nr = eval([datatype,'_wsv_nr(dim+1)']) + 1;
  eval([datatype,'_wsv_nr(dim+1) = wsv_nr;'])

  wsv_type = arts_datatypes(dim+1,datatype);
  varname  = sprintf('%s_%d', lower(wsv_type), wsv_nr  );
  T{end+1} = file_or_data( varname, wsv_type, B.DATA{i}.X, tmpdir );
  A{i}     = sprintf( 'BatchUpdate%s(%s,%s){}', B.DATA{i}.TYPE, ...
                                                      B.DATA{i}.WSV, varname );
end

T        = add_agenda( T, 'batch_update_agenda', A );
T        = add_agenda( T, 'batch_calc_agenda', B.CALC_AGENDA );
T        = add_agenda( T, 'batch_post_agenda', B.POST_AGENDA );
T{end+1} = sprintf( 'IndexSet(ybatch_n){%d}', B.N );
T{end+1} = 'ybatchCalc{}';
%
switch upper( Q.Y_UNIT )
  case '1'
    T{end+1} = '# No conversion to K';
  case 'RJ'
    T{end+1} = 'MatrixToTbByRJ(ybatch,ybatch){}';
  case 'PLANCK'
    T{end+1} = 'MatrixToTbByPlanck(ybatch,ybatch){}';
  otherwise
    error( sprintf( 'Unrecognised choice for Q.Y_UNIT (%s).', Q.Y_UNIT ) );
end
%
T{end+1} = add_savefile( 'ybatch', tmpdir );
