function S = arts1_cfile( S, Q, parts, tmpdir )


qcheck( @qarts1, Q );


for i = 1 : length(parts)

T = [];

switch parts{i}

case 'tgs'
  %
  T{1} = sprintf( 'tgsDefine{[%s]}', arts_tgs_cnvrt(Q.TGS) );

case 'load_atm'
  %
  T = file_or_data( 'p_abs', 'Vector', Q.P_ABS, tmpdir );
  %
  rqre_bool( 'ARTS1 field USE_RAW_ATMOSPHERE', Q.USE_RAW_ATMOSPHERE );
  if Q.USE_RAW_ATMOSPHERE
    rqre_char( 'ARTS1 field APRIORI_PTZ', Q.APRIORI_PTZ );
    rqre_char( 'ARTS1 field APRIORI_VMR', Q.APRIORI_VMR );
    T{2} = add_readfile( 'raw_ptz', 'Matrix', Q.APRIORI_PTZ );
    T{3} = sprintf('raw_vmrsReadFromScenario{"%s"}',Q.APRIORI_VMR);
    T{4} = sprintf('AtmFromRaw{}');
  end

case 'save_atm'
  %
  T{1} = add_savefile( 't_abs', 'Vector', tmpdir );
  T{2} = add_savefile( 'z_abs', 'Vector', tmpdir );
  T{3} = add_savefile( 'vmrs', 'Matrix', tmpdir );

case 'f_mono'
  %
  T = file_or_data( 'f_mono', 'Vector', Q.F_MONO, tmpdir );

case 'spectroscopy'
  %
  T{1} = 'lineshapeDefine{';
  T{2} = sprintf('   shape               = "%s"', Q.LINESHAPE );
  T{3} = sprintf('   normalizationfactor = "%s"', Q.LINESHAPE_FACTOR );
  T{4} = sprintf('   cutoff              = %e', Q.LINESHAPE_CUTOFF );
  T{5} = '}';


case 'abscalc'
  %
  T{1} = 'h2o_absSet{}';
  T{2} = 'n2_absSet{}';
  T{3} = 'absCalc{}';

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end


S = [ S T ];

end


%------------------------------------------------------------------------------

function T = file_or_data( artsvar, datatype, qvalue, tmpfolder )
  if ischar( qvalue )
    T{1} = add_readfile( artsvar, datatype, qvalue );
  else
    filename = fullfile( tmpfolder, [artsvar,'.ab'] );
    write_datafile( filename, qvalue, datatype );
    T{1} = add_readfile( artsvar, datatype, filename );
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
