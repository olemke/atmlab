% QARTS3CFILE  Builds a control file for ARTS
%
%    The function converts the settings and defintions in Q to control file
%    text. For a default call of the method, the settings in Q are included
%    in the following order:
%       Include files
%       WSMS_AT_START
%       ATMOSPHERE_DIM,
%       Workspace variables (WSVs)
%       Atmospheric Q-fields: ABS_SPECIES->abs_species,
%                             RAW_ATMOSPHERE,
%                             ABS_SPECIES->vmr_field,
%                             Z, T, WIND_U/V/W, MAG_U/V/W
%       Surface Q-fields: Z_SURFACE
%       HSE
%       ABSORPTION
%       WSMS_AT_HALFWAY
%       SENSOR
%       Retrieval (Jacobian + OEM)
%       SCATTERING
%       CHECKS_DO
%       WSMS_AT_END
%
%    The experienced user can change the order by defining *parts*. See the
%    code below for the modules that are at hand ('Start', 'End' etc).
%
%    The predefined full calculations are:
%       'All': A full run.
%
% FORMAT S = qarts3cfile( Q, wfolder[, parts, check_fields] )
%
% OUT   S            String cell array that can be passed to *strs2file*.
% IN    Q            Qarts3 structure
%       wfolder      Folder where calculations will be performed. Typically a
%                    temporary folder.
% OPT   parts        Control file parts to include. Default is 'All'.
%       check_fields Flag to control if all fields are recognised. Default is
%                    true.

% 2020-08-19   Patrick Eriksson

function S = qarts3cfile( Q, wfolder, parts, check_fields )
%
if nargin < 3 | isempty(parts)
  parts = 'All';
end
if nargin < 4
  check_fields = true;
end


%- Check that a reasoanble ARTS version is used
%
if ~strncmp( arts_version, 'arts-2.3.12', 11 )
  error( ['A relative late ARTS v2.3 should be used (at least not below ' ...
          '2.3.1200). Your version is %s.'], arts_version );
end


%- Expand *parts*?
%
if ischar( parts )
  switch parts
    case 'All'
      %
      parts = { 'Start', 'WSVs', 'AtmSurfFields', 'Absorption', ...
                'Halfway', 'Modules', 'End' };
    otherwise
      error( sprintf( 'Unknown option for string *parts* (%s).', parts ) );
  end
end


%- Expand Q to have fields for usage checking
%
fnames = fieldnames( Q );
%
for i = 1 : length(fnames)
  Q.(sprintf('USED_%s',fnames{i})) = false;
end


%- Loop parts and append cfile pieces
%
S    = {};
%
for ip = 1 : length(parts)

  switch parts{ip}
    case 'Start'
      %
      [T,Q] = do_start( Q, wfolder );

    case 'WSVs'
      %
      [T,Q] = do_WSVs( Q, wfolder );

    case 'AtmSurfFields'
      %
      [T,Q] = do_atmsurffields( Q, wfolder );

    case 'Absorption'
      %
      [T,Q] = do_absorption( Q, wfolder );

    case 'Halfway'
      %
      [T,Q] = do_halfway( Q, wfolder );

    case 'Modules'
      %
      [T,Q] = do_modules( Q, wfolder );

    case 'End'
      %
      [T,Q] = do_end( Q, wfolder );

    otherwise
      error( sprintf( 'Unknown cfile part (%s) was requested.', parts{ip} ) );
  end

  if ~isempty(T)
    S = { S{:} T{:} };
  end

end


%- Check if all fields have been used
%
if check_fields
  fnames = fieldnames( Q );
  first  = true;
  %
  for i = 1 : length(fnames)
    if strncmp( fnames{i}, 'USED_', 5 ) & ~Q.(fnames{i})
      if first
        fprintf( 'The Q provided includes these non-recognised fields:\n' );
        first = false;
      end
      fprintf( '  %s\n', fnames{i}(6:end) );
    end
  end
  if ~first
    error( 'Q must only contain fields that are recognised and used!' );
  end
end


return



