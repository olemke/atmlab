% ARTS1_CFILE   Builds a control file for ARTS1
%
%    Creates a control file matching the settings in a Qarts1 structure.
%    The control file is provided as cell array of strings. This means
%    that the output can be combined with other control file pieces
%    by combining their string arrays. The final control file is
%    created by *qtool*.
%    
%    The control file structure is determined by putting different 'parts'
%    together, following the format: parts = {'tgs','load_atm','save_atm'}
%
%    Defined parts are:
%       tgs
%       pf_grids
%       load_atm
%       save_atm
%       spectroscopy
%       abscalc
%       save_abs
%       save_abs_per_tg
%
%    Sorry, the Q fields needed for each part is not listed here.
%    See the code.
%
%    Output is directed to files with name [tmpfolder,varname,fileext]
%    where varname is the ARTS1 variable name and fileext is either
%    '.aa' or '.ab' depending on if HDF is available or not. 
%    File format is selected following Atmlab setting ARTS1_HDF, where 
%    binary format is used if possible (ARTS1_HDF=1).
%
% FORMAT   S = arts1_cfile( Q, parts, tmpdir )
%        
% OUT   S       String cell array that can be passed to qtool.
% IN    parts   Control file parts to include. See further above.
%       tmpdir  Temporary folder where calculations will be performed.

% 2004-09-07   Created by Patrick Eriksson.


function S = arts1_cfile( Q, parts, tmpdir )


qcheck( @qarts1, Q );


use_binary = atmlab( 'ARTS1_HDF' );
rqre_bool( 'Atmlab setting ARTS1_HDF', use_binary );


S = {};

for i = 1 : length(parts)

T = [];

switch parts{i}

case 'tgs'
  %
  T{1} = sprintf( 'tgsDefine{[%s]}', arts_tgs_cnvrt(Q.TGS) );

case 'pf_grids'
  %
  T{1} = file_or_data( 'f_mono', 'Vector', Q.F_MONO, tmpdir, use_binary );
  T{2} = file_or_data( 'p_abs', 'Vector', Q.P_ABS, tmpdir, use_binary );

case 'load_atm'
  %
  rqre_bool( 'ARTS1 field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'ARTS1 field APRIORI_PTZ', Q.APRIORI_PTZ );
    rqre_char( 'ARTS1 field APRIORI_VMR', Q.APRIORI_VMR );
    T{1} = add_readfile( 'raw_ptz', 'Matrix', Q.APRIORI_PTZ );
    T{2} = sprintf('raw_vmrsReadFromScenario{"%s"}',Q.APRIORI_VMR);
    T{3} = sprintf('AtmFromRaw{}');
  else
    T{1} = file_or_data( 't_abs', 'Vector', Q.T_ABS, tmpdir, use_binary );
    T{2} = file_or_data( 'z_abs', 'Vector', Q.Z_ABS, tmpdir, use_binary );
    T{3} = file_or_data( 'vmrs', 'Matrix', Q.VMRS, tmpdir, use_binary );
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_abs', 'Vector', tmpdir, use_binary );
  T{2} = add_savefile( 'z_abs', 'Vector', tmpdir, use_binary );
  T{3} = add_savefile( 'vmrs', 'Matrix', tmpdir, use_binary );

case 'spectroscopy'
  %
  T{1} = 'lineshapeDefine{';
  T{2} = sprintf('   shape               = "%s"', Q.LINESHAPE );
  T{3} = sprintf('   normalizationfactor = "%s"', Q.LINESHAPE_FACTOR );
  T{4} = sprintf('   cutoff              = %e', Q.LINESHAPE_CUTOFF );
  T{5} = '}';
  %
  if ischar( Q.LINEDATA )
    filename = Q.LINEDATA;
    format   = Q.LINEFORMAT;
  else
    filename = fullfile( tmpfolder, 'linefile.al' );
    format   = 'Arts';
    arts_write_linefile( filename, Q.LINEDATA );
  end
  T{6} = sprintf( 'linesReadFrom%s{', format ); 
  T{7} = sprintf( '   filename = "%s"', filename );
  T{8} =  '   fmin     = 0';
  T{9} =  '   fmax     = 10e25';
  T{10} = '}';
  T{11} = 'lines_per_tgCreateFromLines{}'; 
  %
  rqre_char( 'ARTS1 field ABS_MODELS', Q.ABSMODELS );
  Tfile = file2strs( Q.ABSMODELS );
  T{12} = 'cont_descriptionInit{}';
  T = [ T Tfile ];

case 'abscalc'
  %
  T{1} = 'h2o_absSet{}';
  T{2} = 'n2_absSet{}';
  T{3} = 'absCalc{}';

case 'save_abs'
  %
  T{1} = add_savefile( 'abs', 'Matrix', tmpdir, use_binary );

case 'save_abs_per_tg'
  %
  T{1} = add_savefile( 'abs_per_tg', 'ArrayOfMatrix', tmpdir, use_binary );

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = [ S T ];

end


%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpfolder, use_binary )
  if ischar( qvalue )
    s = add_readfile( artsvar, datatype, qvalue );
  else
    if isnan( qvalue )
       error( sprintf('NaN found for %s.',artsvar) );
    end
    if use_binary
      filename = fullfile( tmpfolder, [artsvar,'.ab'] );
    else
      filename = fullfile( tmpfolder, [artsvar,'.aa'] );
    end
    write_datafile( filename, qvalue, datatype );
    s = add_readfile( artsvar, datatype, filename );
  end
return


function s = add_readfile( artsvar, datatype, filename )
  if strcmp( tail(filename,3), '.aa' )
    s = sprintf('%sReadAscii(%s){"%s"}', datatype, artsvar, filename ); 
  elseif strcmp( tail(filename,3), '.ab' )
    s = sprintf('%sReadBinary(%s){"%s"}', datatype, artsvar, filename ); 
  else
    error( sprintf('Not allowed file name (must end with .aa or .ab): %s',...
                                                                  filename') );
  end
return


function s = add_savefile( artsvar, datatype, tmpfolder, use_binary )
  if use_binary
    filename = fullfile( tmpfolder, [ artsvar, '.ab' ] ); 
    s = sprintf('%sWriteBinary(%s){"%s"}', datatype, artsvar, filename ); 
  else
    filename = fullfile( tmpfolder, [ artsvar, '.aa' ] ); 
    s = sprintf('%sWriteAscii(%s){"%s"}', datatype, artsvar, filename ); 
  end
return
