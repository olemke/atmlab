function P = gpack(G,Y)

  
%-----------------------------------------------------------------------------
%- Initial part
%-----------------------------------------------------------------------------
 
%- Check G and force loaded data for some fields
%
G = checkAndModifyG( G );

%- Initial check of Y
%
empty_y = checkY( G, Y );

%- Create a work folder
%
workfolder = create_tmpfolder;

%- Set up fixed part of Q (for qarts) and Sx
%
% This step includes calculation of sensor response data
%
[Q,Sx,O] = createQandSxandO( G, workfolder );

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
  [Q,Ythis] = nextMeasurement( G, Q, Y, m );

  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    if isempty(P)
      P    = Y(m);
    else
      P(m) = Y(m);
    end
    %
    P(m).y = arts_y( Q, workfolder );
  
  else
    %- Create Se
    %
    Se = createSe( G, Ythis.tnoise_si );

    %- Perform retrieval
    %
    [Qoem,R,xa] = arts_oem_init( Q );
    X           = oem( O, Qoem, R, @arts_oem, Sx, Se, Sxinv, [], xa, Ythis.y );
    %
    arts_oem( 'clean', R );
    clear Qoem 
    
    %- Fill return structure
    P = fillP( P, G, Q, Ythis, R, xa, X );

  end
end


%- Remove work folder
%
delete_tmpfolder( workfolder );

return


  
%------------------------------------------------------------------------------
%- Internal sub-functions
%------------------------------------------------------------------------------

% Check and load data into G
%
function G = checkAndModifyG( G )
  
  G.F_BACKEND = qarts_get( G.F_BACKEND );
  G.TNOISE_C  = qarts_get( G.TNOISE_C );

  if qarts_isset( G.TNOISE_C )
    if ~issparse(G.TNOISE_C)
      error( '*G.TNOISE_C* is required to be sparse (to save memory).' );
    elseif size(G.TNOISE_C,1) ~= size(G.TNOISE_C,2)
      error( '*G.TNOISE_C* must be square.' );
    elseif size(G.TNOISE_C,1) ~= length(G.F_BACKEND)
      error( 'Size of *G.TNOISE_C* must match length of *G.F_BACKEND*.' );
    end
  end
return



