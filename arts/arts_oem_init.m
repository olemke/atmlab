% ARTS_OEM_INIT   Initialization of OEM inversions by ARTS
%
%   See *arts_oem* for usage of this function.
%
% FORMAT   [Q,R,xa] = arts_oem_init( Q )
%        
% Out   Q    Modified Q structure
%       R    Structure with retrieval variables. See *arts_oem*.
%       xa   A priori state vector
% In    Q    Qarts settings.
%
% 2006-09-07   First working version by Patrick Eriksson.


function [Q,R,xa] = arts_oem_init(Q)



%--- Start part --------------------------------------------------------------

%- Check input
%
min_nargin( 1, nargin );
rqre_datatype( 'struct', Q );
%
if ~isstruct(Q.J)
  error('No jacobian defined !!!.');
end

%- Create work folder
%
R            = [];
R.workfolder = create_tmpfolder;

%- Initialization of variables
%
Q.J_DO = 1;    % Ensure that jacobian calculations will be done
%
[Q,R,t_field,z_field,vmr_field] = init_local( Q, R );

%- R
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
R.x_p    = repmat( NaN, nx, 1 );
R.x_t    = R.x_p;
R.x_vmr0 = R.x_p;

%- xa
%
xa = zeros( nx, 1 );

%- Some other variables
%
i_asj   = find( [ Q.J.ABS_SPECIES.DO ] );
any_gas = false;




%--- Loop retrieval quantities and fill xa and R fields ----------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag


  case 'Absorption species'   %-----------------------------------------------
    %
    ig      = i_asj(i);    % Gas species index
    any_gas = true;
    %
    %- Get p, t and vmr for each retrieval point
    grid1         = R.jq{i}.grids{1};
    R.x_p(ind)    = repmat( grid1, length(ind)/length(grid1), 1 );
    R.x_t(ind)    = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, t_field, ...
                                                             R.jq{i}.grids ) );
    R.x_vmr0(ind) = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, ...
                            get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) );
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

  case 'Polynomial baseline fit'   %------------------------------------------
    %
    xa(ind) = 0;    

  otherwise   %---------------------------------------------------------------
    error('Unknown retrieval quantitity.'); 
  end
end 



%--- More to put into R ? -----------------------------------------------------

if any_gas
  R.vmr_field = vmr_field;
end



%--- Create control files -----------------------------------------------------
%
%- Only y
Q.J_DO    = 0;
parts     = qarts2cfile( 'y' );
S         = qarts2cfile( Q, parts, R.workfolder );
cfile     = fullfile( R.workfolder, 'cfile_y.arts' );
qtool( S, cfile, [] );
R.cfile_y = cfile;
%
%- y+j
Q.J_DO     = 1;
S          = qarts2cfile( Q, parts, R.workfolder );
cfile      = fullfile( R.workfolder, 'cfile_yj.arts' );
qtool( S, cfile, [] );
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
  % We do not want the option USE_RAW_ATMOSPHERE here
  %
  if Q.USE_RAW_ATMOSPHERE 
    [t_field,z_field,vmr_field]       = arts_atmfields( Q );
    [Q.T_FIELD,Q.Z_FIELD,Q.VMR_FIELD] = deal( t_field, z_field, vmr_field );   
    Q.USE_RAW_ATMOSPHERE              = 0;
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
    Q                  = qarts_abstable( Q );
    Q.ABS_LOOKUP       = arts_abstable( Q, R.workfolder );
    Q.ABSORPTION       = 'LoadTable';
  end
  
  %- Run arts to create jacobian and sensor variables
  %
  parts     = qarts2cfile( 'y_init' );
  %
  S     = qarts2cfile( Q, parts, R.workfolder );
  cfile = fullfile( R.workfolder, 'cfile.arts' );
  qtool( S, cfile, [] );
  arts( cfile );

  %- Jacobian
  %
  R.jq = xmlLoad( fullfile( R.workfolder, 'jacobian_quantities.xml' ) );
  R.ji = xmlLoad( fullfile( R.workfolder, 'jacobian_indices.xml' ) );
  %
  if length( R.jq ) == 0 
    % Ending up here means probably a bug!
    error( 'No retrieval quantities defined!?' );
  end
  %
  for i = 1 : length(R.ji)           % Fix different indexing
    for j = 1 : length(R.ji{i})
      R.ji{i}{j} = R.ji{i}{j} + 1;
    end
  end

  %- Sensor
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
  Q.ANTENNA_DIM         = fullfile( R.workfolder, 'antenna_dim.xml' );
  Q.MBLOCK_ZA_GRID      = fullfile( R.workfolder, 'mblock_za_grid.xml' );
  Q.MBLOCK_AA_GRID      = fullfile( R.workfolder, 'mblock_aa_grid.xml' );

return