%------------------------------------------------------------------------------
%--- Functions for individual parts
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
% Adds (in given order):
%    Start lines
%    Inlcude files
%    WSMS_AT_START
%    ATMOSPHERE_DIM
%
function [T,Q] = do_start( Q, wfolder )
  %
  T{1} = [ '# Control file created by Atmlab function *qarts3cfile*' ];
  T{2} = 'Arts2{';
  %
  T = add_includes( T, 'Q.INCLUDES', Q.INCLUDES );
  %
  if qarts_isset( Q.WSMS_AT_START )
    T = add_wsms( T, 'WSMS_AT_START', Q.WSMS_AT_START, Q, false, wfolder );
  end
  %
  if qarts_isset( Q.ATMOSPHERE_DIM )
    T{end+1} = sprintf( '  AtmosphereSet%dD', Q.ATMOSPHERE_DIM );
  end
  Q = ftick( Q, { 'INCLUDES', 'WSMS_AT_START', 'ATMOSPHERE_DIM' } );
return



%------------------------------------------------------------------------------
% Adds (in given order):
%    WSMS_AT_halfway
%
function [T,Q] = do_halfway( Q, wfolder )
  %
  T = [];
  %
  if qarts_isset( Q.WSMS_AT_HALFWAY )
    T = add_wsms( T, 'WSMS_AT_HALFWAY', Q.WSMS_AT_HALFWAY, Q, false, wfolder );
  end
  %
  Q = ftick( Q, { 'WSMS_AT_HALFWAY' } );
return



%------------------------------------------------------------------------------
% Adds (in given order):
%    WSMS_AT_END
%    Closing of cfile
%
function [T,Q] = do_end( Q, wfolder )
  %
  T = [];
  %
  if qarts_isset( Q.CHECKS_DO ) & Q.CHECKS_DO
    T{end+1} = '  lbl_checkedCalc';
    T{end+1} = '  abs_xsec_agenda_checkedCalc';
    T{end+1} = '  propmat_clearsky_agenda_checkedCalc';
    T{end+1} = '  atmfields_checkedCalc';
    T{end+1} = '  atmgeom_checkedCalc';
    T{end+1} = '  cloudbox_checkedCalc';
    % sensor_checkedCalc handled separately, to make iy_calc calculations simpler

  end
  %
  if qarts_isset( Q.WSMS_AT_END )
    T = add_wsms( T, 'WSMS_AT_END', Q.WSMS_AT_END, Q, false, wfolder );
  end
  %
  T{end+1} = '}';
  %
  Q = ftick( Q, { 'CHECKS_DO', 'WSMS_AT_END' } );
return



%------------------------------------------------------------------------------
% Adds (in given order):
%    All WSVs
%
function [T,Q] = do_WSVs( Q, wfolder )
  %
  T = [];
  format = Q.INPUT_FILE_FORMAT;
  Q = ftick( Q, { 'INPUT_FILE_FORMAT' } );
  %
  fnames = fieldnames( Q );
  %
  for i = 1 : length( fnames )
    fname = fnames{i};
    if fname(1) >= 'a' & fname(1) <= 'z'
      group = wsv2group( fname );
      if strcmp( group, 'Agenda' )
        T = add_agenda( T, fname, Q.(fname), Q, wfolder );
      else
        T = file_or_data( T, fname, group, Q.(fname), Q, wfolder, format );
      end
      Q = ftick( Q, { fname } );
    elseif length(fname) > 4 & strcmp( fname(end+[-3:0]), '_WSV' ) & ...
                              ~strcmp( fname(1:5), 'USED_' )
      ius = strfind( fname, '_' );
      if length(ius) < 2
        error(sprintf('*%s* is not a valid definition of a non-std WSV.',fname));
      end
      group = fname( ius(end-1)+1 : ius(end)-1 );
      wsv = lower( fname( 1 : ius(end-1)-1 ) );
      T{end+1} = sprintf( '  %sCreate(%s)', group, wsv );
      if strcmp( group, 'Agenda' )
        T = add_agenda( T, wsv, Q.(fname), Q, wfolder );
      else
        T = file_or_data( T, wsv, group, Q.(fname), Q, wfolder, format );
      end
      Q = ftick( Q, { fname } );
    end
  end