% Creates Sx and fixed parts of Q 
%
function [Q,Sx,O] = createQandSxandO(G,workfolder)

  %- Check if needed atmlab settings are found
  %
  arts_includes = atmlab( 'ARTS_INCLUDES' );
  if isnan( arts_includes )
    error('You need to ARTS_INCLUDES to run this example.');
  end

  %- Init
  Q   = qarts;
  Sx  = [];
  
  %- OEM 
  %
  % User settings
  O.linear              = G.OEM_LINEAR;
  O.imethod             = G.OEM_IMETHOD;
  O.stop_dx             = G.OEM_STOP_DX;
  O.maxiter             = G.OEM_MAXITER;
  %
  % Hard-coded settings
  %
  O.cost                = 1;
  O.e                   = 1;
  O.eo                  = 1;
  O.es                  = 1;
  if G.OUT_Y
    O.yf                = 1;
  end
  if G.OUT_A
    O.A                 = 1;
  end

    
  %- Hard-coded Q settings
  %
  Q.INCLUDES          = { fullfile( arts_includes, 'general.arts' ), ...
                          fullfile( arts_includes, 'continua.arts' ) };
  %
  Q.ATMOSPHERE_DIM       = 1;
  Q.STOKES_DIM           = 1;
  Q.USE_RAW_ATMOSPHERE   = 0;
  Q.CLOUDBOX_DO          = 0;
  %
  Q.ABSORPTION           = 'OnTheFly';
  Q.ABS_LINESHAPE        = 'Voigt_Kuntz6';
  Q.ABS_LINESHAPE_CUTOFF = -1;
  Q.ABS_LINESHAPE_FACTOR = 'quadratic'; 
  %
  Q.R_GEOID              = constants( 'EARTH_RADIUS' );
  %
  Q.SENSOR_POS           = Q.R_GEOID + G.PLATFORM_Z;
  %
  Q.J_DO                 = 1;
  Q.J                    = qartsJacobian;

  %- Line data
  %
  Q.ABS_LINES            = G.ABS_LINES;
  Q.ABS_LINES_FORMAT     = G.ABS_LINES_FORMAT;
    
  %- Surface and atmosphere
  %
  Q.Z_SURFACE            = G.SURFACE_Z;

  %- RT variables
  %
  Q.PPATH_LMAX           = 200;
  Q.PPATH_STEP_AGENDA    = { 'ppath_stepGeometric' };
  %
  if G.CBGR
    Q.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'MatrixCBR( iy, stokes_dim, f_grid )' };
  else
    Q.IY_SPACE_AGENDA = { 'Ignore(rte_los)',  'Ignore(rte_pos)', ...
                          'nelemGet(nrows,f_grid)', 'Copy(ncols,stokes_dim)', ...
                          'MatrixSetConstant(iy,nrows,ncols,0)' };
  end
  
  %- Add species
  %
  pvalues = [];
  %
  for i = 1 : length( G.SPECIES )
    if G.SPECIES(i).RETRIEVE
      Q = qarts_abs_species( Q, {G.SPECIES(i).TAG{:}}, 0, 1, [], [], ...
                             {G.SPECIES(1).GRID}, G.SPECIES(i).UNIT );
      Sx = covmat_append( Sx, G.SPECIES(1).SX );
      pvalues = [ pvalues qarts_get(G.SPECIES(1).GRID) ];
    else
      Q = qarts_abs_species( Q, {G.SPECIES(i).TAG} );
    end
  end
  
  %- P_GRID
  %
  % Create by merge all calculation and retrievals grids, with points closer
  % than 50 m removed.
  %
  Q.P_GRID = unique( pvalues );
  Q.P_GRID = pow10( gridthinning( log10(Q.P_GRID),50/16e3) ); 
  Q.P_GRID = Q.P_GRID(end:-1:1);

  %- Sensor related stuff
  %
  Q.Y_UNIT         = G.Y_UNIT;
  Q.ANTENNA_DIM    = 1;
  Q.MBLOCK_ZA_GRID = 0;
  %
  S                = qartsSensor;
  S.SENSOR_NORM    = 1;
  do_sensor        = 0;
  %
  if G.BACKEND_DO
    do_sensor                  = 1;        
    Q.F_GRID                   = G.F_GRID;
    S.F_BACKEND                = G.F_BACKEND;
    S.BACKEND_CHANNEL_RESPONSE = G.BACKEND_CHANNEL_RESPONSE;
  else
    Q.F_GRID                   = G.F_BACKEND;
  end
  %
  if ~do_sensor
    Q.SENSOR_DO = 0;
  else
    Q.SENSOR_DO       = 1;
    Q.SENSOR_RESPONSE = S;
    Q = arts_sensor( Q, workfolder );
  end
  
  % Polyfit
  %
  if G.POLYFIT_DO
    l = G.POLYFIT_ORDER + 1;
    if length(G.POLYFIT_SI) ~= l
      error('Length of *G.POLYFIT_SI* must be G.POLYFIT_ORDER + 1.');
    end
    %
    Q.J.POLYFIT.DO         = 1;
    Q.J.POLYFIT.POLY_ORDER = G.POLYFIT_ORDER;
    %
    Sx = covmat_append( Sx, spdiags(vec2col(G.POLYFIT_SI).^2,0,l,l) );
  end
return



% Creates observation error matrix, Se
%
function Se = createSe( G, tnoise_si )

  n    = length( tnoise_si );
  nf   = length( G.F_BACKEND );
  cset = qarts_isset( G.TNOISE_C );
  
  if n ~= 1  & n ~= nf
    error( 'Length of *tnoise_si* must be 1 or match *G.F_BACKEND*.' );
  end
  
  if n == 1
    if cset
      Se = (tnoise_si^2) .* G.TNOISE_C;
    else
      Se = spdiags( repmat(tnoise^2,nf,1), 0, nf, nf );
    end
  else
    if cset
      [i,j,s] = find( G.TNOISE_C );
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
function empty_y = checkY( G, Y )

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
      if length([Y(:).y]) ~= length(G.F_BACKEND)
        error( sprintf(['Length of spectrum %d does not match length of ' ...
                        '*G.F_BACKEND*'], i ) );
      end
    end
    empty_y = 0;
  end
return



