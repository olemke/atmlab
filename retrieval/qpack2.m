% QPACK2   Retrievals using arts-2
%
% FORMAT   P = qpack2(Q,Y)

function P = qpack2(Q,Y)

  
%-----------------------------------------------------------------------------
%- Initial part
%-----------------------------------------------------------------------------
 
%- Return directly if Y is totally empty
%
if isempty( Y )
  out(1,1);out(1,'Y totally empty ([]).');out(1,-1);
  P = [];
  return;
end
  
%- Check Q and force loaded data for some fields
%
Q = checkAndModifyQ( Q );

%- Initial check of Y
%
empty_y = checkY( Q, Y );

%- Create a work folder
%
workfolder = create_tmpfolder;

%- Set up fixed part of A (for qarts) and Sx
%
% This step includes calculation of sensor response data
%
[A,Sx,O] = createAandSxandO( Q, workfolder );

%- Inverse of Sx
%
% Is fixed and should only be calculated once (to save time)
%
Sxinv = Sx \ speye(size(Sx));




%-----------------------------------------------------------------------------
%- Invert measurements
%-----------------------------------------------------------------------------

P = [];
  
for m = 1 : length(Y)
  
  %- Set up data for next measurement
  %
  [A,Ythis] = nextMeasurement( Q, A, Y, m );

  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    if isempty(P)
      P    = Y(m);
    else
      P(m) = Y(m);
    end
    %
    fprintf( 'Simulating spectrum %d/%d\n', m, length(Y) );
    P(m).y = arts_y( A, workfolder );
  
  else
    %- Create Se
    %
    Se = createSe( Q, Ythis.tnoise_si );

    %- Perform retrieval
    %
    O.msg = sprintf( 'Inversion case %d (of %d)', m, length(Y) );
    %
    [Aoem,R,xa] = arts_oem_init( A );
    [X,R]       = oem( O, Aoem, R, @arts_oem, Sx, Se, Sxinv, [], xa, Ythis.y );
    %
    arts_oem( 'clean', R );
    clear Aoem 
    
    %- Fill return structure
    P = fillP( P, Q, A, Ythis, R, xa, X );

  end
end


%- Remove work folder
%
delete_tmpfolder( workfolder );

return


  
%------------------------------------------------------------------------------
%- Internal sub-functions
%------------------------------------------------------------------------------

% Check and load data into Q
%
function Q = checkAndModifyQ( Q )
  
  Q.F_BACKEND = qarts_get( Q.F_BACKEND );
  Q.TNOISE_C  = qarts_get( Q.TNOISE_C );

  if qarts_isset( Q.TNOISE_C )
    if ~issparse(Q.TNOISE_C)
      error( '*Q.TNOISE_C* is required to be sparse (to save memory).' );
    elseif size(Q.TNOISE_C,1) ~= size(Q.TNOISE_C,2)
      error( '*Q.TNOISE_C* must be square.' );
    elseif size(Q.TNOISE_C,1) ~= length(Q.F_BACKEND)
      error( 'Size of *Q.TNOISE_C* must match length of *Q.F_BACKEND*.' );
    end
  end
return



