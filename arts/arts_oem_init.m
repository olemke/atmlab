function [Q,R,Sx,xa] = arts_oem_init(Q,R)


%- Handle special case of arts_oem_init('clean',R) ---------------------------

if ischar(Q)  &  strcmp( Q, 'clean' )
  delete_tmpfolder( R.workfolder );
  return                               % --->
end

%-----------------------------------------------------------------------------





%--- Start part --------------------------------------------------------------


%- Default values
%
if nargin < 2,   R = [];  end


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
R.workfolder = create_tmpfolder;


%--- Use ARTS to get basic retrieval information and atmospheric fields
%
[R.jq,R.ji,t_field,z_field,vmr_field] = arts_internal( Q, R );



%- Atmospheric fields
%
% Option USE_RAW_ATMOSPHERE is not handled here. As a start all fields are
% set to be variables.
%
Q.USE_RAW_ATMOSPHERE = 0;
Q.T_FIELD            = t_field;
Q.Z_FIELD            = z_field;
Q.VMR_FIELD          = vmr_field;  





%--- Initialization of variables ----------------------------------------------

%- xa and Sx
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
xa = zeros( nx, 1 );
Sx = sparse( nx, nx );


%- Fields of R
%
R.p    = repmat( NaN, nx, 1 );
R.t    = R.p;
R.vmr0 = R.p;


%- Some other variables
%
any_gas = false;
any_tz  = false;
i_asj   = find( [ Q.J.ABS_SPECIES.DO ] );





%--- Loop retrieval quantities and fill xa and Sx ----------------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag



  case 'Abs. species'   %------------------------------------------------------
    %
    any_gas = true;
    ig      = i_asj(i);    % Gas species index
    %
    %- Get p, t and vmr for each retrieval point
    grid1      = qarts_get( Q.J.ABS_SPECIES(ig).GRID1 );
    R.p(ind)   = repmat( grid1, length(ind)/length(grid1), 1 );
    R.t(ind)   = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, Q.T_FIELD, ...
                                                       Q.J.ABS_SPECIES(ig) ) );
    R.vmr0(ind) = mat2col( arts_atminterp( Q.ATMOSPHERE_DIM, Q, ...
                       get_vmrfield_i(Q.VMR_FIELD,ig), Q.J.ABS_SPECIES(ig) ) );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      xa(ind)    = 1;
    else
      if strcmp( R.jq{i}.mode, 'vmr' )
        xa(ind) = R.vmr0(ind);
      elseif strcmp( R.jq{i}.mode, 'nd' )
        xa(ind) = vmr2nd( R.vmr0(ind), R.p(ind), R.t(ind) );
      else
        error( sprintf('Unknown gas species retrieval unit (%s).', ...
                                                              R.jq{i}.mode ) );
      end
    end
    %
    Sx(ind,ind) = arts_covmat( Q.ATMOSPHERE_DIM, R.SX.ABS_SPECIES(ig), ... 
                                                  Q.J.ABS_SPECIES(ig), 'atm' );



  otherwise   %----------------------------------------------------------------
    error('Unknown retrieval characteristics.'); 
  end
end 




%--- Modify Q to simplify and avoid creating files repeatedly -----------------
%
% This is done here for quantities that can not be affected by the
% the retrieval.

%- Basic grids
%
Q = force_file( Q, 'F_GRID', 'Vector', R );
Q = force_file( Q, 'P_GRID', 'Vector', R );
if Q.ATMOSPHERE_DIM > 1
  Q = force_file( Q, 'LAT_GRID', 'Vector', R );
  if Q.ATMOSPHERE_DIM > 2
    Q = force_file( Q, 'LON_GRID', 'Vector', R );
  end
end

%- Atmospheric fields
%
if ~any_gas
  Q = force_file( Q, 'VMR_FIELD', 'Tensor4', R );
end
%
if ~any_tz
  Q = force_file( Q, 'T_FIELD', 'Tensor3', R );
  Q = force_file( Q, 'Z_FIELD', 'Tensor3', R );
end


%- Absorption
%
Q = force_file( Q, 'ABS_LOOKUP', 'GasAbsLookup', R );

return





%-----------------------------------------------------------------------------
%--- Internal sub-functions
%-----------------------------------------------------------------------------

function Q = force_file( Q, fieldname, datatype, R )
 
  if ~ischar( getfield( Q, fieldname ) )
    filename = fullfile( R.workfolder, [fieldname,'.xml'] );
    xmlStore( filename, getfield( Q, fieldname ), datatype );
    setfield( Q, fieldname, filename );
  end
return



function [jq,ji,t_field,z_field,vmr_field] = arts_internal( Q, R )

  tmpfolder   = R.workfolder;

  if Q.USE_RAW_ATMOSPHERE
   parts = { 'start1', 'start2', 'load_atm', 'save_atm', 'init_rte', ...
             'sensor', 'j', 'stop' };
  else
    parts = { 'start1', 'start2', 'load_atm', 'init_rte', ...
             'sensor', 'j', 'stop' };
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



function V = get_vmrfield_i( vmr_field, i )
  s               = ones( 1, 4 );
  s2              = size( vmr_field );
  s(1:length(s2)) = s2;
  V = zeros( s(2:end) );
  V(:,:,:) = vmr_field(i,:,:,:);
return