% Jump to next measurement
%
% y is set to Y(i) if spectrum is empty
%
function [Q,Ythis] = nextMeasurement( G, Q, Y, i )

  Ythis = Y(i);
  
  %- Observation direction
  %
  Q.SENSOR_LOS = Ythis.zenith_angle;

  %- Position set?
  %
  if ~isfield( Ythis, 'latitude' ),  Ythis.latitude  = G.PLATFORM_LAT; end
  if ~isfield( Ythis, 'longitude' ), Ythis.longitude = G.PLATFORM_LON; end  
  
  %- Non mandatory time data
  %
  if ~isfield( Ythis, 'hour' ),   Ythis.hour = 12;  end
  if ~isfield( Ythis, 'minute' ), Ythis.minute = 0; end
  if ~isfield( Ythis, 'second' ), Ythis.second = 0; end

  %- Create atmospheric fields
  %
  Q.VMR_FIELD = zeros( length(Q.ABS_SPECIES), length(Q.P_GRID), 1, 1 );
  %
  h2o = [];
  %
  for i = 1 : length(Q.ABS_SPECIES) 
    Q.VMR_FIELD(i,:,1,1) = clmtlgy_interp( ...
                           G.ATMDATA_D, G.SPECIES(i).ATMDATA, Q.P_GRID, ...
                           Ythis.latitude, Ythis.longitude, ...
                           Ythis.year, Ythis.month, Ythis.day, ...
                           Ythis.hour, Ythis.minute, Ythis.second );
    if isempty(h2o)
      species = arts_tgs2species( Q.ABS_SPECIES{i}{1} );
      if strcmp( species, 'H2O' )
        h2o = Q.VMR_FIELD(i,1,1,1);
      end
    end
  end
  %
  Q.T_FIELD = clmtlgy_interp( G.ATMDATA_D, G.T.ATMDATA, Q.P_GRID, ...
                           Ythis.latitude, Ythis.longitude, ...
                           Ythis.year, Ythis.month, Ythis.day, ...
                           Ythis.hour, Ythis.minute, Ythis.second ); 
  %
  Q.Z_FIELD = pt2z( Q.P_GRID, Q.T_FIELD, h2o, Ythis.hse_p, Ythis.hse_z, ...
                                                              Ythis.latitude );
return



% Fill output structure
%
function P = fillP( P, G, Q, Ythis, R, xa, X )

  i = length(P) + 1;

  % Position and time 
  P(i).laitude   = Ythis.latitude;
  P(i).longitude = Ythis.longitude;
  P(i).year      = Ythis.year;
  P(i).month     = Ythis.month;
  P(i).month     = Ythis.month;
  P(i).day       = Ythis.day;
  P(i).hour      = Ythis.hour;
  P(i).minute    = Ythis.minute;
  P(i).second    = Ythis.second;
 
  % Retrieval diagnostics 
  if G.OEM_LINEAR 
    P(i).converged = X.converged;
  end 
  P(i).cost   = X.cost;
  P(i).cost_x = X.cost_x;
  P(i).cost_y = X.cost_y;
  %  
  if G.OUT_A
    P(i).A   = X.A;
  end

  % Spectra
  if G.OUT_Y
    P(i).f   = G.F_BACKEND;
    P(i).y   = Ythis.y;
    P(i).yf  = X.yf;
  end
 
  % PTZ (a priori or forward model parameters)
  if G.OUT_PTZ
    P(i).p = vec2col( Q.P_GRID );
    P(i).t = Q.T_FIELD;
    P(i).z = Q.Z_FIELD;
  end

  % Retrieval quantities
  %
  ispecies = 0;
  tdone    = 0;
  %
  for i = 1 : length(R.jq)

    ind      = R.ji{i}{1} : R.ji{i}{2};
    
    if strcmp( R.jq{i}.maintag, 'Abs. species' )
      %
      ispecies = ispecies + 1;
      s        = sprintf( 'species%d', ispecies );
      %
      if strcmp( Q.J.ABS_SPECIES(i).UNIT, 'rel' )
        fac = R.x_vmr0(ind);
      else
        fac = ones( length(pgrid), 1 );
      end
      %
      P(i).([s,'_name'])  = R.jq{i}.subtag;
      P(i).([s,'_p'])     = vec2col( Q.J.ABS_SPECIES(ispecies).GRID1 );
      P(i).([s,'_x'])     = fac .* X.x(ind);
      P(i).([s,'_xa'])    = fac .* xa(ind);
      P(i).([s,'_e'])     = fac .* X.e(ind);
      P(i).([s,'_eo'])    = fac .* X.eo(ind);
      P(i).([s,'_es'])    = fac .* X.es(ind);
    
    else
      error( sprintf( 'Unknown retrieval quantity: %s', R.jq{i}.maintag ) );
    end
    
  end
  
return