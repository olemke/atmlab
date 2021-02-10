% QARTS3CFILE  Builds a control file for ARTS
%
%    The function converts the settings and defintions in Q to control file
%    text. For a default call of the method, the settings in Q are included
%    in the following order:
%       Include files
%       WSMS_AT_START
%       ATMOSPHERE_DIM
%       Workspace variables (WSVs)
%       GAS_SPECIES
%       RAW_ATMOSPHERE,
%       Z_SURFACE
%       HSE
%       ABSORPTION
%       WSMS_AT_HALFWAY
%       SENSOR
%       J
%       PARTICLES
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
%    GAS_SPECIES
%    RAW_ATMOSPHERE
%    Z_SURFACE
%    HSE
%
function [T,Q] = do_atmsurffields( Q, wfolder )
  %
  T = [];
  %
  %
  if qarts_isset( Q.GAS_SPECIES )
    rqre_datatype( Q.GAS_SPECIES, @isstruct, 'Q.GAS_SPECIES' );
    rqre_field( Q.GAS_SPECIES, 'TAG', 'Q.GAS_SPECIES' );
    T{end+1} = sprintf( '  abs_speciesSet(species=[%s])', ...
                                           arts_tgs_cnvrt(Q.GAS_SPECIES) );
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
  if qarts_isset( Q.HSE ) & Q.HSE.ON
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
  Q = ftick( Q, { 'GAS_SPECIES', 'RAW_ATMOSPHERE', 'RAW_ATM_EXPAND_1D' } );
  Q = ftick( Q, { 'Z_SURFACE', 'HSE' } );
return



%------------------------------------------------------------------------------
% Adds (in given order):
%     ABSORPTION
%
function [T,Q] = do_absorption( Q, wfolder )
  %
  T = [];
  if qarts_isset( Q.ABSORPTION ) & ~isempty(Q.ABSORPTION)
    T = add_wsms( T, 'ABSORPTION', Q.ABSORPTION, Q, false, wfolder );
  end %  
  %
  Q = ftick( Q, { 'ABSORPTION' } );
  %
return


%------------------------------------------------------------------------------
% Adds (in given order):
%     SENSOR
%     J
%     PARTICLES
%
function [T,Q] = do_modules( Q, wfolder )
  %
  T = [];
  
  %--- Sensor
  if qarts_isset( Q.SENSOR )
    if isempty( Q.SENSOR )
      T{end+1} = '  sensorOff';
      T{end+1} = '  AntennaOff';
      T{end+1} = '  FlagOn(sensor_checked)';    
    else
      T = add_wsms( T, 'SENSOR', Q.SENSOR, Q, false, wfolder );
    end
  end

  %--- Jacobian
  if qarts_isset( Q.J )
    if isempty( Q.J )
      T{end+1} = '  jacobianOff';
    else
      T = add_wsms( T, 'J', Q.J, Q, false, wfolder );
    end
  end
  
  %--- Particles
  if qarts_isset( Q.PARTICLES )
    if isempty( Q.PARTICLES )
      T{end+1} = '  cloudboxOff';
    else
      T = add_wsms( T, 'PARTICLES', Q.PARTICLES, Q, false, wfolder );
    end
  end
  
  Q = ftick( Q, { 'PARTICLES', 'SENSOR', 'J' } );
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