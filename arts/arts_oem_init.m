% ARTS_OEM_INIT   Initialization of OEM inversions by ARTS
%
%    This function together with *arts_oem* handle bookkeeping and
%    communication to perform OEM inversion with ARTS. Not all possible
%    retrieval set-ups are handled. However, it should be possible to apply
%    this function for most cases, while *arts_oem* is less general (where
%    handling of "non-standard" sensor retrievals are most problematic).
%
%    The standard sequence of function calls is:
%
%       [Qoem,O,R,xa] = arts_oem_init( Q, O, workfolder );
%       Sx            = arts_sx( Qoem, R );
%       Se            = covmat ...
%       X             = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%       %
%       clear Qoem
%
%    Fo "non-standard" cases, you have to make a function that can replace
%    *arts_oem* and give its function handle as input to *oem*.
%
%    Note that *arts_oem_init* can modify Q in such way that it can not be
%    used for further calculations. 
%
%    The implementation strategy is to avoid unnecessery reading and
%    writing of files, in order to obtain high calculation speed. The drawback
%    is that more variables must be kept in memory.
%
%    All pure forward model variables are stored in Q, while all extra data 
%    needed to handle the inversions are put into R. This data can be used
%    for further processing or "re-packing" of inversions results.
%    These fields always exist:
%       workfolder: Path to the temporary working folder.
%       jq        : ARTS description of jacobian quantities.
%       ji        : Start and stop index in J for each jacobian quantities.
%       cfile_y   : Name of control file to generate only y
%       cfile_yj  : Name of control to generate y and J
%       p_grid    : As the ARTS WSM with same name.
%       lat_grid  : As the ARTS WSM with same name.
%       lon_grid  : As the ARTS WSM with same name.
%
%    R can further contain these fields, depending on retrieval settings:
%       vmr_field0      : A priori vmr field
%       sensor_response : A copy of Q.SENSOR_RESPONSE 
%
% FORMAT   [Q,O,R,xa] = arts_oem_init(Q,O,workfolder)
%        
% Out   Q            Modified Q structure
%       O            Modified O structure
%       R            Structure with retrieval variables. See *arts_oem*.
%       xa           A priori state vector
% In    O            OEM settings.
%       Q            Qarts settings.
%       workfolder   Use this as "workfolder".

% 2010-01-11   Created by Patrick Eriksson.

function [Q,O,R,xa] = arts_oem_init(Q,O,workfolder)


%--- Start part --------------------------------------------------------------
                                                                           %&%
%- Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 2, nargin );                                                  %&%
if ~qarts_isset( Q.J_DO) | ~Q.J_DO                                         %&%
  error( 'Q.J_DO must be set to true.' );                                  %&%
end                                                                        %&%
rqre_datatype( workfolder, @ischar );                                      %&%




%- Initialization of variables
%
R            = [];
R.workfolder = workfolder;
%
[Q,R,t_field,z_field,vmr_field] = init_local( Q, R );


%- R continued
%
nq = length( R.jq );
nx = R.ji{nq}{2};


%- xa
%
xa = zeros( nx, 1 );


%- Some other variables
%
i_asj       = find( [ Q.ABS_SPECIES.RETRIEVE ] );
store_vmr0  = false;


%- O
%
O.i_rel = [];
O.i_log = [];



%--- Loop retrieval quantities and fill xa and R fields ----------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag


  case 'Absorption species'   %-----------------------------------------------
    %
    store_vmr0 = true;
    ig         = i_asj(i);    % Gas species index
    %
