% ARTS_BATCH   Performs ARTS batch calculations
%
%    The general calculations are described by the Qarts structure where
%    fields for atmosphere, absorption, sensor and RT must be specified.
%
%    The actual batch calculations are controled by a separate structure,
%    denoted as B. This structure has fields named after ARTS workspace
%    variables (but all uppercase letters). If such field is set to NaN
%    this is interpreted as that the corresponding value(s) in Q shall be
%    used throughout. Otherwise, the field shall hold a set of realisations
%    of the variables. The realisations are stored in a tensor with a 
%    dimension one higher than the WSV of concern, where the realisations
%    are stored along the highest dimension. For example 50 realisations
%    of *t_field* would be a Tensor4 of size (50,x,y,z).
%
%    All existing fields of B must be set. The B structure can be initiated
%    as: B = arts_batch('init');
%    which also then gives a list of existing fields.
%
% FORMAT   Y = arts_batch( Q, B, n )
%        
% OUT   Y   Matrix with batch spectra. Each spectrum vector is a column.
% IN    Q   Qarts structure.
%       B   Structure with batch variables.
%       n   Number of batch cases to consider.
%
%   or
%
% FORMAT   B = arts_batch( 'init' )
%        
% OUT   B   Structure with all existing batch fields set to NaN.
% IN        Can only be the string 'init'.


% 2004-09-17   Created by Patrick Eriksson.


function Y = arts_batch( Q, B, n )


if nargin == 1

  if ~strcmp( Q, 'init' )
    error( ...
      'There must either be 3 input arguments, or first argument = ''init''' );
  end

  B.T_FIELD    = NaN;
  B.Z_FIELD    = NaN;
  B.VMR_FIELD  = NaN;
  B.SENSOR_LOS = NaN;
  B.SENSOR_POS = NaN;

  Y = B;
  return
end



%=== Create temporary working folder
%
tmpfolder   = create_tmpfolder;



%=== Build first part of control file
%
parts = {'start','stokes','load_atm','load_abs','calc_abs','init_rte'};
S1 = qarts2cfile( Q, parts, tmpfolder );


%=== Create batch part of control file
%
t3_used = 0;
t4_used = 0;
t5_used = 0;
%
T1{1} = sprintf( 'IndexSet(ybatch_n){%d}', n );
T2{1} = 'AgendaSet(batch_update_agenda){';
%
if ~isnan( B.T_FIELD )
  t4_used = t4_used + 1;
  [T1,T2] = add_std_case( T1, T2, 't_field', 'Tensor3', t4_used, ...
                                                        B.T_FIELD, tmpfolder );
end
%
if ~isnan( B.Z_FIELD )
  t4_used = t4_used + 1;
  [T1,T2] = add_std_case( T1, T2, 'z_field', 'Tensor3', t4_used, ...
                                                        B.Z_FIELD, tmpfolder );
end
%
if ~isnan( B.VMR_FIELD )
  t5_used = t5_used + 1;
  [T1,T2] = add_std_case( T1, T2, 'vmr_field', 'Tensor4', t5_used, ...
                                                      B.VMR_FIELD, tmpfolder );
end
%
if ~isnan( B.SENSOR_POS )
  t3_used = t3_used + 1;
  [T1,T2] = add_std_case( T1, T2, 'sensor_pos', 'Matrix', t3_used, ...
                                                     B.SENSOR_POS, tmpfolder );
end
%
if ~isnan( B.SENSOR_LOS )
  t3_used = t3_used + 1;
  [T1,T2] = add_std_case( T1, T2, 'sensor_los', 'Matrix', t3_used, ...
                                                     B.SENSOR_LOS, tmpfolder );
end
%
T2{length(T2)+1} = '}';
T2{length(T2)+1} = 'AgendaSet(batch_calc_agenda){RteCalc{}}';
T2{length(T2)+1} = 'AgendaSet(batch_post_agenda){';
  switch upper( Q.Y_UNIT )
    case '1'
      ;
    case 'RJ'
      T2{length(T2)+1} = 'MatrixToTbByRJ(ybatch,ybatch){}';
    case 'PLANCK'
      T2{length(T2)+1} = 'MatrixToTbByPlanck(ybatch,ybatch){}';
    otherwise
      error( sprintf( 'Unrecognised choice for Q.Y_UNIT (%s).', Q.Y_UNIT ) );
  end
T2{length(T2)+1} =  'WriteXML(ybatch){""}';
T2{length(T2)+1} = '}';
T2{length(T2)+1} = 'ybatchCalc{}';



%=== Create control file control file and run calculations
%
parts = {'stop'};
S2 = qarts2cfile( Q, parts, tmpfolder );
cfile = fullfile( tmpfolder, 'cfile.arts' );
qtool( {S1{:} T1{:} T2{:} S2{:} }, cfile, [] );
arts( cfile );


%=== Load data
%
Y = xmlLoad( fullfile( tmpfolder, 'cfile.ybatch.xml' ) );


%=== Delete working folder
%
delete_tmpfolder( tmpfolder );



%------------------------------------------------------------------------------

function   [T1,T2] = ...
             add_std_case( T1, T2, mainvar, maintype, tmpn, vfield, tmpfolder )

  switch maintype
    case 'Numeric'
      batchtype = 'Vector';
    case 'Vector'
      batchtype = 'Matrix';
    case 'Matrix'
      batchtype = 'Tensor3';
    case 'Tensor3'
      batchtype = 'Tensor4';
    case 'Tensor4'
      batchtype = 'Tensor5';
    otherwise
      error( 'Unknown type of main variable.' );
  end

  batchvar = sprintf('%s_%d', lower(batchtype), tmpn );

  if ischar( vfield )
    filename = vfield;
  else
    filename = fullfile( tmpfolder, sprintf( 'batch_%s.xml', mainvar ) );
    xmlStore( filename, vfield, batchtype );
  end

  T1{length(T1)+1} = sprintf('ReadXML(%s){"%s"}', batchvar, filename );
  T2{length(T2)+1} = sprintf('BatchUpdate%s(%s,%s){}', maintype, ...
                                                           mainvar, batchvar );
return