return



%------------------------------------------------------------------------------
% Adds (in given order):
%    RAW_ATMOSPHERE
%    HSE
%
function [T,Q] = do_atmsurffields( Q, wfolder )
  %
  T = [];
  %
  if qarts_isset( Q.ABS_SPECIES )
    T{end+1} = sprintf( '  abs_speciesSet(species=[%s])', ...
                                           arts_tgs_cnvrt(Q.ABS_SPECIES) );
  end
  %
  if qarts_isset( Q.RAW_ATMOSPHERE )
    T{end+1} = sprintf( '  AtmRawRead(basename="%s")', Q.RAW_ATMOSPHERE );
    if qarts_isset( Q.RAW_ATM_EXPAND_1D ) & Q.RAW_ATM_EXPAND_1D
      wsm = '  AtmFieldsCalcExpand1D';
    else
      wsm = '  AtmFieldsCalc';
    end
    T{end+1} = sprintf( '%s(vmr_zeropadding=%d)', wsm, 1 );
  end
  %
  if qarts_isset( Q.Z_SURFACE )
    T = file_or_data( T, 'z_surface', 'Matrix', Q.Z_SURFACE, Q, wfolder, ...
                      Q.INPUT_FILE_FORMAT );
  end
  %
  if Q.HSE.ON
    T{end+1} = sprintf( '  NumericSet(p_hse,%.3f)', Q.HSE.P );
    T{end+1} = sprintf( '  NumericSet(z_hse_accuracy,%.3f)', Q.HSE.ACCURACY );
    if qarts_isset( Q.CHECKS_DO ) & Q.CHECKS_DO
      T{end+1} = '  atmfields_checkedCalc';
    end
    T{end+1} = '  z_fieldFromHSE';
  else
    % If defined set p/z_hse to simplify t-retrievals without HSE
    if isfield( Q.HSE, 'P' )
      T{end+1} = sprintf( '  NumericSet(p_hse,%.3f)', Q.HSE.P );
    end
    if isfield( Q.HSE, 'ACCURACY' )
      T{end+1} = sprintf( '  NumericSet(z_hse_accuracy,%.3f)', Q.HSE.ACCURACY );
    end
  end
  %
  Q = ftick( Q, { 'ABS_SPECIES', 'RAW_ATMOSPHERE', 'RAW_ATM_EXPAND_1D' } );
  Q = ftick( Q, { 'Z_SURFACE', 'HSE' } );
return