%    grid1         = R.jq{i}.grids{1};
%    R.x_p(ind)    = repmat( grid1, length(ind)/length(grid1), 1 );
%    R.x_t(ind)    = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, t_field, ...
%                                                            R.jq{i}.grids ) );
%    R.x_vmr0(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...
%                           get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      xa(ind)    = 1;
      O.i_rel    = [ O.i_rel ind ];
    elseif strcmp( R.jq{i}.mode, 'vmr' )
      xa(ind)    = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...
                          get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) );
    elseif strcmp( R.jq{i}.mode, 'nd' )
      xa(ind)    = vmr2nd( ...
                     mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...   % VMR
                       get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) ), ...
                     repmat( R.jq{i}.grids{1}, ...                    % P
                       length(ind)/length(R.jq{i}.grids{1}), 1 ), ...
                     mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...   % T
                       t_field, R.jq{i}.grids ) ) ...
                   );
                  %vmr2nd( R.x_vmr0(ind), R.x_p(ind), R.x_t(ind) );
    elseif strcmp( R.jq{i}.mode, 'logrel' )
      xa(ind)    = 0;
      O.i_log    = [ O.i_log ind ];
    else                                                                   %&%
      error( sprintf('Unknown gas species retrieval unit (%s).', ...       %&%
                                                         R.jq{i}.mode ) ); %&%
    end
    
  case 'Atmospheric temperatures'   %-----------------------------------------
    %
    xa(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, t_field, ...
                                                             R.jq{i}.grids ) );
   
  case { 'Frequency', 'Polynomial baseline fit', 'Sensor pointing' }
    %
    xa(ind) = 0;    

  otherwise   %---------------------------------------------------------------
    error('Unknown retrieval quantitity.'); 
  end
end 



%--- More to put into R ? -----------------------------------------------------

if store_vmr0
  R.vmr_field0 = vmr_field;
end



%--- Create control files -----------------------------------------------------
%
%- Only y
Q.J_DO    = false;
parts     = qarts2cfile( 'y_after_init' );
S         = qarts2cfile( Q, parts, R.workfolder );
cfile     = fullfile( R.workfolder, 'cfile_y.arts' );
strs2file( cfile, S );
R.cfile_y = cfile;
%
%- y+j
Q.J_DO     = true;
S          = qarts2cfile( Q, parts, R.workfolder );
cfile      = fullfile( R.workfolder, 'cfile_yj.arts' );
strs2file( cfile, S );
R.cfile_yj = cfile;

return





%-----------------------------------------------------------------------------
%--- Internal sub-functions
%-----------------------------------------------------------------------------

function Q = force_file_local( Q, fieldname, datatype, R )
  if ~ischar( getfield( Q, fieldname ) )
    filename = fullfile( R.workfolder, [lower(fieldname),'.xml'] );
    xmlStore( filename, Q.(fieldname), datatype );
    Q.(fieldname) = filename;
  end
return



function V = get_vmrfield_local( vmr_field, i )
  s               = ones( 1, 4 );
  s2              = size( vmr_field );
  s(1:length(s2)) = s2;
  V = zeros( s(2:end) );
  V(:,:,:) = vmr_field(i,:,:,:);
return



