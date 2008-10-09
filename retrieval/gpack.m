function Xa = gpack(G,O,Y)

  
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
[Q,Sx] = createQandSx( G, workfolder );

%- Inverse of Sx
%
% Is fixex and should only be calculated once (to save time)
%
Sxinv = Sx \ speye(size(Sx));




%-----------------------------------------------------------------------------
%- Invert measurements
%-----------------------------------------------------------------------------

for m = 1 : length(Y)
  
  %- Set up data for next measurement
  %
  [Q,y] = nextMeasurement( G, Q, Y, m );

  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    if m == 1
      Xa = y;
    else
      Xa(m) = y;
    end
    Xa(m).y = arts_y( Q, workfolder );
  
  else
    %- Create Se
    %
    Se = createSe( G, Y(m).tnoise_si );

    %- Perform retrieval
    %
    [Qoem,R,xa] = arts_oem_init( Q );
    X           = oem( O, Qoem, R, @arts_oem, Sx, Se, Sxinv, [], xa, y );
    %
    arts_oem( 'clean', R );
    clear Qoem 
    %
    if m == 1
      Xa = X;
    else
      Xa(m) = X;
    end

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
function [Q,Sx] = createQandSx(G,workfolder)

  %- Check if needed atmlab settings are found
  %
  arts_includes = atmlab( 'ARTS_INCLUDES' );
  if isnan( arts_includes )
    error('You need to ARTS_INCLUDES to run this example.');
  end

  %- Init
  Q   = qarts;
  Sx  = [];
  
  %- Hard-coded settings
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
  Q.PPATH_LMAX           = 200;
  Q.PPATH_STEP_AGENDA    = { 'ppath_stepGeometric' };
  %
  Q.SENSOR_POS           = Q.R_GEOID + G.STATION_Z;
  %
  Q.J_DO                 = 1;
  Q.J                    = qartsJacobian;

  %- Line data
  %
  Q.ABS_LINES            = G.ABS_LINES;
  Q.ABS_LINES_FORMAT     = G.ABS_LINES_FORMAT;
    
  %- Surface and atmosphere
  %
  Q.Z_SURFACE            = G.STATION_Z;

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
return



% Extracts atmospheric fields for selected measurement
%
function Q = create_atm_fields( G, Q, hse_p, hse_z, ...
                                       year, month, day, hour, minute, second ) 

  Q.VMR_FIELD = zeros( length(Q.ABS_SPECIES), length(Q.P_GRID), 1, 1 );

  h2o = [];

  for i = 1 : length(Q.ABS_SPECIES) 
    Q.VMR_FIELD(i,:,1,1) = clmtlgy_interp( G.ATMDATA_D, G.SPECIES(i).ATMDATA,...
                                  Q.P_GRID, G.STATION_LAT, G.STATION_LON, ...
                                           year, month, day, hour, minute, 0 );
    if isempty(h2o)
      species = arts_tgs2species(Q.ABS_SPECIES{1}{1});
      if strcmp( species, 'H2O' )
        h2o = Q.VMR_FIELD(i,1,1,1);
      end
    end
  end

  Q.T_FIELD = clmtlgy_interp( G.ATMDATA_D, G.T.ATMDATA, Q.P_GRID, ...
                              G.STATION_LAT, G.STATION_LON, ...
                              year, month, day, hour, minute, 0 );

  Q.Z_FIELD = pt2z( Q.P_GRID, Q.T_FIELD, h2o, hse_p, hse_z, G.STATION_LAT );
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
function [Q,y] = nextMeasurement( G, Q, Y, i )

  %- Observation direction
  %
  Q.SENSOR_LOS = Y(i).zenith_angle;


  %- Create atmospheric / apriori profiles
  %
  if ~isfield( Y, 'hour' ),   hour = 12;  else hour = Y(i).hour;     end
  if ~isfield( Y, 'minute' ), minute = 0; else minute = Y(i).minute; end
  if ~isfield( Y, 'second' ), second = 0; else second = Y(i).second; end
  %
  Q = create_atm_fields( G, Q, Y(i).hse_p, Y(i).hse_z, ...
                       Y(i).year, Y(i).month, Y(i).day, hour, minute, second );  

  %- Set y
  %
  if length( Y.y )
    y = Y.y;
  else
    y = Y(i);
  end
return
