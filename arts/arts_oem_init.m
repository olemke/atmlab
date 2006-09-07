% ARTS_OEM_INIT   Initialization of OEM inversions by ARTS
%
%   See *arts_oem* for usage of this function.
%
% FORMAT   [R,y,J] = arts_oem( Q, R, x, iter )
%        
% OUT   Q     Qarts structure. See *qarts*.
%       R     Retrieval data structure. See *arts_oem*.
%       xa    A priori state vector.
% IN    Q     Qarts structure. See *qarts*.

% 2006-09-07   First working version by Patrick Eriksson.


function [Q,R,xa] = arts_oem_init(Q)



%--- Start part --------------------------------------------------------------

%- Check input
%
min_nargin( 1, nargin );
rqre_datatype( 'struct', Q );
%
if ~isstruct(Q.J)
  error('No jacobain defined !!!.');
end


%- Create work folder
%
R            = [];
R.workfolder = create_tmpfolder;


%- Copy some data to R.
%
% This is done here to possible save time, as the data is forced to files below
%
R.p_grid   = qarts_get( Q.P_GRID );
R.lat_grid = qarts_get( Q.LAT_GRID );
R.lon_grid = qarts_get( Q.LON_GRID );





%- Everything below is put into try-catch to enable that work folder is
%- removed if something goes wrong.
%
try

%--- Force some ARTS variables to be files ------------------------------------
%
% This is done to avoid creating the same file repeatedly in qarts2cfile.
% This can be done for variables that never are part of the retrieval 
% quantities. Some variables, beside the ones included here, are handled 
% close to the end of the (main) function.

%- Basic grids
Q = force_file( Q, 'F_GRID', 'Vector', R );
%
Q = force_file( Q, 'P_GRID', 'Vector', R );
if Q.ATMOSPHERE_DIM > 1
  Q = force_file( Q, 'LAT_GRID', 'Vector', R );
  if Q.ATMOSPHERE_DIM > 2
    Q = force_file( Q, 'LON_GRID', 'Vector', R );
  end
end

%- Absorption
Q = force_file( Q, 'ABS_LOOKUP', 'GasAbsLookup', R );

%- Sensor LOS and POS
Q = force_file( Q, 'SENSOR_POS', 'Matrix', R );
Q = force_file( Q, 'SENSOR_LOS', 'Matrix', R );



%----- Use ARTS to get basic retrieval information and atmospheric fields -----

[R.jq,R.ji,t_field,z_field,vmr_field] = arts_internal( Q, R );





%--- Initialization of variables ----------------------------------------------

%- xa
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
xa = zeros( nx, 1 );


%- R
%
R.x_p      = repmat( NaN, nx, 1 );
R.x_t      = R.x_p;
R.x_vmr0   = R.x_p;


%- Some other variables
%
i_asj   = find( [ Q.J.ABS_SPECIES.DO ] );
any_gas = false;




%--- Loop retrieval quantities and fill xa and R fields ----------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag


  case 'Abs. species'   %------------------------------------------------------
    %
    ig      = i_asj(i);    % Gas species index
    any_gas = true;
    %
    %- Get p, t and vmr for each retrieval point
    grid1        = R.jq{i}.grids{1};
    R.x_p(ind)   = repmat( grid1, length(ind)/length(grid1), 1 );
    R.x_t(ind)   = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, t_field, ...
                                                             R.jq{i}.grids ) );
    R.x_vmr0(ind) = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, ...
                               get_vmrfield_i(vmr_field,ig), R.jq{i}.grids ) );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      xa(ind)    = 1;
    else
      if strcmp( R.jq{i}.mode, 'vmr' )
        xa(ind) = R.x_vmr0(ind);
      elseif strcmp( R.jq{i}.mode, 'nd' )
        xa(ind) = vmr2nd( R.x_vmr0(ind), R.x_p(ind), R.x_t(ind) );
      else
        error( sprintf('Unknown gas species retrieval unit (%s).', ...
                                                              R.jq{i}.mode ) );
      end
    end


  otherwise   %----------------------------------------------------------------
    error('Unknown retrieval characteristics.'); 
  end
end 




%--- More to put into R ? -----------------------------------------------------

if any_gas
  R.vmr_field = vmr_field;
end





%--- Continued modification of Q fields ---------------------------------------

%- Atmospheric fields
%
% Option USE_RAW_ATMOSPHERE is not handled here. 
%
if Q.USE_RAW_ATMOSPHERE
  Q.USE_RAW_ATMOSPHERE = 0;
  Q.T_FIELD            = t_field;
  Q.Z_FIELD            = z_field;
  Q.VMR_FIELD          = vmr_field;