function [Q,R,t_field,z_field,vmr_field] = init_local( Q, R )

  %- Copy some data to R
  %
  % This is done here to possible save time; the data are forced to files below
  %
  R.p_grid   = qarts_get( Q.P_GRID );
  R.lat_grid = qarts_get( Q.LAT_GRID );
  R.lon_grid = qarts_get( Q.LON_GRID );

  %- Force some ARTS variables to be files 
  %
  % This is done to avoid creating the same file repeatedly in qarts2cfile.
  % This can be done for variables that never are part of the retrieval 
  % quantities. Some variables, beside the ones included here, are handled 
  % below.
  Q = force_file_local( Q, 'F_GRID', 'Vector', R );
  %
  Q = force_file_local( Q, 'P_GRID', 'Vector', R );
  if Q.ATMOSPHERE_DIM > 1
    Q = force_file_local( Q, 'LAT_GRID', 'Vector', R );
    if Q.ATMOSPHERE_DIM > 2
      Q = force_file_local( Q, 'LON_GRID', 'Vector', R );
    end
  end
  %
  Q = force_file_local( Q, 'SENSOR_POS', 'Matrix', R );
  Q = force_file_local( Q, 'SENSOR_LOS', 'Matrix', R );

  %- Atmospheric fields
  %
  % We do not want the option RAW_ATMOSPHERE here
  %
  if qarts_isset( Q.RAW_ATMOSPHERE )
    [t_field,z_field,vmr_field]       = arts_atmfields( Q );
    [Q.T_FIELD,Q.Z_FIELD,Q.VMR_FIELD] = deal( t_field, z_field, vmr_field );   
    Q.RAW_ATMOSPHERE                  = {};
  else
    t_field   = qarts_get( Q.T_FIELD );
    z_field   = qarts_get( Q.Z_FIELD );
    vmr_field = qarts_get( Q.VMR_FIELD );
  end
  %
  Q = force_file_local( Q, 'T_FIELD', 'Tensor3', R );
  Q = force_file_local( Q, 'Z_FIELD', 'Tensor3', R );
  Q = force_file_local( Q, 'VMR_FIELD', 'Tensor4', R );
  
  %- Absorption
  %
  if strcmp( Q.ABSORPTION, 'LoadTable' )
    Q = force_file_local( Q, 'ABS_LOOKUP', 'GasAbsLookup', R );
  elseif strcmp( Q.ABSORPTION, 'CalcTable' )
    Q            = qarts_abstable( Q );
    Q.ABS_LOOKUP = arts_abstable( Q, R.workfolder );
    Q.ABSORPTION = 'LoadTable';
  end
  
  %- Run arts to create jacobian and sensor variables
  %
  parts = qarts2cfile( 'y_init' );
  %
  S     = qarts2cfile( Q, parts, R.workfolder );
  cfile = fullfile( R.workfolder, 'cfile.arts' );
  strs2file( cfile, S );
  arts( cfile );

  %- Jacobian
  %
  R.jq = xmlLoad( fullfile( R.workfolder, 'jacobian_quantities.xml' ) );
  R.ji = xmlLoad( fullfile( R.workfolder, 'jacobian_indices.xml' ) );
  %                                                                      %&%
  if length( R.jq ) == 0                                                 %&%
    % Ending up here means probably a bug!                               %&%
    error( 'No retrieval quantities defined!?' );                        %&%
  end                                                                    %&%
  %
  for i = 1 : length(R.ji)           % Fix different indexing
    for j = 1 : length(R.ji{i})
      R.ji{i}{j} = R.ji{i}{j} + 1;
    end
  end

  %- Sensor
  %
  %- Check special cases                                                   %&%
  %                                                                        %&%
  if qarts_isset(Q.FFIT) & Q.FFIT.RETRIEVE
    if ~isstruct( Q.SENSOR_RESPONSE )                                      %&%
      error( ['When any frequency fit is performed ',...                   %&%
              '(Q.FFIT_RETRIEVAL=true), Q.SENSOR_RESPONSE must follow ',...%&%
              'qartsSensor (i.e. be a structure).'] );                     %&%
    end                                                                    %&% 
    %- A copy of Q.SENSOR_RESPONSE is needed here
    R.SENSOR_RESPONSE = Q.SENSOR_RESPONSE;
  end
  %
  Q.SENSOR_RESPONSE     = fullfile( R.workfolder, 'sensor_response.xml' );
  %
  Q.SENSOR_RESPONSE     = fullfile( R.workfolder, 'sensor_response.xml' );
  Q.SENSOR_RESPONSE_F   = fullfile( R.workfolder, 'sensor_response_f.xml' );
  Q.SENSOR_RESPONSE_ZA  = fullfile( R.workfolder, 'sensor_response_za.xml' );
  Q.SENSOR_RESPONSE_AA  = fullfile( R.workfolder, 'sensor_response_aa.xml' );
  Q.SENSOR_RESPONSE_POL = fullfile( R.workfolder, 'sensor_response_pol.xml' );
  Q.SENSOR_RESPONSE_F_GRID = ...
                        fullfile( R.workfolder, 'sensor_response_f_grid.xml' );
  Q.SENSOR_RESPONSE_ZA_GRID = ...
                       fullfile( R.workfolder, 'sensor_response_za_grid.xml' );
  Q.SENSOR_RESPONSE_AA_GRID  = ...
                       fullfile( R.workfolder, 'sensor_response_aa_grid.xml' );
  Q.SENSOR_RESPONSE_POL_GRID = ...
                      fullfile( R.workfolder, 'sensor_response_pol_grid.xml' );
  Q.MBLOCK_ZA_GRID      = fullfile( R.workfolder, 'mblock_za_grid.xml' );
  Q.MBLOCK_AA_GRID      = fullfile( R.workfolder, 'mblock_aa_grid.xml' );
return