%------------------------------------------------------------------------------
% Adds (in given order):
%     ABSORPTION
%
function [T,Q] = do_absorption( Q, wfolder )
  %
  T = [];
  %
  if qarts_isset( Q.ABSORPTION )
    rqre_datatype( Q.ABSORPTION, @ischar, 'Q.ABSORPTION' );
    %
    if ~( strcmp(Q.ABSORPTION,'OnTheFly') | ...
          strcmp(Q.ABSORPTION,'LoadTable') | ...
          strcmp(Q.ABSORPTION,'CalcTable') )
      error( ['Only recognised choices for *ABSORPTION* are ',...
                       '''OnTheFly'', ''LoadTable'' and ''CalcTable''.'] );
    end
    %
    if strcmp(Q.ABSORPTION,'OnTheFly') | strcmp(Q.ABSORPTION, 'CalcTable')
      %
      if qarts_isset( Q.ABS_LINES_FORMAT )
        %
        rqre_datatype( Q.ABS_LINES_FORMAT, @ischar, 'Q.ABS_LINES_FORMAT' );
        %
        if strcmp( upper(Q.ABS_LINES_FORMAT), 'NONE' )
          T{end+1} = '  abs_lines_per_speciesSetEmpty';
        else
          %
          if strcmp(upper(Q.ABS_LINES_FORMAT),'XML')
            rqre_datatype( Q.ABS_LINES, {@ischar,@iscellstr}, 'Q.ABS_LINES' );
            if ischar( Q.ABS_LINES )
              T = file_or_data( T, 'abs_lines', 'ArrayOfAbsorptionLines', ...
                                Q.ABS_LINES, wfolder, Q.INPUT_FILE_FORMAT );
            else
              T = file_or_data( T, 'abs_lines', 'ArrayOfAbsorptionLines', ...
                                Q.ABS_LINES{1}, wfolder, Q.INPUT_FILE_FORMAT );
              T{end+1} = '  ArrayOfAbsorptionLinesCreate( appending_lines )';
              for i = 2 : length(Q.ABS_LINES)
                T = file_or_data( T, 'appending_lines', 'ArrayOfAbsorptionLines', ...
                                  Q.ABS_LINES{i}, wfolder, Q.INPUT_FILE_FORMAT );
                T{end+1} = '  abs_linesAppendWithLines(abs_lines,appending_lines,0)';
              end
            end
          else
            if ~ischar( Q.ABS_LINES )
              error( ...
               'Q.ABS_LINES must be a filename for formats beside XML.' );
            end
            filename = Q.ABS_LINES;
            %
            if qarts_isset( Q.ABS_LINES_FLIMS )
              if ~( isnumeric( Q.ABS_LINES_FLIMS )  &  ...
                    length( Q.ABS_LINES_FLIMS ) == 2 )
                error( ...
                 'If set, Q.ABS_LINES_FLIMS must be a vector of length 2' );
              end
              f1 = Q.ABS_LINES_FLIMS(1);
              f2 = Q.ABS_LINES_FLIMS(2);
            else
                f1 = 0;
                f2 = 1e99;
            end
            T{end+1} = sprintf( '  Read%s(abs_lines,"%s",%.3e,%.3e,"","")', ...
                                upper(Q.ABS_LINES_FORMAT), filename, f1, f2 );
            %
            if qarts_isset( Q.ABS_LINESHAPE )
              rqre_datatype( Q.ABS_LINESHAPE, @ischar, 'Q.ABS_LINESHAPE' );
              T{end+1} = sprintf( '  abs_linesSetLineShapeType(abs_lines,"%s")', ...
                                 Q.ABS_LINESHAPE );
            end
            %
            if qarts_isset( Q.ABS_LINESHAPE_FACTOR )
              rqre_datatype( Q.ABS_LINESHAPE_FACTOR, @ischar, ...
                             'Q.ABS_LINESHAPE_FACTOR' ); ...
              T{end+1} = sprintf( '  abs_linesSetNormalization(abs_lines,"%s")', ...
                                  Q.ABS_LINESHAPE_FACTOR );
            end
            %
            if qarts_isset( Q.ABS_LINESHAPE_CUTOFF )
              rqre_datatype( Q.ABS_LINESHAPE_CUTOFF, @istensor0, ...
                             'Q.ABS_LINESHAPE_CUTOFF' );
              if Q.ABS_LINESHAPE_CUTOFF < 0
                T{end+1} = sprintf( '  abs_linesSetCutoff(abs_lines,"None",-1)' );
              else
                T{end+1} = sprintf( '  abs_linesSetCutoff(abs_lines,"ByLine",%e)', ...
                                    Q.ABS_LINESHAPE_CUTOFF );
              end
            end
            %
            if qarts_isset( Q.ABS_LINESHAPE_MIRRORING )
              rqre_datatype( Q.ABS_LINESHAPE_MIRRORING, @ischar, ...
                             'Q.ABS_LINESHAPE_MIRRORING' ); ...
              T{end+1} = sprintf( '  abs_linesSetMirroring(abs_lines,"%s")', ...
                                  Q.ABS_LINESHAPE_MIRRORING );
            end
            %
          end
          %
          T{end+1} = '  abs_lines_per_speciesCreateFromLines';
          %
        end  % not NONE
      end
    end

    if ~isfield( Q, 'abs_xsec_agenda' )
      T = add_agenda( T, 'abs_xsec_agenda', { ...
                         'abs_xsec_per_speciesInit', ...
                         'abs_xsec_per_speciesAddLines', ...
                         'abs_xsec_per_speciesAddConts' }, ...
                      Q, wfolder );
    end

    if strcmp( Q.ABSORPTION, 'OnTheFly' )
      %
      if ~isfield( Q, 'propmat_clearsky_agenda' )
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
                           'Ignore(rtp_mag)', 'Ignore(rtp_los)', ...
                           'propmat_clearskyInit', 'propmat_clearskyAddOnTheFly' }, ...
                        Q, wfolder );                            
      end
      %
    elseif strcmp( Q.ABSORPTION, 'CalcTable' )
      %
      T{end+1} = '  abs_lookupCalc';
      if ~isfield( Q, 'propmat_clearsky_agenda' )
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
                           'Ignore(rtp_mag)', 'Ignore(rtp_los)', ...
                           'Ignore(rtp_nlte)', 'propmat_clearskyInit', ...
                           'propmat_clearskyAddFromLookup' }, ...
                        Q, wfolder );                            
      end
      %
      abstable = true;
      %
    elseif strcmp( Q.ABSORPTION, 'LoadTable' )
      %
      T{end+1} = '  abs_lookupAdapt';
      if ~isfield( Q, 'propmat_clearsky_agenda' )
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
                           'Ignore(rtp_mag)', 'Ignore(rtp_los)', ...
                           'Ignore(rtp_nlte)', 'propmat_clearskyInit', ...
                           'propmat_clearskyAddFromLookup' }, ...
        Q, wfolder );                            
      end
      %
      abstable = true;
      %
    end
  end %  qarts_isset( Q.ABSORPTION )
  %
  Q = ftick( Q, { 'ABSORPTION' } );
  %
return


%------------------------------------------------------------------------------
% Adds (in given order):
%     SENSOR
%     J
%     SCATTERRING
%
function [T,Q] = do_modules( Q, wfolder )
  %
  T = {};
  
  %--- Sensor
  if qarts_isset( Q.SENSOR_DO )
    if ~Q.SENSOR_DO
      T{end+1} = '  sensorOff';
      T{end+1} = '  AntennaOff';
      T{end+1} = '  FlagOn(sensor_checked)';    
    else
      % Cfile text 
      if iscellstr( Q.SENSOR )
        T = add_wsms( T, 'SENSOR', Q.SENSOR, Q, false, wfolder );
      % Defined as structure
      else
        H = Q.SENSOR;
        qcheck( @qartsSensor, H );
        % Find out sensor structure
        parts{1} = 'init';
        if qarts_isset( H.STOKES_ROTATION )
          parts{end+1} = 'rotation';
        end
        if qarts_isset( H.INSTRUMENT_POL )
          parts{end+1} = 'polarisation';
        end
        if qarts_isset( H.ANTENNA_DO ) & H.ANTENNA_DO
          parts{end+1} = 'antenna';
        end
        if qarts_isset( H.FILL_FGRID )
          parts{end+1} = 'fill_fgrid';
        end
        if qarts_isset( H.MIXER_DO ) & H.MIXER_DO
          parts{end+1} = 'mixer';
        end
        if qarts_isset( H.IF2RF ) & H.IF2RF
          parts{end+1} = 'if2rf';
        end
        if qarts_isset( H.BACKEND_DO ) & H.BACKEND_DO
          parts{end+1} = 'backend';
        end
        if qarts_isset( H.BEAM_SWITCHING )  &  H.BEAM_SWITCHING
          parts{end+1} = 'beamswitch';
        end
        % If multiple LO are given exchange 'mixer' for 'multimixer' and 'remove
        % 'backend'
        if( any(strcmp( 'mixer', parts ))   &  ...
            any(strcmp( 'backend', parts )) &  length(H.LO) > 1 )
          %
          ir        = find( strcmp('mixer',parts) );
          parts{ir} = 'multimixer';
          parts     = parts{ find( ~strcmp('backend',parts) ) };
        end
        parts{end+1} = 'close';

        for it = 1 : length(parts)
          %
          U = {};

          switch parts{it}

          case 'init'
            U{1} = ['  # Start of sensor part:'];
            if qarts_isset( H.ANTENNA_DO )  &  ~H.ANTENNA_DO
              U{end+1} = '  AntennaOff';
            end
            if qarts_isset( H.SENSOR_NORM )
              rqre_datatype( H.SENSOR_NORM, @isboolean, ...
                                             'Q.SENSOR.SENSOR_NORM' );
              U{end+1} = sprintf( '  IndexSet(sensor_norm,%d)', H.SENSOR_NORM );
            end
            U{end+1} = '  sensor_responseInit';

          case 'fill_fgrid'
            v = qarts_get( H.FILL_FGRID );
            if ~( isnumeric(v) & isvector(v) & length(v) == 2 )
              error( 'The sensor *FILL_FGRID* must be a vector of length 2.' );
            end
            U{end+1} = sprintf( ...
               '  sensor_responseFillFgrid(polyorder=%d,nfill=%d)', v(1), v(2) );

          case 'rotation'
            U = file_or_data( U, 'stokes_rotation', 'Vector', ...
                          H.STOKES_ROTATION, Q, wfolder, Q.INPUT_FILE_FORMAT );
            U{end+1} = '  sensor_responseStokesRotation';

           case 'polarisation'
            U = file_or_data( U, 'instrument_pol', 'ArrayOfIndex', ...
                               H.INSTRUMENT_POL, Q, wfolder, Q.INPUT_FILE_FORMAT );
            U{end+1} = '  sensor_responsePolarisation';

          case 'antenna'
            if qarts_isset( H.ANTENNA_DLOS )
              U = file_or_data( U, 'antenna_dlos', 'Matrix', ...
                             H.ANTENNA_DLOS, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.ANTENNA_RESPONSE )
              U = file_or_data( U, 'antenna_response', 'GriddedField4',...
                         H.ANTENNA_RESPONSE, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            U{end+1} = '  sensor_responseAntenna';

          case 'mixer'
            if qarts_isset( H.LO )
              U = file_or_data( U, 'lo', 'Numeric', H.LO, ...
                                             Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.SIDEBAND_RESPONSE )
              U = file_or_data( U, 'sideband_response', 'GriddedField1', ...
                        H.SIDEBAND_RESPONSE, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.SIDEBAND_MODE )
              U = file_or_data( U, 'sideband_mode', 'String', ...
                            H.SIDEBAND_MODE, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            U{end+1} = '  sensor_responseMixer';

          case 'if2rf'
            U{end+1} = '  sensor_responseIF2RF';

          case 'backend'
            if qarts_isset( H.F_BACKEND )
              U = file_or_data( U, 'f_backend', 'Vector', H.F_BACKEND, ...
                                             Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
              U = file_or_data( U, 'backend_channel_response', ...
                'ArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, ...
                                             Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if ~qarts_isset( H.F_SWITCHING )
              U{end+1} = '  sensor_responseBackend';
            else
              df = qarts_get( H.F_SWITCHING );
              if ~( isnumeric(df) & isvector(df) & length(df)==2 )
              error( 'The sensor *F_SWITCHING* must be a vector of length 2.' );
              end
              U{end+1} = '  sensor_responseBackendFrequencySwitching(';
              U{end+1} = sprintf( '   df1=%.6e, df2=%.6e)', df(1), df(2) );
            end

           case 'multimixer'
            if qarts_isset( H.F_SWITCHING )
              error( 'The sensor *F_SWITCHING* option can not be used together ',...
                                                             'with multiple LO.' );
            end
            if qarts_isset( H.LO )
              U = file_or_data( U, 'lo_multi', 'Vector', H.LO, Q, wfolder, ...
                                                         Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.SIDEBAND_RESPONSE )
              U = file_or_data( U, 'sideband_response_multi', ...
                         'ArrayOfGriddedField1', H.SIDEBAND_RESPONSE, ...
                                             Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.SIDEBAND_MODE )
              U = file_or_data( U, 'sideband_mode_multi', 'ArrayOfString', ...
                                H.SIDEBAND_MODE, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.F_BACKEND )
              U = file_or_data( U, 'f_backend_multi', 'ArrayOfVector', ...
                                H.F_BACKEND, Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
              U = file_or_data( U, 'backend_channel_response_multi', ....
                     'ArrayOfArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, ...
                                             Q, wfolder, Q.INPUT_FILE_FORMAT );
            end
            U{end+1} = '  sensor_responseMultiMixerBackend';

          case 'beamswitch'
            U{1} = '  sensor_responseBeamSwitching';

          case 'close'
            U{1} = '  sensor_checkedCalc';
            U{2} = '  # End of sensor part';

          otherwise
            error(sprintf('Unknown action (%s) was requested.',parts{it}));
          end
          %
          T = { T{:} U{:} };
          %
        end %for parts
      end %
    end
  end
  Q = ftick( Q, { 'SENSOR_DO', 'SENSOR' } );

  
  %--- Jacobian and OEM
  if qarts_isset( Q.J_DO )
    if ~Q.J_DO
      T{end+1} = '  jacobianOff';
    else
      error( 'Retrievals not yet handled' );
    end
  end
  Q = ftick( Q, { 'J_DO' } );

  
  %--- Scattering
  if qarts_isset( Q.SCATTERING_DO )
    if ~Q.SCATTERING_DO
      T{end+1} = '  cloudboxOff';
    else
      error( 'Scattering not yet handled' );
    end
  end
  Q = ftick( Q, { 'SCATTERING_DO' } );
return



%------------------------------------------------------------------------------
%--- Help functions
%------------------------------------------------------------------------------

function T = add_includes( T, name, field )
  %
  if qarts_isset( field )
    if ~iscellstr( field )
      error( sprintf( '%s must be given as a cell array of strings.', name ) );
    end
    %
    arts_includes = atmlab( 'ARTS_INCLUDES' );
    %
    for i = 1 : length( field )
      if strfind( field{i}, 'ARTS_INCLUDES' )
        if isnan( arts_includes )
          error( 'Atmlab setting ARTS_INCLUDES is requested, but is not set.' );
        end
        s = strrep( field{i}, 'ARTS_INCLUDES', arts_includes );
      else
        s = field{i};
      end
      T{end+1} = sprintf( '  INCLUDE "%s"', s );
    end
  end
return



function T = file_or_data(T,artsvar,datatype,qvalue,Q,wfolder,dformat,...
                                                                  nonDefFileId)
  % Check if string array with cfile code to include. If yes, fill T and return.
  if iscellstr(qvalue)  &  length(qvalue) > 1  &  ...
     strcmp( qvalue{1}, 'Arts2{' )  &  strcmp( qvalue{end}, '}' )

     T = add_wsms( T, artsvar, {qvalue{2:end-1}}, Q, false, wfolder );
    return  % --->
  end

  if strcmp( datatype, 'Index' )
    rqre_datatype( qvalue, {@ischar,@iswhole}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Numeric' )
    rqre_datatype( qvalue, {@ischar,@istensor0}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Vector' )
    rqre_datatype( qvalue, {@ischar,@istensor1}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Matrix' )
    rqre_datatype( qvalue, {@ischar,@istensor2}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Tensor3' )
    rqre_datatype( qvalue, {@ischar,@istensor3}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Tensor4' )
    rqre_datatype( qvalue, {@ischar,@istensor4}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'Sparse' )
    rqre_datatype( qvalue, {@ischar,@issparse}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'String' )
    rqre_datatype( qvalue, {@ischar,@isempty}, ...
                                    sprintf('The input for %s',artsvar) );
  elseif strcmp( datatype, 'ArrayOfString' )
    rqre_datatype( qvalue, {@ischar,@isempty,@iscellstr,}, ...
                                    sprintf('The input for %s',artsvar) );
  % A generic check for remaining array types
  elseif strncmp( datatype, 'ArrayOf', 7 )
    rqre_datatype( qvalue, {@ischar,@isempty,@iscell}, ...
                                    sprintf('The input for %s',artsvar) );
  end

  % Determine if input data are a file
  isfile = ischar( qvalue );
  if strcmp( datatype, 'String' )       % Special handling of String vars.
    [p,n,ext] = fileparts( qvalue );
    if ~strcmp( ext, {'xml','nc'} )
      isfile = false;
    end
  end

  if isfile
    T{end+1} = add_readfile( artsvar, qvalue );
  else
    if nargin > 7
      filename = fullfile( wfolder, [nonDefFileId,'.xml'] );
    else
      filename = fullfile( wfolder, [artsvar,'.xml'] );
    end
    xmlStore( filename, qvalue, datatype, dformat );
    T{end+1} = add_readfile( artsvar, filename );
  end
return



function s = add_readfile( artsvar, filename )
  [p,n,ext] = fileparts( filename );
  switch lower(ext)
   case '.xml'
     s = sprintf('  ReadXML(%s,"%s")', artsvar, filename );
   case '.nc'
     s = sprintf('  ReadNetCDF(%s,"%s")', artsvar, filename );
   otherwise
    error( sprintf( ...
    'Unknown file extension (%s), Allowed options are ''xml'' and ''nc''', ...
        ext ) );
  end
