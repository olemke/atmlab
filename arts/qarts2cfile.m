% QARTS2CFILE   Builds a control file for ARTS
%
%    Creates a control file matching the settings in a Qarts structure.
%    The control file is provided as cell array of strings. This means
%    that the output can be combined with other control file pieces
%    by combining their string arrays. The final control file is
%    created by *qtool*.
%    
%    The control file structure is determined by putting different 'parts'
%    together, following the format: parts = {'Generl','AtmSrfSave'}
%
%    Defined parts are:
%       Generl / GenerlSave
%       AtmSrf / AtmSrfSave
%       Absrpt / AbsrptSave
%       CldBox / CldBoxSave
%       SctMth / SctMthSave / SctMthBatch
%       RteSet
%       Sensor / SensorSave 
%       Jacobi 
%       RteExe
%       BatchC
%
%    The later options, including 'Save', adds commands to save main
%    variables for the part.
%
%    For fields that can be given both as a Matlab variable or name of a 
%    file, a file is generated automatically if the input a variable.
%    Output is stored in files placed in *workfolder*, with names identical
%    the WSV name and extension '.xml' (e.g. y.xml).
%
%    The parts to combine for some different  tasks can be obtained by 
%    this function, using the second format version below. In this case, 
%    there shall only be one input argument, and it shall be a plain string.
%
%    Defined options, of general interest, for *runtype* are:
%      'GetAtmSrf'  : To obtain variables defining the atmosphere and the 
%                     surface.
%      'GetAbsTable': To obtain an absorption table.
%      'y':         : A complete calcultion, possibly including sensor,
%                     scattering and jacobians.
%
%    In most of these cases there is a function to directly perform the
%    calculations, named as arts_"runtype", for example arts_y.
%
% FORMAT   S = qarts2cfile( Q, parts, workfolder )
%
% OUT   S           String cell array that can be passed to qtool.
% IN    Q           Qarts structure
%       parts       Control file parts to include. See further above.
%       workfolder  Folder where calculations will be performed. Typically a
%                   temporary folder.
%
%             or
%
% FORMAT   parts = qarts2cfile( runtype )
%
% OUT   parts     As above
% IN    runtype   String describing type of calculation to perform.
%                 See further above.

% 2007-08-21   Large revision of function structure and code. PE 
% 
% 2004-09-08   Created by Patrick Eriksson (PE).


function S = qarts2cfile( Q, parts, workfolder )

%- Check input
%
if ~( nargin == 1  |  nargin == 3 )
  error( 'The function takes 1 or 3 input arguments.' );
end





%--- Version returning cfile parts --------------------------------------------
%
if nargin == 1
 
  if ~ischar( Q )
    error( 'If number of arguments is 1, this argument must be a string' );
  end

  switch Q

  case 'GetAtmSrf'
    %
    S = { 'Generl', 'AtmSrfSave', 'CloseF' };

  case 'GetAbsTable'
    %
    S = { 'Generl', 'AtmSrf', 'AbsrptSave', 'CloseF' };

  case 'GetSensor'
    %
    S = { 'Generl', 'AtmSrf', 'SensorSave', 'CloseF' };
   
  case 'y_init'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'SensorSave', ...
          'JacobiSave', 'CloseF' };
    
    case 'y'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'Sensor', 'Jacobi', ...
          'CldBox', 'SctMth', 'RteExe', 'CloseF' };

  case 'Batch'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'Sensor', 'Jacobi', ...
          'CldBox', 'SctMthBatch', 'BatchC', 'CloseF' };
    
  otherwise
    error( sprintf( 'Unknown cfile type (%s) was requested.', Q ) );
  end

  return    % --->
end
%------------------------------------------------------------------------------





%--- Version returning string struture ----------------------------------------

qcheck( @qarts, Q );

S    = {};

for ip = 1 : length(parts)

  T = [];

  switch parts{ip}(1:6)
    
   case 'Generl'
    %
    T = cfile_Generl( Q, parts{ip}, workfolder );

   case 'CloseF'
    %
    T = cfile_CloseF( Q, parts{ip}, workfolder );
    
   case 'AtmSrf'
    %
    T = cfile_AtmSrf( Q, parts{ip}, workfolder );
   
   case 'Absrpt'
    %
    T = cfile_Absrpt( Q, parts{ip}, workfolder );
   
   case 'RteSet'
    %
    T = cfile_RteSet( Q, parts{ip}, workfolder );
   
   case 'Sensor'
    %
    T = cfile_Sensor( Q, parts{ip}, workfolder );
    
   case 'Jacobi'
    %
    T = cfile_Jacobi( Q, parts{ip}, workfolder );
   
   case 'CldBox'
    %
    T = cfile_CldBox( Q, parts{ip}, workfolder );
   
   case 'SctMth'
    %
    T = cfile_SctMth( Q, parts{ip}, workfolder );
   
   case 'RteExe'
    %
    T = cfile_RteExe( Q, parts{ip}, workfolder );

   case 'BatchC'
    %
    T = cfile_BatchC( Q, parts{ip}, workfolder );
    
   otherwise
    error( sprintf( 'Unknown cfile part (%s) was requested.', parts{ip} ) );
  end
  
  if ~isempty(T)
   S = { S{:} T{:} };
  end

end

return
%------------------------------------------------------------------------------
%--- End main
%------------------------------------------------------------------------------