% Creates Sx and fixed parts of A 
%
function [A,Sx,O] = createAandSxandO(Q,workfolder)

  %- Check if needed atmlab settings are found
  %
  arts_includes = atmlab( 'ARTS_INCLUDES' );
  if isnan( arts_includes )
    error('You need to ARTS_INCLUDES to run qpack2.');
  end

  %- Init
  A   = qarts;
  Sx  = [];
  
  %- OEM 
  %
  % User settings
  O.linear              = Q.OEM_LINEAR;
  O.imethod             = Q.OEM_IMETHOD;
  O.stop_dx             = Q.OEM_STOP_DX;
  O.maxiter             = Q.OEM_MAXITER;
  %
  % Hard-coded settings
  %
  O.cost                = 1;
  O.e                   = 1;
  O.eo                  = 1;
  O.es                  = 1;
  if Q.OUT_Y
    O.yf                = 1;
  end
  if Q.OUT_A
    O.A                 = 1;
  end

    
  %- Hard-coded A settings
  %
  A.INCLUDES          = { fullfile( arts_includes, 'general.arts' ), ...
                          fullfile( arts_includes, 'continua.arts' ) };
  %
  A.ATMOSPHERE_DIM       = 1;
  A.STOKES_DIM           = 1;
  A.USE_RAW_ATMOSPHERE   = 0;
  A.CLOUDBOX_DO          = 0;
  %
  A.ABSORPTION           = 'OnTheFly';
  A.ABS_LINESHAPE        = 'Voigt_Kuntz6';
  A.ABS_LINESHAPE_CUTOFF = -1;
  A.ABS_LINESHAPE_FACTOR = 'quadratic'; 
  %
  A.R_GEOID              = constants( 'EARTH_RADIUS' );
  %
  A.SENSOR_POS           = A.R_GEOID + Q.PLATFORM_Z;
  %
  A.J_DO                 = 1;
  A.J                    = qartsJacobian;

  %- Line data
  %
  A.ABS_LINES            = Q.ABS_LINES;
  A.ABS_LINES_FORMAT     = Q.ABS_LINES_FORMAT;
    
  %- Surface and atmosphere
  %
  A.Z_SURFACE            = Q.SURFACE_Z;

  %- RT variables
  %
  A.PPATH_LMAX           = 200;
  A.PPATH_STEP_AGENDA    = { 'ppath_stepGeometric' };
  %
  if Q.CBGR
    A.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'MatrixCBR( iy, stokes_dim, f_grid )' };
  else
    A.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'nelemGet(nrows,f_grid)', 'Copy(ncols,stokes_dim)', ...
                          'MatrixSetConstant(iy,nrows,ncols,0)' };
  end
  
  %- Add species
  %
  pvalues = [];
  %
  for i = 1 : length( Q.SPECIES )
    if Q.SPECIES(i).RETRIEVE
      A = qarts_abs_species( A, {Q.SPECIES(i).TAG{:}}, 0, 1, [], [], ...
                             {Q.SPECIES(1).GRID}, Q.SPECIES(i).UNIT );
      Sx = covmat_append( Sx, Q.SPECIES(1).SX );
      pvalues = [ pvalues qarts_get(Q.SPECIES(1).GRID) ];
    else
      A = qarts_abs_species( A, {Q.SPECIES(i).TAG} );
    end
  end
  
  %- P_GRID
  %
  % Create by merge all calculation and retrievals grids, with points closer
  % than 50 m removed.
  %
  A.P_GRID = unique( pvalues );
  A.P_GRID = pow10( gridthinning( log10(A.P_GRID), 50/16e3 ) ); 
  A.P_GRID = A.P_GRID(end:-1:1);

  %- Sensor related stuff
  %
  S                 = qartsSensor;
  A.SENSOR_DO       = 1;
  S.SENSOR_NORM     = 1;
  %
  A.Y_UNIT          = Q.Y_UNIT;
  A.ANTENNA_DIM     = 1;
  A.MBLOCK_ZA_GRID  = Q.MBLOCK_ZA_GRID;
  %
  if Q.BACKEND_DO
    A.F_GRID                   = Q.F_GRID;
    S.F_BACKEND                = Q.F_BACKEND;
    S.BACKEND_CHANNEL_RESPONSE = Q.BACKEND_CHANNEL_RESPONSE;
  else
    A.F_GRID                   = Q.F_BACKEND;
  end
  %
  S.BEAM_SWITCHING = Q.BEAM_SWITCHING;
  %
  A.SENSOR_RESPONSE = S;
  A = arts_sensor( A, workfolder );
  
  % Polyfit
  %
  if Q.POLYFIT_DO
    l = Q.POLYFIT_ORDER + 1;
    if length(Q.POLYFIT_SI) ~= l
      error('Length of *Q.POLYFIT_SI* must be Q.POLYFIT_ORDER + 1.');
    end
    %
    A.J.POLYFIT.DO         = 1;
    A.J.POLYFIT.POLY_ORDER = Q.POLYFIT_ORDER;
    %
    Sx = covmat_append( Sx, spdiags(vec2col(Q.POLYFIT_SI).^2,0,l,l) );
  end
