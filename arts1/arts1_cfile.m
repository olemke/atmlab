function S = arts1_cfile( S, Q, parts, tmpdir )


qcheck( @qarts1, Q );


S = {};

for i = 1 : length(parts)

T = [];

switch parts{i}

case 'tgs'
  %
  T{1} = sprintf( 'tgsDefine{[%s]}', arts_tgs_cnvrt(Q.TGS) );

case 'load_atm'
  %
  T{1} = file_or_data( 'p_abs', 'Vector', Q.P_ABS, tmpdir );
  %
  rqre_bool( 'ARTS1 field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'ARTS1 field APRIORI_PTZ', Q.APRIORI_PTZ );
    rqre_char( 'ARTS1 field APRIORI_VMR', Q.APRIORI_VMR );
    T{2} = add_readfile( 'raw_ptz', 'Matrix', Q.APRIORI_PTZ );
    T{3} = sprintf('raw_vmrsReadFromScenario{"%s"}',Q.APRIORI_VMR);
    T{4} = sprintf('AtmFromRaw{}');
  else
    T{2} = file_or_data( 't_abs', 'Vector', Q.T_ABS, tmpdir );
    T{3} = file_or_data( 'z_abs', 'Vector', Q.Z_ABS, tmpdir );
    T{4} = file_or_data( 'vmrs', 'Matrix', Q.VMRS, tmpdir );
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_abs', 'Vector', tmpdir );
  T{2} = add_savefile( 'z_abs', 'Vector', tmpdir );
  T{3} = add_savefile( 'vmrs', 'Matrix', tmpdir );

case 'f_mono'
  %
  T{1} = file_or_data( 'f_mono', 'Vector', Q.F_MONO, tmpdir );

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
  if isempty( Q.ABSMODELS )
    Q.ABSMODELS = which('arts1_absmodels.cfile');
  end
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
  T{1} = add_savefile( 'abs', 'Matrix', tmpdir );

case 'save_abs_per_tg'
  %
  T{1} = add_savefile( 'abs_per_tg', 'ArrayOfMatrix', tmpdir );

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = [ S T ];

end


%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpfolder )
  if ischar( qvalue )
    s = add_readfile( artsvar, datatype, qvalue );
  else
    filename = fullfile( tmpfolder, [artsvar,'.ab'] );
    write_datafile( filename, qvalue, datatype );
    s = add_readfile( artsvar, datatype, filename );
  end


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


function s = add_savefile( artsvar, datatype, tmpfolder )
  filename = fullfile( tmpfolder, [ artsvar, '.ab' ] ); 
  s = sprintf('%sWriteBinary(%s){"%s"}', datatype, artsvar, filename ); 
return