%------------------------------------------------------------------------------
%--- Sub-functions for main control file parts
%------------------------------------------------------------------------------



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    Start of cfile
%    output_file_format
%    stokes_dim
%    f_grid  
%    abs_species
%
function T = cfile_Generl( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'Generl' )  |  strcmp( partname, 'GenerlSave' ) )
    error( 'Only recognised choices are ''Generl'' and ''GenerlSave''.' );
  end
  %
  T{1} = [ '# Control file created by Atmlab function *qarts2cfile*' ];
  T{2} = 'Arts2{';
  %
  if qarts_isset( Q. WSMS_AT_START )
    T = add_wsms( T, ' WSMS_AT_START', Q. WSMS_AT_START );
  end
  %
  T = add_includes( T, 'Q.INCLUDES', Q.INCLUDES );
  %
  if qarts_isset( Q.OUTPUT_FILE_FORMAT )
    if strcmp( Q.OUTPUT_FILE_FORMAT, 'binary' )  
      T{end+1} = 'output_file_formatSetBinary';
    elseif strcmp( Q.OUTPUT_FILE_FORMAT, 'ascii' )  
      T{end+1} = 'output_file_formatSetAscii';
    else
      error( 'Q.OUTPUT_FILE_FORMAT must be ''binary'' or ''ascii''.' );
    end
  end
  %
  if qarts_isset( Q.STOKES_DIM )
    rqre_scalar( 'Qarts field STOKES_DIM', Q.STOKES_DIM, 1, 4 );
    T{end+1} = sprintf( 'IndexSet(stokes_dim,%d)', Q.STOKES_DIM );
  end
  %  
  if qarts_isset( Q.F_GRID )
    T{end+1} = file_or_data( 'f_grid', 'Vector', Q.F_GRID, workfolder );
  end
  %
  if qarts_isset( Q.ABS_SPECIES )
    rqre_datatype( 'cell', Q.ABS_SPECIES )
    T{end+1} = sprintf( 'SpeciesSet(abs_species,[%s])', ...
                                               arts_tgs_cnvrt(Q.ABS_SPECIES) );
  end
  %
  if strcmp( partname, 'GenerlSave' )
    T{end+1} = add_savefile( 'output_file_format', workfolder );
    T{end+1} = add_savefile( 'stokes_dim', workfolder );
    T{end+1} = add_savefile( 'f_grid', workfolder );
    T{end+1} = add_savefile( 'abs_species', workfolder );
  end  
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    Closing of cfile
%    WSMS_AT_END
%
function T = cfile_CloseF( Q, partname, workfolder )
  %
  T = [];
  %
  if qarts_isset( Q. WSMS_AT_END )
    T = add_wsms( T, ' WSMS_AT_END', Q. WSMS_AT_END );
  end
  %
  T{end+1} = '}';
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    atmosphere_dim
%    p_grid
%    lat_grid
%    lon_grid
%    t_field
%    z_field
%    vmr_field
%    r_geoid
%    z_surface
%
function T = cfile_AtmSrf( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'AtmSrf' )  |  strcmp( partname, 'AtmSrfSave' ) )
    error( 'Only recognised choices are ''AtmSrf'' and ''AtmSrfSave''.' );
  end
  %
  T = [];
  %
  if qarts_isset( Q.ATMOSPHERE_DIM )
    rqre_scalar( 'Qarts field ATMOSPHERE_DIM', Q.ATMOSPHERE_DIM, 1, 3 );
    T{end+1} = sprintf( 'AtmosphereSet%dD', Q.ATMOSPHERE_DIM );
  end
  %
  if qarts_isset( Q.P_GRID )
    T{end+1} = file_or_data( 'p_grid', 'Vector', Q.P_GRID, workfolder );
  end
  %
  if qarts_isset( Q.LAT_GRID )
    T{end+1} = file_or_data( 'lat_grid', 'Vector', Q.LAT_GRID, workfolder );
  end
  if qarts_isset( Q.LON_GRID )
    T{end+1} = file_or_data( 'lon_grid', 'Vector', Q.LON_GRID, workfolder );
  end
  %
  if qarts_isset( Q.USE_RAW_ATMOSPHERE )
    rqre_bool( 'Qarts field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
    if Q.USE_RAW_ATMOSPHERE
      rqre_char( 'Qarts field RAW_ATMOSPHERE', Q.RAW_ATMOSPHERE );
      if qarts_isset( Q.RAW_ATM_EXPAND_1D )
        rqre_bool( 'Qarts field RAW_ATM_EXPAND_1D', Q.RAW_ATM_EXPAND_1D );
      end
      T{end+1} = sprintf( ...
       'AtmRawRead(t_field_raw,z_field_raw,vmr_field_raw,abs_species,"%s")',...
                                                            Q.RAW_ATMOSPHERE );
      if qarts_isset( Q.RAW_ATM_EXPAND_1D ) & Q.RAW_ATM_EXPAND_1D
        T{end+1} = 'AtmFieldsCalcExpand1D';
      else
        T{end+1} = 'AtmFieldsCalc';
      end
    else
      if qarts_isset( Q.T_FIELD )
        T{end+1} = file_or_data( 't_field', 'Tensor3', Q.T_FIELD, workfolder );
      end      
      if qarts_isset( Q.VMR_FIELD )
        T{end+1} = file_or_data( 'vmr_field', 'Tensor4', Q.VMR_FIELD, ...
                                                                   workfolder);
      end      
      if qarts_isset( Q.Z_FIELD )
        T{end+1} = file_or_data( 'z_field', 'Tensor3', Q.Z_FIELD, workfolder );
      end
    end
  end
  %
  if qarts_isset(Q.R_GEOID)
    if isscalar( Q.R_GEOID )
      T{end+1} = sprintf( ...
          'r_geoidSpherical(r_geoid,atmosphere_dim,lat_grid,lon_grid,%e)', ...
                                                                   Q.R_GEOID );
    else
      T{end+1} = file_or_data( 'r_geoid', 'Matrix', Q.R_GEOID, workfolder );
    end
  end
  %
  if qarts_isset(Q.Z_SURFACE)
    if isscalar( Q.Z_SURFACE )
      T{end+1} = 'ncolsGet( ncols, r_geoid )';
      T{end+1} = 'nrowsGet( nrows, r_geoid )';
      T{end+1} = sprintf('MatrixSetConstant(z_surface,nrows,ncols,%.3f)', ...
                                                                  Q.Z_SURFACE );
    else
      T{end+1} = file_or_data( 'z_surface', 'Matrix', Q.Z_SURFACE, workfolder );
    end
  end
  %
  if strcmp( partname, 'AtmSrfSave' )
    T{end+1} = add_savefile( 'atmosphere_dim', workfolder );
    T{end+1} = add_savefile( 'p_grid', workfolder );
    T{end+1} = add_savefile( 'lat_grid', workfolder );
    T{end+1} = add_savefile( 'lon_grid', workfolder );
    T{end+1} = add_savefile( 't_field', workfolder );
    T{end+1} = add_savefile( 'z_field', workfolder );
    T{end+1} = add_savefile( 'vmr_field', workfolder );
    T{end+1} = add_savefile( 'r_geoid', workfolder );
    T{end+1} = add_savefile( 'z_surface', workfolder );
  end
  
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    basic absorption variables, such as abs_lines (if used)
%    abs_lookup  (if used)
%    abs_scalar_gas_agenda
%    emission_agenda
%
function T = cfile_Absrpt( Q, partname, workfolder )
  %
  abstable = false;
  %
  T = {};
  %
  if ~( strcmp( partname, 'Absrpt' )  |  strcmp( partname, 'AbsrptSave' ) )
    error( 'Only recognised choices are ''Absrpt'' and ''AbsrptSave''.' );
  end
  %
  if qarts_isset( Q.ABSORPTION )
    rqre_char( 'Qarts field ABSORPTION', Q.ABSORPTION );
    %
    if ~( strcmp(Q.ABSORPTION,'OnTheFly') | ...
          strcmp(Q.ABSORPTION,'LoadTable') | strcmp(Q.ABSORPTION,'CalcTable') )
      error( 'Only recognised choices for *ABSORPTION* are ''OnTheFly'', ',...
                                          '''LoadTable'' and ''CalcTable''.' );
    end
    %
    if strcmp(Q.ABSORPTION,'OnTheFly') | strcmp(Q.ABSORPTION, 'CalcTable')
      %
      nset = qarts_isset( Q.ABS_LINESHAPE )  +  ...
             qarts_isset( Q.ABS_LINESHAPE_FACTOR ) + ...
             qarts_isset( Q.ABS_LINESHAPE_CUTOFF );
      %
      if nset  
        if nset < 3
          error( ['Q.ABS_LINESHAPE, Q.ABS_LINESHAPE_FACTOR, and ', ...
         'Q.ABS_LINESHAPE_CUTOFF must all be left empty ({}), or all be set.']);
        end
        %
        if ischar(Q.ABS_LINESHAPE) & ischar(Q.ABS_LINESHAPE_FACTOR) & ...
                                               isscalar(Q.ABS_LINESHAPE_CUTOFF)
          T{end+1} = ...
              sprintf( 'abs_lineshapeDefine(abs_lineshape,"%s","%s",%e)',...
             Q.ABS_LINESHAPE, Q.ABS_LINESHAPE_FACTOR, Q.ABS_LINESHAPE_CUTOFF );
        else     
          error( ['Q.ABS_LINESHAPE,Q.ABS_LINESHAPE_FACTOR, and ', ...
                  'Q.ABS_LINESHAPE_CUTOFF must either be NaNs or ', ...
                  'char, char, and scalar respectively.']);
        end
      end
      %
      if qarts_isset( Q.ABS_LINES_FORMAT )
        %
        rqre_datatype( 'char', Q.ABS_LINES_FORMAT );
        %
        if strcmp( upper(Q.ABS_LINES_FORMAT), 'NONE' )
          T{end+1} = 'abs_lines_per_speciesSetEmpty';
        else
          %
          rqre_datatype( {'char','struct','empty'}, Q.ABS_LINES );
          %
          if strcmp(upper(Q.ABS_LINES_FORMAT),'ARTS') & ~ischar(Q.ABS_LINES)
            filename = fullfile( workfolder, 'abs_lines.xml' );
            T{end+1} = file_or_data( 'abs_lines', 'ArrayOfLineRecord', ...
                                                      Q.ABS_LINES,workfolder );
          else
            if ~ischar( Q.ABS_LINES )
              error( 'Q.ABS_LINES must be a filename for formats beside Arts.' );
            end
            filename = Q.ABS_LINES;
          end
          %
          T{end+1} = sprintf( 'abs_linesReadFrom%s(abs_lines,"%s",0,1e99)', ...
                                                Q.ABS_LINES_FORMAT, filename );
          T{end+1} = 'abs_lines_per_speciesCreateFromLines';
        end
      end
      %
      T = add_includes( T, 'Q.ABS_MODELS', Q.ABS_MODELS );
      %
    end
    %
    if strcmp( Q.ABSORPTION, 'OnTheFly' )
      %
    elseif strcmp( Q.ABSORPTION, 'CalcTable' )
      %
      if qarts_isset( Q.ABS_P )
        T{end+1} = file_or_data( 'abs_p', 'Vector', Q.ABS_P, workfolder );
      end
      if qarts_isset( Q.ABS_T )
        T{end+1} = file_or_data( 'abs_t', 'Vector', Q.ABS_T, workfolder );
      end
      if qarts_isset( Q.ABS_T_PERT )
      T{end+1} = file_or_data( 'abs_t_pert', 'Vector', Q.ABS_T_PERT, ...
                                                                  workfolder );
      end
      if qarts_isset( Q.ABS_VMRS )
        T{end+1} = file_or_data( 'abs_vmrs', 'Matrix', Q.ABS_VMRS, ...
                                                                  workfolder );
      end
      if qarts_isset( Q.ABS_NLS )
        if isempty( Q.ABS_NLS )
          T{end+1} = 'SpeciesSet(abs_nls,[])';
        else
          T{end+1} = sprintf( 'SpeciesSet(abs_nls,[%s])', ...
                                  arts_tgs_cnvrt({Q.ABS_SPECIES{Q.ABS_NLS}}) );
        end
      
      end
      if qarts_isset( Q.ABS_NLS_PERT )
        T{end+1} = file_or_data( 'abs_nls_pert', 'Vector', Q.ABS_NLS_PERT, ...
                                                                  workfolder );
      
      end
      %
      T{end+1} = 'abs_lookupCreate'; 
      T        = add_agenda( T, 'abs_scalar_gas_agenda', ... 
                                       { 'abs_scalar_gasExtractFromLookup' } );
      %
      abstable = true;
      %   
    elseif strcmp( Q.ABSORPTION, 'LoadTable' )
      %
      T{end+1} = file_or_data( 'abs_lookup', 'GasAbsLookup', Q.ABS_LOOKUP, ...
                                                                  workfolder );
      T{end+1} = 'abs_lookupAdapt';
      T        = add_agenda( T, 'abs_scalar_gas_agenda', ...
                                       { 'abs_scalar_gasExtractFromLookup' } );
      %
      abstable = true;
      %
    end
  end %  qarts_isset( Q.ABSORPTION )

  
  if qarts_isset( Q.EMISSION_AGENDA )
    T = add_agenda( T, 'emission_agenda', Q.EMISSION_AGENDA );
  end

  if abstable  &  strcmp( partname, 'AbsrptSave' )
    T{end+1} = add_savefile( 'abs_lookup', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    surface_prop_agenda
%    iy_space_agenda
%    ppath_lmax
%    ppath_lraytrace
%    ppath_step_agenda
%    refr_index_agenda
%    rte_agenda
%    sensor_pos
%    sensor_los
%
function T = cfile_RteSet( Q, partname, workfolder )
  %
  if ~strcmp( partname, 'RteSet' )
    error( 'Only recognised choices is ''RteSet''.' );
  end
  %
  T = {};
  %
  if qarts_isset( Q.SURFACE_PROP_AGENDA )
    T = add_agenda( T, 'surface_prop_agenda', Q.SURFACE_PROP_AGENDA );
  end
  if qarts_isset( Q.IY_SPACE_AGENDA )
    T = add_agenda( T, 'iy_space_agenda', Q.IY_SPACE_AGENDA );
  end
  %T = add_agenda( T, 'jacobian_y_agenda', {'RteCalcNoJacobian'} );  
  if qarts_isset( Q.PPATH_LMAX )
    T{end+1} = sprintf( 'NumericSet( ppath_lmax, %.2e )', Q.PPATH_LMAX );
  end  
  if qarts_isset( Q.PPATH_LRAYTRACE )
    T{end+1} = sprintf( 'NumericSet( ppath_lraytrace, %.2e )', ...
                                                           Q.PPATH_LRAYTRACE );
  end  
  if qarts_isset( Q.PPATH_STEP_AGENDA )
    T = add_agenda( T, 'ppath_step_agenda', Q.PPATH_STEP_AGENDA );
  end
  if qarts_isset( Q.REFR_INDEX_AGENDA )
    T = add_agenda( T, 'refr_index_agenda', Q.REFR_INDEX_AGENDA );
  end
  if qarts_isset( Q.RTE_AGENDA )
    T = add_agenda( T, 'rte_agenda', Q.RTE_AGENDA );
  end
  if qarts_isset( Q.SENSOR_POS )
    T{end+1} = file_or_data( 'sensor_pos', 'Matrix', Q.SENSOR_POS,...
                                                                  workfolder );
  end
  if qarts_isset( Q.SENSOR_LOS )
    T{end+1} = file_or_data( 'sensor_los', 'Matrix', Q.SENSOR_LOS,...
                                                                  workfolder );
  end
  %
  T{end+1} = add_savefile( 'sensor_pos', workfolder );
  T{end+1} = add_savefile( 'sensor_los', workfolder );
  %
return



% Sub-function handling:
%
%    y
%    jacobian
%
function T = cfile_RteExe( Q, partname, workfolder )
  %
  if ~strcmp( partname, 'RteExe' )
    error( 'Only recognised choice is ''RteExe''.' );
  end
  %
  [T,do_mc] = add_rtecalc(Q);
   
  T{end+1} = add_savefile( 'y',     workfolder );
  T{end+1} = add_savefile( 'y_f',   workfolder );
  T{end+1} = add_savefile( 'y_pol', workfolder );
  T{end+1} = add_savefile( 'y_pos', workfolder );
  T{end+1} = add_savefile( 'y_los', workfolder );
  %
  if do_mc
    T{end+1} = add_savefile( 'mc_error', workfolder ); 
  end
  %
  if qarts_isset( Q.J_DO )  &  Q.J_DO
    T{end+1} = add_savefile( 'jacobian', workfolder );
  end
return



% Sub-function handling:
%
%    sensor variables
%
function T = cfile_Sensor( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'Sensor' )  |  strcmp( partname, 'SensorSave' ) )
    error( 'Only recognised choices are ''Sensor'' and ''SensorSave''.' );
  end

  do_parts = false;

  if ~qarts_isset( Q.SENSOR_DO )
     T = {};
  elseif ~Q.SENSOR_DO
    T{1} = 'sensorOff';
  elseif ischar(Q.SENSOR_RESPONSE)  |  issparse(Q.SENSOR_RESPONSE)
    T{1} = file_or_data( 'sensor_response', 'Sparse', ...
                                                Q.SENSOR_RESPONSE, workfolder );
    if qarts_isset( Q.ANTENNA_DIM )
      T{end+1} = file_or_data( 'antenna_dim', 'Index', ...
                                                    Q.ANTENNA_DIM, workfolder );
    end
    if qarts_isset( Q.MBLOCK_ZA_GRID )
      T{end+1} = file_or_data( 'mblock_za_grid', 'Vector', ...
                                                  Q.MBLOCK_ZA_GRID, workfolder);
    end
    if qarts_isset( Q.MBLOCK_AA_GRID )
      T{end+1} = file_or_data( 'mblock_aa_grid', 'Vector', ...
                                                  Q.MBLOCK_AA_GRID, workfolder);
    end
    if qarts_isset( Q.SENSOR_RESPONSE_F )
      T{end+1} = file_or_data( 'sensor_response_f', 'Vector', ...
                                              Q.SENSOR_RESPONSE_F, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_ZA )
      T{end+1} = file_or_data( 'sensor_response_za', 'Vector', ...
                                             Q.SENSOR_RESPONSE_ZA, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_AA )
      T{end+1} = file_or_data( 'sensor_response_aa', 'Vector', ...
                                             Q.SENSOR_RESPONSE_AA, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_POL )
      T{end+1} = file_or_data( 'sensor_response_pol', 'Index', ...
                                            Q.SENSOR_RESPONSE_POL, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_F_GRID )
      T{end+1} = file_or_data( 'sensor_response_f_grid', 'Vector', ...
                                     Q.SENSOR_RESPONSE_F_GRID, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_ZA_GRID )
      T{end+1} = file_or_data( 'sensor_response_za_grid', 'Vector', ...
                                     Q.SENSOR_RESPONSE_ZA_GRID, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_AA_GRID )
      T{end+1} = file_or_data( 'sensor_response_aa_grid', 'Vector', ...
                                     Q.SENSOR_RESPONSE_AA_GRID, workfolder );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_POL_GRID )
      T{end+1} = file_or_data( 'sensor_response_pol_grid', 'Index', ...
                                     Q.SENSOR_RESPONSE_POL_GRID, workfolder );
    end
  elseif iscellstr( Q.SENSOR_RESPONSE ) 
    T = add_includes( {}, 'Q.SENSOR_RESPONSE', Q.SENSOR_RESPONSE );
  elseif isstruct( Q.SENSOR_RESPONSE ) 
    do_parts = true;
  else
    error( 'Unrecognised choice for Q.SENSOR_RESPONSE.' );
  end

  %- Code for structure version:
  if do_parts
    
    H = Q.SENSOR_RESPONSE;
    %
    qcheck( @qartsSensor, H );

    % Find out sensor structure
    parts{1} = 'init';
    if qarts_isset( H.ANTENNA_LOS )  |  qarts_isset( H.ANTENNA_RESPONSE )
      parts{end+1} = 'antenna';
    end
    %if qarts_isset( H.SENSOR_ROT )
    %    parts{end+1} = 'rotation';
    %end
    %if qarts_isset( H.SENSOR_POL )
    %  parts{end+1} = 'polarisation';
    %end
    if qarts_isset( H.LO )  |  qarts_isset( H.SIDEBAND_RESPONSE )
      parts{end+1} = 'mixer';
    end
    if qarts_isset( H.F_BACKEND )  |  qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
      parts{end+1} = 'backend';
    end
    if qarts_isset( H.BEAM_SWITCHING )  &  H.BEAM_SWITCHING
      parts{end+1} = 'beamswitch';
    end
    % If multiple LO are given exchange 'mixer' and 'backend' for 'multimixer'
    if( strmatch( 'mixer', char(parts) )   & ...
        strmatch( 'backend', char(parts) ) & ...
        length(H.LO) > 1 ...
      )
      parts = rmfield( parts, {'mixer' 'backend'} );
      parts{end+1} = 'multimixer';
    end
    parts{end+1} = 'close';
        
    % Start writing to output structure
    T = {};

    for it = 1 : length(parts)
      %
      U = {};

      switch parts{it}

      case 'init'
        U{1} = ['# Start of sensor part:'];
        if qarts_isset( Q.ANTENNA_DIM ) 
          if( Q.ANTENNA_DIM == 1  |  Q.ANTENNA_DIM == 2 )
            U{end+1} = sprintf( 'AntennaSet%dD', Q.ANTENNA_DIM );
          else
            error('The field *ANTENNA_DIM* can only be set to 1 or 2.');
          end
        end
        if qarts_isset( Q.MBLOCK_ZA_GRID ) 
          U{end+1} = file_or_data( 'mblock_za_grid', 'Vector', ...
                                                 Q.MBLOCK_ZA_GRID, workfolder );
        
        end        
        if qarts_isset( Q.MBLOCK_AA_GRID ) 
          U{end+1} = file_or_data( 'mblock_aa_grid', 'Vector', ...
                                                  Q.MBLOCK_AA_GRID, workfolder);
        end
        if qarts_isset( H.SENSOR_NORM )
          if H.SENSOR_NORM == 0  |   H.SENSOR_NORM == 1
            U{end+1} = sprintf( 'IndexSet(sensor_norm,%d)', H.SENSOR_NORM );
          else
            error('The field *SENSOR_RESPONSE.SENSOR_NORM* can only be 0 or 1.')
          end 
        end
        U{end+1} = 'sensor_responseInit';
        
      case 'antenna'
        if qarts_isset( H.ANTENNA_LOS )
          U{end+1} = file_or_data( 'antenna_los', 'Matrix', H.ANTENNA_LOS, ...
                                                                   workfolder );
        end
        if qarts_isset( H.ANTENNA_RESPONSE )
          U{end+1} = file_or_data( 'antenna_response', 'GriddedField4',...
                                               H.ANTENNA_RESPONSE, workfolder );
        end
        U{end+1} = 'sensor_responseAntenna';
        
      %case 'rotation'
      %  U{1} = file_or_data( 'sensor_rot', 'Vector', H.SENSOR_ROT, workfolder );
      %  U{2} = 'sensor_responseRotation';

      %case 'polarisation'
      %  U{1} = file_or_data( 'sensor_pol', 'Matrix', H.SENSOR_POL, workfolder );
      %  U{2} = 'sensor_responsePolarisation';
          
      case 'mixer'
        if qarts_isset( H.LO ) 
          U{end+1} = file_or_data( 'lo', 'Numeric', H.LO, workfolder );
        end
        if qarts_isset( H.SIDEBAND_RESPONSE )           
          U{end+1} = file_or_data( 'sideband_response', 'GriddedField1', ...
                                              H.SIDEBAND_RESPONSE, workfolder );
        end   
        U{end+1} = 'sensor_responseMixer';

      case 'backend'
        if qarts_isset( H.F_BACKEND ) 
          U{end+1} = file_or_data( 'f_backend', 'Vector', H.F_BACKEND, ...
                                                                   workfolder );
        end        
        if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
          U{end+1} = file_or_data( 'backend_channel_response', ....
               'ArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, workfolder );
        end
        U{end+1} = 'sensor_responseBackend';
        
      case 'multimixer'
        if qarts_isset( H.LO ) 
          U{end+1} = file_or_data( 'lo', 'Vector', H.LO, workfolder );
        end
        if qarts_isset( H.SIDEBAND_RESPONSE )           
          U{end+1} = file_or_data( 'sideband_response_multi', ...
                      'ArrayOfGriddedField1', H.SIDEBAND_RESPONSE, workfolder );
        end   
        if qarts_isset( H.F_BACKEND ) 
          U{end+1} = file_or_data( 'f_backend_multi', 'ArrayOfVector', ...
                                                      H.F_BACKEND, workfolder );
        end        
        if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
          U{end+1} = file_or_data( 'backend_channel_response_multi', ....
                 'ArrayOfArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, ... 
                                                                   workfolder );
        end
        U{6} = 'sensor_responseMultiMixerBackend';
        
      case 'beamswitch'
        U{1} = 'sensor_responseBeamSwitching';
        
      case 'close'
        U{1} = '# End of sensor part';

      otherwise
        error(sprintf('Unknown action (%s) was requested.',parts{it}));
      end

      T = { T{:} U{:} };

    end
  end
  
  %- Saving
  %
  if strcmp( partname, 'SensorSave' )
    T{end+1} = add_savefile( 'sensor_response',          workfolder );
    T{end+1} = add_savefile( 'sensor_response_f',        workfolder );
    T{end+1} = add_savefile( 'sensor_response_za',       workfolder );
    T{end+1} = add_savefile( 'sensor_response_aa',       workfolder );
    T{end+1} = add_savefile( 'sensor_response_pol',      workfolder );
    T{end+1} = add_savefile( 'sensor_response_f_grid',   workfolder );
    T{end+1} = add_savefile( 'sensor_response_za_grid',  workfolder );
    T{end+1} = add_savefile( 'sensor_response_aa_grid',  workfolder );
    T{end+1} = add_savefile( 'sensor_response_pol_grid', workfolder );
    T{end+1} = add_savefile( 'antenna_dim',              workfolder );
    T{end+1} = add_savefile( 'mblock_za_grid',           workfolder );
    T{end+1} = add_savefile( 'mblock_aa_grid',           workfolder );
  end

return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    jacobians
%
function T = cfile_Jacobi( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'Jacobi' ) |  strcmp( partname, 'JacobiSave' ) )
    error( 'Only recognised choices are ''Jacobi'' and ''JacobiSave''.' );
  end

  do_parts = false;
  
  if ~qarts_isset( Q.J_DO )
     T={};
  elseif ~Q.J_DO
    T{1} = 'jacobianOff';
  elseif isstruct( Q.J )
    do_parts = true;  % code below
  else
    error( 'Unknown selection for Q.JACOBIAN.' );
  end

  if do_parts

    qcheck( @qartsJacobian, Q.J );

    T{1} = 'jacobianInit';

    %- Gas species
    for i = 1 : length(Q.J.ABS_SPECIES)
      %
      rqre_field( Q.J.ABS_SPECIES(i), 'DO' );
      %
      if Q.J.ABS_SPECIES(i).DO
        %
        rqre_field( Q.J.ABS_SPECIES(i), 'METHOD' );
        rqre_char( 'Q.J.ABS_SPECIES.METHOD', Q.J.ABS_SPECIES(i).METHOD );
        rqre_field( Q.J.ABS_SPECIES(i), 'UNIT' );
        rqre_char( 'Q.J.ABS_SPECIES.UNIT', Q.J.ABS_SPECIES(i).UNIT );
        rqre_field( Q.J.ABS_SPECIES(i), 'GRID1' );
        rqre_field( Q.J.ABS_SPECIES(i), 'GRID2' );
        rqre_field( Q.J.ABS_SPECIES(i), 'GRID3' );
        %
        name1 = sprintf( 'gas%d_jac_p_grid', i );
        T{end+1} = create_var( name1, 'Vector' );
        T{end+1} = file_or_data( name1, 'Vector', Q.J.ABS_SPECIES(i).GRID1, ...
                                                            workfolder, name1 );
        name2 = sprintf( 'gas%d_jac_lat_grid', i );
        T{end+1} = create_var( name2, 'Vector' );
        T{end+1} = file_or_data( name2, 'Vector', Q.J.ABS_SPECIES(i).GRID2, ...
                                                            workfolder, name2 );
        name3 = sprintf( 'gas%d_jac_lon_grid', i );
        T{end+1} = create_var( name3, 'Vector' );
        T{end+1} = file_or_data( name3, 'Vector', Q.J.ABS_SPECIES(i).GRID3, ...
                                                            workfolder, name3 );

        T{end+1} = 'jacobianAddAbsSpecies(jacobian_quantities,jacobian_agenda,'; 
        T{end+1} = '   jacobian,atmosphere_dim,p_grid,lat_grid,lon_grid,';
        T{end+1} = sprintf( '  %s,%s,%s,', name1, name2, name3 );
        T{end+1} = sprintf( '  %s,', arts_tgs_cnvrt({Q.ABS_SPECIES{i}}) );
        T{end+1} = sprintf( '  "%s","%s",', Q.J.ABS_SPECIES(i).METHOD, ...
                                                      Q.J.ABS_SPECIES(i).UNIT );
        if strcmp( Q.J.ABS_SPECIES(i).METHOD, 'analytical' )
           T{end+1} = '  0.0)';
        elseif strcmp( Q.J.ABS_SPECIES(i).METHOD, 'perturbation' )
          rqre_field( Q.J.ABS_SPECIES(i), 'DX' );
          T{end+1} = sprintf( '  %.5e)', Q.J.ABS_SPECIES(i).DX );
        else
          error( sprintf('Unknown selection for J.ABS_SPECIES.METHOD (%s)',...
                                                  Q.J.ABS_SPECIES(i).METHOD ) );
        end
      end
    end

    %- Frequency
    %
    if Q.J.FREQUENCY.DO
      rqre_field( Q.J.FREQUENCY, 'DF' );
      rqre_field( Q.J.FREQUENCY, 'ORDER' );
      %
      if Q.J.FREQUENCY.ORDER < 0  &   Q.J.FREQUENCY.ORDER > 1
        error('Q.J.FREQUENCY.ORDER must be 0 or 1.');
      end
      T{end+1} = 'jacobianAddFreqShiftAndStretch(jacobian_quantities,';
      T{end+1} =  '   jacobian_agenda, jacobian, ';
      T{end+1} = sprintf( '   %.3e, %d )', Q.J.FREQUENCY.DF, ...
                                           Q.J.FREQUENCY.ORDER == 1 );
    end

  %- Pointing
    %
    if Q.J.POINTING.DO
      rqre_field( Q.J.POINTING, 'DZA' );
      rqre_field( Q.J.POINTING, 'POLY_ORDER' );
      
      T{end+1} = 'jacobianAddPointing(jacobian_quantities, jacobian_agenda,';
      T{end+1} =  '   jacobian, sensor_pos, sensor_time';
      T{end+1} = sprintf( '   %g,%d)', Q.J.POINTING.DZA, ...
                                                    Q.J.POINTING.POLY_ORDER );
    end

    %- Polyfit
    %
    if Q.J.POLYFIT.DO
      rqre_field( Q.J.POLYFIT, 'POLY_ORDER' );
      rqre_field( Q.J.POLYFIT, 'NO_POL_VARIATION' );
      rqre_field( Q.J.POLYFIT, 'NO_ZA_VARIATION' );
      rqre_field( Q.J.POLYFIT, 'NO_BLOCK_VARIATION' );
      %
      T{end+1} = 'jacobianAddPolyfit(jacobian_quantities, jacobian_agenda,';
      T{end+1} =  '   jacobian,sensor_response_pol_grid,sensor_response_f_grid,';
      T{end+1} =  '   sensor_response_za_grid, sensor_pos,';
      T{end+1} = sprintf( '   %d,%d,%d,%d)', Q.J.POLYFIT.POLY_ORDER, ...
                                             Q.J.POLYFIT.NO_POL_VARIATION, ...
                                             Q.J.POLYFIT.NO_ZA_VARIATION,...
                                             Q.J.POLYFIT.NO_BLOCK_VARIATION );
    end
    
    if length(T) > 1
      T{end+1} = 'jacobianClose';    
    else
      T{1} = 'jacobianOff';          
    end
  end  % do_parts
  
  %- Saving 
  %
  if strcmp( partname, 'JacobiSave' )
    T{end+1} = add_savefile( 'jacobian_quantities', workfolder );
    T{end+1} = add_savefile( 'jacobian_indices', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    cloudbox_on
%    cloudbox_limits
%    pnd_field
%    scat_data_raw
%    spt_calc_agenda
%    opt_prop_gas_agenda
%
function T = cfile_CldBox( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'CldBox' )  |  strcmp( partname, 'CldBoxSave' ) )
    error( 'Only recognised choices are ''CldBox'' and ''CldBoxSave''.' );
  end

  % add consistency checks: Q.CLOUDBOX.METHOD and  Q.CLOUDBOX.METHOD_PRMTRS
  
  if ~qarts_isset(Q.CLOUDBOX_DO)
     T={};
     return
  end
  
  if ~Q.CLOUDBOX_DO
    T{1} = 'cloudboxOff';
    return
  end
  
  if ~isstruct( Q.CLOUDBOX )
    error( 'Q.CLOUDBOX must be a structure if Q.CLOUD_BOX=1.' );
  end

  %= Check that all fields are present
  %
  qcheck( @qartsCloudbox, Q.CLOUDBOX );

  %= Cloudbox
  %
  if qarts_isset (Q.CLOUDBOX.LIMITS)
    if isvector(Q.CLOUDBOX.LIMITS) 
      if length(Q.CLOUDBOX.LIMITS) < 6
        limits = Q.CLOUDBOX.LIMITS;
        Q.CLOUDBOX.LIMITS = zeros(1,6);
        Q.CLOUDBOX.LIMITS(1:length(limits)) = limits;
      end
      T{1}     = 'cloudboxSetManuallyAltitude(';
      T{end+1} = '   cloudbox_on,cloudbox_limits,atmosphere_dim,z_field,';
      T{end+1} = sprintf( ...
       '   lat_grid,lon_grid,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f', Q.CLOUDBOX.LIMITS);
      T{end+1} = ')';
    else
      error('Not valid specification Q.CLOUDBOX.LIMITS.');
    end
  end

  %= Particle field and single scattering data
  %
  nset = qarts_isset(Q.CLOUDBOX.PND_FIELD) + qarts_isset(Q.CLOUDBOX.SCAT_DATA);
  %
  if nset == 1
    error( 'Q.CLOUDBOX.PND_FIELD and Q.CLOUDBOX.SCAT_DATA must both ',...
                                        'be set, or both be undefined ({}).' );
  end
  if nset
    if length(Q.CLOUDBOX.PND_FIELD) ~= length(Q.CLOUDBOX.SCAT_DATA)
      error( 'Q.CLOUDBOX.PND_FIELD and Q.CLOUDBOX.SCAT_DATA must have ',...
                                                              'same length.' );
    end
    %
    T{end+1}  = 'ParticleTypeInit';
    do_pfCALC = false;
    %
    for i = 1 : length(Q.CLOUDBOX.PND_FIELD)
      if isstr( Q.CLOUDBOX.SCAT_DATA{i} )
        sfile = Q.CLOUDBOX.SCAT_DATA{i};
      else
        sfile = fullfile( workfolder, sprintf( 'scat_data_raw_%d.xml', i ) );
        xmlStore( sfile, Q.CLOUDBOX.SCAT_DATA{i}, 'SingleScatteringData' );
      end
      if isstr( Q.CLOUDBOX.PND_FIELD{i} )
        pfile = Q.CLOUDBOX.PND_FIELD{i};
      else
        pfile = fullfile( workfolder, sprintf( 'pnd_field_raw_%d.xml', i ) ); 
        xmlStore( pfile, Q.CLOUDBOX.PND_FIELD{i}, 'GriddedField3' );
      end
      %
      if length(pfile)
        do_pfCALC = true;
      end
      %
      T{end+1} = 'ParticleTypeAdd(';
      T{end+1} = '   scat_data_raw,pnd_field_raw,atmosphere_dim,f_grid,';
      T{end+1} = '   p_grid,lat_grid,lon_grid,cloudbox_limits,';
      T{end+1} = sprintf('   "%s","%s"', sfile, pfile );
      T{end+1} = ')';
    end
    %
    if do_pfCALC 
      T{end+1} = 'pnd_fieldCalc';
    end
  end
      

  %= Agendas for scattering properties 
  %
  if qarts_isset(Q.CLOUDBOX.OPT_PROP_GAS_AGENDA)
    T = add_agenda( T, 'opt_prop_gas_agenda', Q.CLOUDBOX.OPT_PROP_GAS_AGENDA );
  end
  if qarts_isset(Q.CLOUDBOX.OPT_PROP_PART_AGENDA)
    T = add_agenda( T, 'opt_prop_part_agenda', Q.CLOUDBOX.OPT_PROP_PART_AGENDA);
  end
  if qarts_isset(Q.CLOUDBOX.SPT_CALC_AGENDA)
    T = add_agenda( T, 'spt_calc_agenda', Q.CLOUDBOX.SPT_CALC_AGENDA );
  end

  %= Saving?
  %
  if strcmp( partname, 'CldBoxSave' )
    T{end+1} = add_savefile( 'cloudbox_on', workfolder );
    T{end+1} = add_savefile( 'cloudbox_limits', workfolder );
    T{end+1} = add_savefile( 'pnd_field', workfolder );
    T{end+1} = add_savefile( 'scat_data_raw', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    variables for the different scattering methods
%
function T = cfile_SctMth( Q, partname, workfolder )
  %
 
  if ~( strcmp( partname, 'SctMth' )  |  strcmp( partname, 'SctMthSave' ) |...
        strcmp( partname, 'SctMthBatch' ) )
    error( ['Only recognised choices are ''SctMth'', ''SctMthSave'' ',...
            'and ''SctMthBatch''.']);
  end

  if ~qarts_isset(Q.CLOUDBOX_DO)  |  ~Q.CLOUDBOX_DO
     T={};
     return
  end
 
  % It is assumed that cfile_CldBox has been called and checks of Q.CLOUDBOX 
  % have been performed
  
  
  %= DOIT / MC
  %
  if strcmp( upper(Q.CLOUDBOX.METHOD), 'DOIT' )
    %
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'N_ZA_GRID', 0 );
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'N_AA_GRID', 0 );
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'ZA_GRID_OPT_FILE', 0 );
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'SCAT_ZA_INTERP', 0 );
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'EPSILON', 0 );
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, 'ALL_F', 0 );
    
    if( ~iswhole(Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID)  |  ...
        ~iswhole(Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID) )
      error( ['The parameter N_ZA_GRID and N_AA_GRID must be given as',...
       ' integer values.']);
    end
    
    if( ~(strcmp(Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP,'linear')  |  ...
          strcmp(Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP,'polynomial') ) )
      error( ['Unknown interpolation method. ',... 
                               'SCAT_ZA_INTERP can be linear or polynomial.']);
    end
    
    if isnumeric( Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE )
      filename = fullfile( workfolder, 'scat_za_grid.xml' ); 
      xmlStore( filename, Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE, 'Vector');
      Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE = filename;
    end
    
    T{1}     = sprintf( ...
                    'doit_za_interpSet(doit_za_interp,atmosphere_dim,"%s")', ...
                                      Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP );
    T{end+1} = 'DoitAngularGridsSet(';
    T{end+1} = '   doit_za_grid_size,scat_aa_grid,scat_za_grid,';
    T{end+1} = sprintf('   %d,%d,"%s"', Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID,...
                                      Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID, ...
                                    Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE );
    T{end+1} = ')';
    %
    T = add_agenda( T, 'doit_mono_agenda', { ...
           'DoitScatteringDataPrepare', ...
           'doit_i_fieldSetClearsky(', ...
           '   doit_i_field,scat_i_p,scat_i_lat,scat_i_lon,f_grid,f_index', ...
           sprintf( ...
           '   p_grid,lat_grid,lon_grid,cloudbox_limits,atmosphere_dim,%d', ...
                                          Q.CLOUDBOX.METHOD_PRMTRS.ALL_F ), ...
           ')', ...
           'doit_i_fieldIterate',...
           'DoitCloudboxFieldPut' } ...
    );
    %
    T = add_agenda( T, 'pha_mat_spt_agenda', { ...
        'pha_mat_sptFromDataDOITOpt' } );
    
    if isempty(Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE)
      T = add_agenda( T, 'doit_scat_field_agenda', ...
                                             { 'doit_scat_fieldCalc' } );
    else
      T = add_agenda( T, 'doit_scat_field_agenda', ...
                                             { 'doit_scat_fieldCalcLimb' } );
    end
    
    T = add_agenda( T, 'doit_rte_agenda', ...
                  { sprintf('doit_i_fieldUpdateSeq%dD',Q.ATMOSPHERE_DIM) } );
    T = add_agenda( T, 'doit_conv_test_agenda', { ...
         'doit_conv_flagAbsBT(', ...
         '   doit_conv_flag,doit_iteration_counter,doit_i_field,', ...
         sprintf('   doit_i_field_old,f_grid,f_index,[%s]', ...
         vector2commalist(Q.CLOUDBOX.METHOD_PRMTRS.EPSILON(1:Q.STOKES_DIM))),...
         ')' } ...
        );
    T = add_agenda( T, 'iy_cloudbox_agenda', { 'DoNothing(ppath, ppath)',...
            'DoNothing(rte_pos,rte_pos)', 'DoNothing(rte_los,rte_los)', ...
            'iyInterpCloudboxField' } );

    if ~strcmp( partname, 'SctMthBatch' )
      T{end+1} = 'CloudboxGetIncoming';
      T{end+1} = 'DoitInit';
      T{end+1} = 'ScatteringDoit';
    end
    
  elseif strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
    %
    T = {};
    %
  else
    error( 'Unknown choice for Q.CLOUDBOX.METHOD.' );
  end

return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    batch calculations
%
function T = cfile_BatchC( Q, partname, workfolder )

  error(' Batch part of *qarts2cfile* not updated.' );
  
  %- Some checks of data
  %
  if ~isstruct( Q.BATCH )
    error( 'Batch calculations can only be described by a structure.' );
  end
  %
  qcheck( @qartsBatch, Q.BATCH );
  %
  if length(Q.BATCH.DATA)  &  ~isstruct( Q.BATCH.DATA(1) )
    error( 'Q.BATCH.DATA must be a structure array.' );
  end
  %
  rqre_scalar( 'Q.BATCH.N', Q.BATCH.N, 1 );

  %- Store batch data and create batch_calc_agenda
  %
  T = [];
  A = [];
  %
  n_num = zeros(5,1);   % Number of "numeric" batch variables of different dim
  n_int = zeros(5,1);   % Same for index variables
  %
  for i = 1 : length( Q.BATCH.DATA )
    
    rqre_field( Q.BATCH.DATA(i), 'TYPE', 0 );
    rqre_char( sprintf('Q.BATCH{%d}.TYPE',i), Q.BATCH.DATA(i).TYPE );
    rqre_field( Q.BATCH.DATA(i), 'WSV', 0 );
    rqre_char( sprintf('Q.BATCH{%d}.WSV',i), Q.BATCH.DATA(i).WSV );
    rqre_field( Q.BATCH.DATA(i), 'X', 0 );
  
    %if size(Q.BATCH.DATA(i).X,1) < Q.BATCH.N 
    %  error( sprintf( ...
    %         'Q.BATCH.DATA{%d}.X contains fewer cases than Q.BATCH.N', i ) );
    %end

    %- Determine dimensionality and type (num or int) of variable
    %
    [dim,datatype] = arts_datatypes( Q.BATCH.DATA(i).TYPE );
    %
    if strcmp(datatype,'num')
      n_num(dim) = n_num(dim) + 1;
      vn         = n_num(dim);      % "variable number" 
    elseif strcmp(datatype,'int')
      n_int(dim) = n_int(dim) + 1;
      vn         = n_int(dim);      % "variable number" 
    else
      vn         = 1;               % Assume only one variable of other types
    end
    
    mainname  = Q.BATCH.DATA(i).WSV;
    batchtype = arts_datatypes( dim+1, datatype );
    batchname = sprintf( '%s_%d', lower(batchtype), vn );
    
    T{end+1} = file_or_data( batchname, batchtype, Q.BATCH.DATA(i).X, ...
                             workfolder, sprintf('%s_batch.xml',mainname) );
    A{end+1} = sprintf( '%sExtractFrom%s(%s,%s,ybatch_index)', ...
                        Q.BATCH.DATA(i).TYPE, ...
                        batchtype, ...
                        mainname, ...
                        batchname );
  end
  %
  Arc = add_rtecalc( Q );
  A   = { A{:} Q.BATCH.WSM{:} Arc{:} };
  %
  T = add_agenda( T, 'ybatch_calc_agenda', A );
  
  %- Make actual calculations
  %
  T{end+1} = sprintf( 'IndexSet(ybatch_n){%d}', Q.BATCH.N );
  T{end+1} = 'ybatchCalc';
  %
  T{end+1} = add_savefile( 'ybatch', workfolder );
  
return





%------------------------------------------------------------------------------
% Smaller help functions
%------------------------------------------------------------------------------

function s = create_var(artsvar,datatype)
  s = sprintf( '%sCreate(%s)', datatype, artsvar );
return


function s = file_or_data(artsvar,datatype,qvalue,workfolder,nonDefFileId)
  if ischar( qvalue )
    s = add_readfile( artsvar, qvalue );
  else
    if nargin >= 5
      filename = fullfile( workfolder, [nonDefFileId,'.xml'] );
    else
      filename = fullfile( workfolder, [artsvar,'.xml'] );
    end
    xmlStore( filename, qvalue, datatype );
    s = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  s = sprintf('ReadXML(%s,"%s")', artsvar, filename );
return


function s = add_savefile( artsvar, workfolder )
  filename = fullfile( workfolder, [ artsvar, '.xml' ] );
  s = sprintf('WriteXML(output_file_format,%s,"%s")', artsvar, filename );
return


function T = add_agenda( T, agenda, strarray )
  if ~iscellstr( strarray ) 
    error( ...
      sprintf('The agenda %s must be specified as cell array of strings.', ...
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


function T = add_includes( T, name, field );
  %
  if qarts_isset( field )
    if ~iscellstr( field )
      error( sprintf('%s must be given as a cell array of strings.',name) );
    end
    %
    arts_includes = atmlab( 'ARTS_INCLUDES' );
    %
    for i = 1 : length( field )
      if isnan( arts_includes )  &  strfind( field{i}, 'ARTS_INCLUDES' )
        error( 'Atmlab setting ARTS_INCLUDES is requested, but is not set.' );
      end
      s        = strrep( field{i}, 'ARTS_INCLUDES', arts_includes );
      T{end+1} = sprintf( 'INCLUDE "%s"', s );
    end
  end
return


function [T,do_mc] = add_rtecalc( Q )
  %
  T = {};
  %
  if qarts_isset( Q.Y_UNIT )
    if ischar(Q.Y_UNIT)
      T{end+1} = sprintf( 'StringSet(y_unit,"%s")', Q.Y_UNIT );
    else
      error( 'Q.Y_UNIT must either be a char.');
    end  
  end

  if qarts_isset( Q. WSMS_BEFORE_RTE )
    T = add_wsms( T, ' WSMS_BEFORE_RTE', Q. WSMS_BEFORE_RTE );
  end

  do_mc = 0;
    
  %----------
  %- MC 
  %----------
  if qarts_isset( Q.CLOUDBOX_DO )  &  Q.CLOUDBOX_DO  &  ...
                                        strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
    %
    % Some checks of Q.CLOUDBOX performed already in cfile_CldBox
    %
    do_mc = 1;
    %
    if ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'STD_ERR' )  |  ...
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_TIME' )  |  ...
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_ITER' )  |  ...
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'Z_FIELD_IS_1D' )       
      error( ['With Q.CLOUDBOX_DO=1 and MC method selected, ',...
              'CLOUDBOX.METHOD_PRMTRS must contain the fields: STD_ERR, ',...
              'MAX_TIME, MAX_ITER and Z_FIELD_IS_1D'] )
    end
    %
    rqre_datatype( 'scalar', Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR );
    rqre_datatype( 'scalar', Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME );
    rqre_datatype( 'scalar', Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER );
    rqre_bool( 'CLOUDBOX.METHOD_PRMTRS.Z_FIELD_IS_1D', ...
                        Q.CLOUDBOX.METHOD_PRMTRS.Z_FIELD_IS_1D );
    %
    T{end+1} = sprintf( 'NumericSet(mc_std_err,%.3e)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR );
    T{end+1} = sprintf( 'IndexSet(mc_max_time,%d)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME );
    T{end+1} = sprintf( 'IndexSet(mc_max_iter,%d)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER );
    T{end+1} = sprintf( 'IndexSet(mc_z_field_is_1D,%d)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.Z_FIELD_IS_1D );
    %
    T{end+1} = 'RteCalcMC';

    
  %----------
  %- Non-MC 
  %----------
  else
    %  
    if qarts_isset( Q.J_DO )  &  Q.J_DO
      % Existence of field UNIT made as part of cfile_Jacobi
      rqre_char( 'Qarts field J.UNIT', Q.J.UNIT );
      T{end+1} = sprintf( 'StringSet(jacobian_unit,"%s")', Q.J.UNIT );
      %
      T{end+1} = 'RteCalc';
      T{end+1} = 'jacobianCalc';
    else
      T{end+1} = 'RteCalcNoJacobian';
    end
  end

  if qarts_isset( Q. WSMS_AFTER_RTE )
    T = add_wsms( T, ' WSMS_BEFORE_RTE', Q. WSMS_AFTER_RTE );
  end

return  
%------------------------------------------------------------------------------
