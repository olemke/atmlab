% QARTS12CFILE   Builds a control file for ARTS1
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
%       calc_abs
%       save_abs
%       save_abs_per_tg
%       init_rte
%       calc_rte
%       save_y
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
% FORMAT   S = arts12cfile( Q, parts, tmpdir [, do_save] )
%        
% OUT   S       String cell array that can be passed to qtool.
% IN    Q       Qarts1 structure.
%       parts   Control file parts to include. See further above.
%       tmpdir  Temporary folder where calculations will be performed.
% OPT   do_save If 0 no data is stored to files and only a control
%               file is created. Default is 1.

% 2004-09-07   Created by Patrick Eriksson.


function S = qarts12cfile( Q, parts, tmpdir, do_save )

if nargin < 4
  do_save = 1;
end


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
  T{1} = file_or_data( 'f_mono', 'Vector', Q.F_MONO, tmpdir, use_binary, ...
                                                                     do_save );
  T{2} = file_or_data( 'p_abs', 'Vector', Q.P_ABS, tmpdir, use_binary, ...
                                                                     do_save );

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
    T{1} = file_or_data( 't_abs', 'Vector', Q.T_ABS, tmpdir, use_binary, ...
                                                                     do_save );
    T{2} = file_or_data( 'z_abs', 'Vector', Q.Z_ABS, tmpdir, use_binary, ...
                                                                     do_save );
    T{3} = file_or_data( 'vmrs', 'Matrix', Q.VMRS, tmpdir, use_binary, ...
                                                                     do_save );
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

case 'calc_abs'
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

case 'init_rte'
  %
  rqre_bool( 'Qarts1 setting EMISSION_ON', Q.EMISSION_ON );
  if Q.EMISSION_ON
    T{1} = 'emissionOn{}';
  else
    T{1} = 'emissionOff{}';
  end
  rqre_scalar( 'Qarts1 setting Z_PLAT', Q.Z_PLAT, 0 );
  T{2} = sprintf( 'NumericSet(z_plat){%e}', Q.Z_PLAT );  
  T{3} = file_or_data( 'za_pencil', 'Vector', Q.ZA_PENCIL, tmpdir, ...
                                                          use_binary, do_save);
  rqre_scalar( 'Qarts1 setting L_STEP', Q.L_STEP, 0 );
  T{4} = sprintf( 'NumericSet(l_step){%e}', Q.L_STEP );  
  T{5} = sprintf( 'VectorPlanck(y_space,f_mono){%.3f}', Q.T_SPACE );
  rqre_bool( 'Qarts1 setting HSE_ON', Q.HSE_ON );
  if Q.HSE_ON
    T{6} = 'hseSet{';
    T{7} = sprintf('      pref  = %e', Q.HSE(1) );
    T{8} = sprintf('      zref  = %.3f', Q.HSE(2) );
    T{9} = sprintf('      g0    = %.3f', Q.HSE(3) );
    T{10} = sprintf('     niter = %d', Q.HSE(4) );
    T{11} = '}';
    T{12} = 'hseCalc{}';
  else
    T{6} = 'hseOff{}';
    T{7} = ' '; T{8} = ' '; T{9} = ' '; T{10} = ' '; T{11} = ' '; T{12} = ' '; 
  end
  rqre_scalar( 'Qarts1 setting R_GEOID', Q.R_GEOID, 0 );
  T{13} = sprintf( 'NumericSet(r_geoid){%e}', Q.R_GEOID );  
  rqre_scalar( 'Qarts1 setting Z_GROUND', Q.Z_GROUND, 0 );
  T{14} = sprintf( 'NumericSet(z_ground){%e}', Q.Z_GROUND );  
  rqre_scalar( 'Qarts1 setting T_GROUND', Q.T_GROUND, 0 );
  T{15} = sprintf( 'NumericSet(t_ground){%e}', Q.T_GROUND );  
  T{16} = file_or_data( 'e_ground', 'Vector', Q.E_GROUND, tmpdir, ...
                                                         use_binary, do_save );
  rqre_bool( 'Qarts1 setting REFR_ON', Q.REFR_ON );
  if Q.REFR_ON
    T{17} = 'refrSet{';
    T{18} = '   on    = 1';
    T{19} = '   model = "Boudouris"';
    T{20} = sprintf('   lfac    = %.3f', Q.REFR_LFAC );
  else
    T{17} = 'refrOff{}'; T{18} = ' '; T{19} = ' '; T{20} = ' ';
  end
  T{21} = 'refrCalc{}';

case 'calc_rte'
  %
  T{1} = 'losCalc{}';
  T{2} = 'sourceCalc{}';
  T{3} = 'transCalc{}';
  T{4} = 'yCalc{}';

case 'save_y'
  %
  switch upper( Q.Y_UNIT )
    case '1'
      T{1} = '# No conversion to K';
    case 'RJ'
      T{1} = 'yTRJ{}';
    case 'PLANCK'
      T{1} = 'yTB{}';
    otherwise
      error( sprintf( 'Unrecognised choice for Q.Y_UNIT (%s).', Q.Y_UNIT ) );
  end
  T{2} = add_savefile( 'y', 'Vector', tmpdir, use_binary );

otherwise
  error(sprintf('Unknown action (%s) was requested.',parts{i}));
end

S = [ S T ];

end


%------------------------------------------------------------------------------

function s = file_or_data( artsvar, datatype, qvalue, tmpfolder, ...
                                                         use_binary, do_save )
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
    if do_save
      write_datafile( filename, qvalue, datatype );
    end
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