return



function s = add_savefile( artsvar, wfolder )
  filename = fullfile( wfolder, [ artsvar, '.xml' ] );
  s = sprintf('WriteXML(output_file_format,%s,"%s")', artsvar, filename );
return



function T = add_wsms( T, field, strarray, Q, add_indent, wfolder )
  if ~iscellstr( strarray )
    error( sprintf( ...
           'The field %s must be specified as cell array of strings.', ...
                                                                field ) );
  end
  inif   = false;
  insert = true;
  for j = 1 : length(strarray)
    thisline = strarray{j};
    skipline = false;
    % Check keywords
    if length(thisline) > 0  &  thisline(1) == '<'
      if strncmp( thisline, '<IF>', 4 )
        if length(thisline) < 5
          error( 'Empty <IF> found in %s.', field );
        end
        qfield = strtrim( thisline(5:end) );
        if ~qarts_isset( Q.(qfield) ) | ~isboolean(Q.(qfield))
          error( ['Incorrect usage of if-statement in %s. The argument (in ',...
                  'this case %s) must be a field of Q that is set and is ',  ...
                  'a boolean.'], field, qfield );
        end
        if Q.(qfield)
          insert = true;
        else
          insert = false;
        end
        inif = true;
        skipline = true;
      elseif strncmp( thisline, '<ELSE>', 6 )
        if ~inif | length( deblank( thisline ) ) ~= 6
          error( 'Incorrect line including <ELSE> found in %s.', field );
        end
        insert = ~insert;
        skipline = true;
      elseif strncmp( thisline, '<END>', 5 )
        if ~inif | length( deblank( thisline ) ) ~= 5
          error( 'Incorrect line including <END> found in %s.', field );
        end
        inif   = false;
        insert = true;
        skipline = true;
      elseif strncmp( thisline, '<OUTPUT>', 8 )
        artsvar = strtrim( thisline(9:end) );
        thisline = add_savefile( artsvar, wfolder );
      else
        error( 'Could not decode this line: %s', thisline );
      end
    end % Keyword part
    if insert & ~skipline
      if add_indent
        T{end+1} = sprintf( '    %s', thisline );
      else
        T{end+1} = sprintf( '  %s', thisline );
      end
    end
  end
return


function T = add_agenda( T, agenda, strarray, Q, wfolder )
  if ~iscellstr( strarray )
    error( sprintf( ...
          'The agenda %s must be specified as cell array of strings.', ...
                                                        upper(agenda) ) );
  end
  if length(strarray) == 1  &  ~isempty(strfind( strarray{1}, [agenda,'__'] ) )
    T{end+1} = sprintf( '  Copy(%s,%s)', agenda, strarray{1} );
  else
    T{end+1} = sprintf( '  AgendaSet(%s){', agenda );
    T = add_wsms( T, agenda, strarray, Q, true, wfolder );
    T{end+1} = '  }';
  end
return


function Q = ftick( Q, fields )
  for i = 1 : length(fields)
    Q.(sprintf('USED_%s',fields{i})) = true;
  end
return