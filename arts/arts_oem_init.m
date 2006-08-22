function [Q,R,Sx,xa] = arts_oem_init(Q,R)


%- Handle special case of arts_oem_init('clean',R)
%
if ischar(Q)  &  strcmp( Q, 'clean' )
  delete_tmpfolder( R.workfolder );
  return
end



%- Default values
%
if nargin < 2,   R = [];  end


%- Check input
%
min_nargin( 1, nargin );
rqre_datatype( 'struct', Q );
%
if ~Q.JACOBIAN_DO
  error('Inversion turned off (Q.JACOBIAN.DO = 0) !!!.');
end


%- Extract some information from ARTS
%
[R.jq,R.ji,t_field,z_field,vmr_field] = arts_internal( Q );


%- Init xa and Sx
%
nq = length( R.jq );
nx = R.ji{nq}{2};
%
xa = zeros( nx, 1 );
Sx = sparse( nx, nx );


%- Init some fields of R
%
R.p   = repmat( NaN, nx, 1 );
R.t   = R.p;
R.vmr = R.p;


%- Create work folder
%
R.workfolder = create_tmpfolder;


%- Some other variables
%
i_asj = find( [ Q.ABS_SPECIES_JAC.DO ] );


%- Loop retrieval quantities and fill xa and Sx
%
for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

  case 'Gas species'   %-------------------------------------------------------
    %
    %- Data communication here done by VMR_FIELD, not USE_RAW_ATMOSPHERE 
    if Q.USE_RAW_ATMOSPHERE 
      Q.USE_RAW_ATMOSPHERE = 0;
      Q.T_FIELD            = t_field;
      Q.Z_FIELD            = z_field;
      Q.VMR_FIELD          = vmr_field;  
    end
    %
    ig  = i_asj(i);    % Gas species index
    %
    %- Get p and T for each retrieval point 
    R.p(ind)   = repmat( Q.ABS_SPECIES_JAC(ig).P_GRID, ...
                         length(ind)/length(Q.ABS_SPECIES_JAC(ig).P_GRID), 1 );
    D          = arts_atminterp( Q.ATMOSPHERE_DIM, Q, Q.T_FIELD, ...
                                                       Q.ABS_SPECIES_JAC(ig) );
    R.t(ind)   = D(:);
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      xa(ind)    = 1;
      %- Get VMR for each retrieval point 
      D          = arts_atminterp( Q.ATMOSPHERE_DIM, Q, ...
                       get_vmrfield_i(Q.VMR_FIELD,ig), Q.ABS_SPECIES_JAC(ig) );
      R.vmr(ind) = D(:);
    else
      if strcmp( R.jq{i}.mode, 'vmr' )
        xa(ind) = R.vmr(ind);
      elseif strcmp( R.jq{i}.mode, 'nd' )
        xa(ind) = vmr2nd( R.vmr(ind), R.p(ind), R.t(ind) );
      else
        error( sprintf('Unknown gas species retrieval unit (%s).', ...
                                                              R.jq{i}.mode ) );
      end
    end
    %
    Sx(ind,ind) = arts_covmat( Q.ATMOSPHERE_DIM, Q.ABS_SPECIES_SX(ig), ... 
              Q.ABS_SPECIES_JAC(ig).P_GRID, Q.ABS_SPECIES_JAC(ig).LAT_GRID, ...
                                       Q.ABS_SPECIES_JAC(ig).LON_GRID, 'atm' );

  otherwise
    error('Unknown retrieval characteristics.'); 
  end
end 



%-----------------------------------------------------------------------------

function [jq,ji,t_field,z_field,vmr_field] = arts_internal( Q )

  tmpfolder   = create_tmpfolder;

  if Q.USE_RAW_ATMOSPHERE
    parts = { 'start1', 'start2', 'load_atm', 'save_atm', 'init_rte', ...
             'sensor', 'jq', 'stop' };
  else
    parts = { 'start1', 'start2', 'load_atm', 'init_rte', ...
             'sensor', 'jq', 'stop' };
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
  end

  delete_tmpfolder( tmpfolder );
return



function V = get_vmrfield_i( vmr_field, i )
  %
  s               = ones( 1, 4 );
  s2              = size( vmr_field );
  s(1:length(s2)) = s2;
  V = zeros( s(2:end) );
  V(:,:,:) = vmr_field(i,:,:,:);
  %
return