return



% Creates observation error matrix, Se
%
function Se = createSe( Q, tnoise_si )

  n    = length( tnoise_si );
  nf   = length( Q.F_BACKEND );
  cset = qarts_isset( Q.TNOISE_C );
  
  if n ~= 1  & n ~= nf
    error( 'Length of *tnoise_si* must be 1 or match *Q.F_BACKEND*.' );
  end
  
  if n == 1
    if cset
      Se = (tnoise_si^2) .* Q.TNOISE_C;
    else
      Se = spdiags( repmat(tnoise^2,nf,1), 0, nf, nf );
    end
  else
    if cset
      [i,j,s] = find( Q.TNOISE_C );
      for k = 1 : length(i)
        s(k) = prod( thermal_si([i(k) j(k)]) ) * s(k);
      end
      Se = sparse(i,j,s);
    else
      Se = spdiags( vec2col(tnoise_si.^2), 0, nf, nf );
    end
  end
return


  
% Check if mandatory fields of Y exist
%
function empty_y = checkY( Q, Y )

  % Default values are not set here as Y could be very big and we do not want
  % to create a copy. Defaults are instead set below in getYthis.
  
  % Spectrum
  if ~isfield( Y, 'y' )
    error( 'Y must include the field ''y''.' );
  end

  % Time information
  if ~isfield(Y,'year') | ~isfield(Y,'month') | ~isfield(Y,'day')
    error( 'Y must include the fields ''year'', ''month'' and ''day''.' );
    error( 'At least  data must be set.' );
  end

  % Zenith angle
  if ~isfield( Y, 'zenith_angle' )
    error( 'Y must include the field ''zenith_angle''.' );
  end

  % Thermal noise
  if ~isfield( Y, 'tnoise_si' )
    error( 'Y must include the field ''tnoise_si''.' );
  end

  % HSE point
  if ~isfield( Y, 'hse_p' )  |  ~isfield( Y, 'hse_p' ) 
    error( 'Y must include the fields ''hse_p'' and ''hse_z''.' );
  end
    
  % All y empty 
  if isempty( Y(1).y )
    if length([Y(:).y]) > 0
      error( [ 'First spectrum in Y is empty. Then all other spectra must '...
               'also be empty.'] );
    end
    empty_y = 1;
  else
    for i = 1 : length(Y)
      if length(Y(i).y) ~= length(Q.F_BACKEND)
        error( sprintf(['Length of spectrum %d does not match length of ' ...
                        '*Q.F_BACKEND*'], i ) );
      end
    end
    empty_y = 0;
  end
return



% Jump to next measurement
%
% y is set to Y(i) if spectrum is empty
%
function [A,Ythis] = nextMeasurement( Q, A, Y, i )

  Ythis = Y(i);
  
  %- Observation direction
  %
  A.SENSOR_LOS = Ythis.zenith_angle;

  %- Position set?
  %
  if ~isfield( Ythis, 'latitude' ),  Ythis.latitude  = Q.PLATFORM_LAT; end
  if ~isfield( Ythis, 'longitude' ), Ythis.longitude = Q.PLATFORM_LON; end  
  
  %- Non mandatory time data
  %
  if ~isfield( Ythis, 'hour' ),   Ythis.hour = 12;  end
  if ~isfield( Ythis, 'minute' ), Ythis.minute = 0; end
  if ~isfield( Ythis, 'second' ), Ythis.second = 0; end

  %- Create atmospheric fields
  %
  A.VMR_FIELD = zeros( length(A.ABS_SPECIES), length(A.P_GRID), 1, 1 );
  %
  h2o = [];
  %
  for i = 1 : length(A.ABS_SPECIES) 
    A.VMR_FIELD(i,:,1,1) = clmtlgy_interp( ...
                           Q.ATMDATA_D, Q.SPECIES(i).ATMDATA, A.P_GRID, ...
                           Ythis.latitude, Ythis.longitude, ...
                           Ythis.year, Ythis.month, Ythis.day, ...
                           Ythis.hour, Ythis.minute, Ythis.second );
    if isempty(h2o)
      species = arts_tgs2species( A.ABS_SPECIES{i}{1} );
      if strcmp( species, 'H2O' )
        h2o = A.VMR_FIELD(i,1,1,1);
      end
    end
  end
  %
  A.T_FIELD = clmtlgy_interp( Q.ATMDATA_D, Q.T.ATMDATA, A.P_GRID, ...
                           Ythis.latitude, Ythis.longitude, ...
                           Ythis.year, Ythis.month, Ythis.day, ...
                           Ythis.hour, Ythis.minute, Ythis.second ); 
  %
  A.Z_FIELD = pt2z( A.P_GRID, A.T_FIELD, h2o, Ythis.hse_p, Ythis.hse_z, ...
                                                              Ythis.latitude );