end
%
Q = force_file( Q, 'VMR_FIELD', 'Tensor4', R );
Q = force_file( Q, 'T_FIELD', 'Tensor3', R );
Q = force_file( Q, 'Z_FIELD', 'Tensor3', R );

%- Sensor
%
% In arts_internal all sensor response variables are stored as files
%
Q.SENSOR_RESPONSE     = fullfile( R.workfolder, 'sensor_response.xml' );
Q.SENSOR_RESPONSE_F   = fullfile( R.workfolder, 'sensor_response_f.xml' );
Q.SENSOR_RESPONSE_ZA  = fullfile( R.workfolder, 'sensor_response_za.xml' );
Q.SENSOR_RESPONSE_AA  = fullfile( R.workfolder, 'sensor_response_aa.xml' );
Q.SENSOR_RESPONSE_POL = fullfile( R.workfolder, 'sensor_response_pol.xml' );
Q.ANTENNA_DIM         = fullfile( R.workfolder, 'antenna_dim.xml' );
Q.MBLOCK_ZA_GRID      = fullfile( R.workfolder, 'mblock_za_grid.xml' );
Q.MBLOCK_AA_GRID      = fullfile( R.workfolder, 'mblock_aa_grid.xml' );





%--- Create control files -----------------------------------------------------
%
%- y+j
parts = qarts2cfile( 'y+j' );
S     = qarts2cfile( Q, parts, R.workfolder );
cfile = fullfile( R.workfolder, 'cfile_yj.arts' );
qtool( S, cfile, [] );
R.cfile_yj = cfile;
%
%- Only y
parts = qarts2cfile( 'y' );
S     = qarts2cfile( Q, parts, R.workfolder );
cfile = fullfile( R.workfolder, 'cfile_y.arts' );
qtool( S, cfile, [] );
R.cfile_y = cfile;





%- Something went wrong?
%
catch
  delete_tmpfolder( R.workfolder );
  rethrow(lasterror);
end

return





%-----------------------------------------------------------------------------
%--- Internal sub-functions
%-----------------------------------------------------------------------------

function Q = force_file( Q, fieldname, datatype, R )
  if ~ischar( getfield( Q, fieldname ) )
    filename = fullfile( R.workfolder, [lower(fieldname),'.xml'] );
    xmlStore( filename, Q.(fieldname), datatype );
    Q.(fieldname) = filename;
  end
return



function V = get_vmrfield_i( vmr_field, i )
  s               = ones( 1, 4 );
  s2              = size( vmr_field );
  s(1:length(s2)) = s2;
  V = zeros( s(2:end) );
  V(:,:,:) = vmr_field(i,:,:,:);
return



function [jq,ji,t_field,z_field,vmr_field] = arts_internal( Q, R )

  tmpfolder   = R.workfolder;

  if Q.USE_RAW_ATMOSPHERE
   parts = { 'start1', 'start2', 'load_atm', 'save_atm', 'init_rte', ...
             'sensor', 'save_sensor' 'j', 'stop' };
  else
    parts = { 'start1', 'start2', 'load_atm', 'init_rte', ...
             'sensor', 'save_sensor', 'j', 'stop' };
  end

  S = qarts2cfile( Q, parts, tmpfolder );

  cfile = fullfile( tmpfolder, 'cfile.arts' );

  qtool( S, cfile, [] );

  arts( cfile );

  jq = xmlLoad( fullfile( tmpfolder, 'jacobian_quantities.xml' ) );
  ji = xmlLoad( fullfile( tmpfolder, 'jacobian_indices.xml' ) );

  %- Fix different indexing
  %
  for i = 1 : length(ji)
    for j = 1 : length(ji{i})
      ji{i}{j} = ji{i}{j} + 1;
    end
  end

  if Q.USE_RAW_ATMOSPHERE  &  nargout >= 3
    t_field   = xmlLoad( fullfile( tmpfolder, 't_field.xml' ) );
    z_field   = xmlLoad( fullfile( tmpfolder, 'z_field.xml' ) );
    vmr_field = xmlLoad( fullfile( tmpfolder, 'vmr_field.xml' ) ); 
  else
    t_field   = qarts_get( Q.T_FIELD );
    z_field   = qarts_get( Q.Z_FIELD );
    vmr_field = qarts_get( Q.VMR_FIELD );
  end
return




