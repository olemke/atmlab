function gpack(G)

  
%- Create a work folder
%
workfolder = create_tmpfolder;

  
%- Set up fixed part of Q (for qarts) and Sx
%
[Q,Sx] = createQandSx( G, workfolder );


%- Loop measurements

za = 70;

year   = 2007;
month  = 3;
day    = 4;
hour   = 4;
minute = 12;

station_p = 100e2;


%- Observation direction
%
%
Q.SENSOR_LOS = za;


%- Create atmospheric / apriori profiles
%
Q = create_atm_fields( G, Q, station_p, year, month, day, hour, minute );  

  
[y,ydata] = arts_y( Q, workfolder );

plot( ydata.f/1e9, y )
keyboard

%- Remove work folder
%
delete_tmpfolder( workfolder );

return


  
%------------------------------------------------------------------------------
%- Internal sub-functions
%------------------------------------------------------------------------------

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
      pvalues = [ pvalues G.SPECIES(1).GRID ];
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
  Q.F_GRID         = G.F_GRID;
  Q.ANTENNA_DIM    = 1;
  Q.MBLOCK_ZA_GRID = 0;
  %
  S                = qartsSensor;
  S.SENSOR_NORM    = 1;
  do_sensor        = 0;
  %
  if G.BACKEND_DO
    do_sensor                  = 1;        
    S.F_BACKEND                = G.F_BACKEND;
    S.BACKEND_CHANNEL_RESPONSE = G.BACKEND_CHANNEL_RESPONSE;
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
function Q = create_atm_fields( G, Q, station_p, year, month, day, hour, minute) 

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

  Q.Z_FIELD = pt2z( Q.P_GRID, Q.T_FIELD, h2o, station_p, G.STATION_Z, ...
                                                                G.STATION_LAT );
return