return



% Fill output structure
%
function P = fillP( P, Q, A, Ythis, R, xa, X )

  i = length(P) + 1;

  % Start and stop index for each retrieval quantity  
  I = zeros( length(R.jq), 2 );
  for q = 1 : length(R.jq)
    I(q,:) = [ R.ji{q}{1}  R.ji{q}{2} ];
  end
  
  % Position and time 
  P(i).latitude  = Ythis.latitude;
  P(i).longitude = Ythis.longitude;
  P(i).year      = Ythis.year;
  P(i).month     = Ythis.month;
  P(i).month     = Ythis.month;
  P(i).day       = Ythis.day;
  P(i).hour      = Ythis.hour;
  P(i).minute    = Ythis.minute;
  P(i).second    = Ythis.second;
 
  % Retrieval diagnostics 
  %
  P(i).tnoise_si = mean( Ythis.tnoise_si );
  %
  if Q.OEM_LINEAR 
    P(i).converged = X.converged;
  end 
  P(i).cost   = X.cost;
  P(i).cost_x = X.cost_x;
  P(i).cost_y = X.cost_y;
  %  
  if Q.OUT_A
    As = splitA( X.A, I );
  end
  %
  mresp = mrespA( X.A, I );
  
  % Spectra
  if Q.OUT_Y
    P(i).f   = Q.F_BACKEND;
    P(i).y   = Ythis.y;
    P(i).yf  = X.yf;
  end
 
  % PTZ (a priori or forward model parameters)
  if Q.OUT_PTZ
    P(i).p = vec2col( A.P_GRID );
    P(i).t = A.T_FIELD;
    P(i).z = A.Z_FIELD;
  end

  % Retrieval quantities
  %
  ispecies = 0;
  tdone    = 0;
  %
  for q = 1 : length(R.jq)

    unitfac = 1;
    include = 1;
    ind     = I(q,1) : I(q,2);
    
    
    if strcmp( R.jq{q}.maintag, 'Absorption species' )
      %------------------------------------------------------------------------
      ispecies = ispecies + 1;
      s        = sprintf( 'species%d', ispecies );
      %
      if strcmp( A.J.ABS_SPECIES(q).UNIT, 'rel' )
        unitfac = R.x_vmr0(ind);
      end
      %
      P(i).([s,'_name'])  = R.jq{q}.subtag;
      P(i).([s,'_p'])     = vec2col( A.J.ABS_SPECIES(ispecies).GRID1 );
    
    
    elseif strcmp( R.jq{q}.maintag, 'Polynomial baseline fit' )
      %------------------------------------------------------------------------
      if Q.OUT_BASELINE
        s = sprintf( 'polyfit%s', R.jq{q}.subtag(end) );
        P(i).baseline = R.bl;
      else
        include = 0;
      end
      
      
    else
      error( sprintf( 'Unknown retrieval quantity: %s', R.jq{q}.maintag ) );
    end

    if include
      P(i).([s,'_x'])  = unitfac .* X.x(ind);
      P(i).([s,'_xa']) = unitfac .* xa(ind);
      P(i).([s,'_e'])  = unitfac .* X.e(ind);
      P(i).([s,'_eo']) = unitfac .* X.eo(ind);
      P(i).([s,'_es']) = unitfac .* X.es(ind);
      P(i).([s,'_mr']) = mresp(ind);
      if Q.OUT_A
        P(i).([s,'_A']) = As{q};
      end
    end
  end
  
return