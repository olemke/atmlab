% Include files
% WSMS_AT_START
% WSVs
% Z, T, ABS_SPECIES, WIND_U/V/W, MAG_U/V/W
% WSMS_AT_HALFWAY
% SENSOR
% WSMS_ACTION
% WSMS_AT_END

function S = qarts3cfile( Q, parts, wfolder )

%- Run and append cfile parts
%
S    = {};
%
for ip = 1 : length(parts)

  switch parts{ip}

   case 'All'
    %
    T = qarts3cfile( Q, ...
                     { 'Start', 'WSVs', 'End' }, ... 
                     wfolder );
    
  case 'Start'
    %
    T = do_Start( Q, wfolder );

   case 'WSVs'
    %
    T = do_WSVs( Q, wfolder );

   case 'End'
    %
    T = do_End( Q, wfolder );

   otherwise
    error( sprintf( 'Unknown cfile part (%s) was requested.', parts{ip} ) );
  end

  if ~isempty(T)
   S = { S{:} T{:} };
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
%
function T = do_Start( Q, wfolder )
  %
  T{1} = [ '# Control file created by Atmlab function *qarts3cfile*' ];
  T{2} = 'Arts2{';
  %
  T = add_includes( T, 'Q.INCLUDES', Q.INCLUDES );
  %
  if qarts_isset( Q.WSMS_AT_START )
    T = add_wsms( T, ' WSMS_AT_START', Q.WSMS_AT_START, Q, false );
  end
return


%------------------------------------------------------------------------------
% Adds (in given order):
%    WSMS_AT_END
%    Closing of cfile
%
function T = do_End( Q, wfolder )
  %
  T = [];
  %
  if qarts_isset( Q.WSMS_AT_END )
    T = add_wsms( T, ' WSMS_AT_END', Q.WSMS_AT_END, Q, false );
  end
  %
  T{end+1} = '}';
return


%------------------------------------------------------------------------------
% Adds (in given order):
%    All WSVs
%
function T = do_WSVs( Q, wfolder )
  %
  T = [];
  format = Q.INPUT_FILE_FORMAT;
  %
  fnames = fieldnames( Q );
  %
  for i = 1 : length( fnames )
    fname = fnames{i};
    if fname(1) >= 'a' & fname(1) <= 'z'
      group = wsv2group( fname ); 
      if strcmp( group, 'Agenda' )
        T = add_agenda( T, fname, Q.(fname), Q );
      else
        T = file_or_data( T, fname, group, Q.(fname), Q, wfolder, format ); 
      end
    elseif length(fname) > 4 & strcmp( fname(end+[-3:0]), '_WSV' )
      ius = strfind( fname, '_' );
      if length(ius) < 2
        error(sprintf('*%s* is not a valid definition of a non-std WSV.',fname));
      end
      group = fname( ius(end-1)+1 : ius(end)-1 );
      wsv = fname( 1 : ius(end-1)-1 );
      T{end+1} = sprintf( '  %sCreate(%s)', group, wsv );
      if strcmp( group, 'Agenda' )
        T = add_agenda( T, wsv, Q.(fname), Q );
      else
        T = file_or_data( T, wsv, group, Q.(fname), Q, wfolder, format ); 
      end
    end
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



function T = file_or_data(T,artsvar,datatype,qvalue,Q,workfolder,dformat,...
                                                                  nonDefFileId)
  % Check if string array with cfile code to include. If yes, fill T and return.
  if iscellstr(qvalue)  &  length(qvalue) > 1  &  ...
     strcmp( qvalue{1}, 'Arts2{' )  &  strcmp( qvalue{end}, '}' )

     T = add_wsms( T, artsvar, {qvalue{2:end-1}}, Q, false );
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
      filename = fullfile( workfolder, [nonDefFileId,'.xml'] );
    else
      filename = fullfile( workfolder, [artsvar,'.xml'] );
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



function s = add_savefile( artsvar, workfolder )
  filename = fullfile( workfolder, [ artsvar, '.xml' ] );
  s = sprintf('  WriteXML(output_file_format,%s,"%s")', artsvar, filename );
return



function T = add_wsms( T, field, strarray, Q, add_indent )
  if ~iscellstr( strarray )
    error( sprintf( ...
           'The field %s must be specified as cell array of strings.', ...
                                                                field ) );
  end
  inif   = false;
  insert = true;
  for j = 1 : length(strarray)
    thisline = strarray{j};
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
      elseif strncmp( thisline, '<ELSE>', 6 )
        if length( deblank( thisline ) ) ~= 6
          error( 'Incorrect line including <ELSE> found in %s.', field );
        end
        insert = ~insert;
      elseif strncmp( thisline, '<END>', 5 )
        if length( deblank( thisline ) ) ~= 5
          error( 'Incorrect line including <END> found in %s.', field );
        end
        inif   = false;
        insert = true;
      else
      end
    else
      if insert
        if add_indent
          T{end+1} = sprintf( '    %s', strarray{j} );
        else
          T{end+1} = sprintf( '  %s', strarray{j} );
        end
      end
    end
  end
return


function T = add_agenda( T, agenda, strarray, Q )
  if ~iscellstr( strarray )
    error( sprintf( ...
          'The agenda %s must be specified as cell array of strings.', ...
                                                        upper(agenda) ) );
  end
  if length(strarray) == 1  &  ~isempty(strfind( strarray{1}, [agenda,'__'] ) )
    T{end+1} = sprintf( '  Copy(%s,%s)', agenda, strarray{1} );
  else
    T{end+1} = sprintf( '  AgendaSet(%s){', agenda );
    T = add_wsms( T, agenda, strarray, Q, true );
    T{end+1} = '  }';
  end
return
