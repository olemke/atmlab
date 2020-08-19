% QARTS3CFILE  Builds a control file for ARTS
%
%    The function converts the settings and defintions in Q to control file
%    text. For a default call of the method, the settings in Q are included
%    in the following order:
%       Include files
%       WSMS_AT_START
%       ATMOSPHERE_DIM, 
%       Workspace variables (WSVs)
%       Atmospheric fields: Z, T, ABS_SPECIES, WIND_U/V/W, MAG_U/V/W
%       WSMS_AT_HALFWAY
%       SENSOR
%       Retrieval (Jacobian + OEM)
%       SCATTERING
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
      parts = { 'Start', 'WSVs', 'AtmFields', 'Halfway', 'Sensor', ...
              'Retrieval', 'Scattering', 'End' };
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

    case 'AtmFields'
      %
      [T,Q] = do_atmfields( Q, wfolder );

    case 'Halfway'
      %
      [T,Q] = do_halfway( Q, wfolder );

    case 'Sensor'
      %
      [T,Q] = do_sensor( Q, wfolder );

    case 'Scattering'
      %
      [T,Q] = do_scattering( Q, wfolder );

    case 'Retrieval'
      %
      [T,Q] = do_retrieval( Q, wfolder );
    
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
    T = add_wsms( T, ' WSMS_AT_START', Q.WSMS_AT_START, Q, false, wfolder );
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
    T = add_wsms( T, ' WSMS_AT_HALFWAY', Q.WSMS_AT_HALFWAY, Q, false, wfolder );
  end
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
  if qarts_isset( Q.WSMS_AT_END )
    T = add_wsms( T, ' WSMS_AT_END', Q.WSMS_AT_END, Q, false, wfolder );
  end
  %
  T{end+1} = '}';
  Q = ftick( Q, { 'WSMS_AT_END' } );
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
%
function [T,Q] = do_atmfields( Q, wfolder )
  %
  T = [];
  %
return



%------------------------------------------------------------------------------
% Adds (in given order):
%
function [T,Q] = do_sensor( Q, wfolder )
  %
  Q = ftick( Q, { 'SENSOR_DO' } );
  T = [];
  %
  if ~qarts_isset( Q.SENSOR_DO )
    T = {};
  elseif ~Q.SENSOR_DO
    T{1} = '  sensorOff';
  else
    error( 'Sensor not yet handled' );
  end
return



%------------------------------------------------------------------------------
% Adds (in given order):
%
function [T,Q] = do_scattering( Q, wfolder )
  %
  Q = ftick( Q, { 'SCATTERING_DO' } );
  T = [];
  %
  if ~qarts_isset( Q.SCATTERING_DO )
    T = {};
  elseif ~Q.SCATTERING_DO
    T{1} = '  cloudboxOff';
  else
    error( 'Scattering not yet handled' );
  end
return



%------------------------------------------------------------------------------
% Adds (in given order):
%
function [T,Q] = do_retrieval( Q, wfolder )
  %
  Q = ftick( Q, { 'J_DO' } );
  T = [];
  %
  if ~qarts_isset( Q.J_DO )
    T = {};
  elseif ~Q.J_DO
    T{1} = '  jacobianOff';
  else
    error( 'Scattering not yet handled' );
  end
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