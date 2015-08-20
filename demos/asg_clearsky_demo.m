function asg_clearsky_demo

% This is a demonstration of basic usage of the ArtsSceneGen functions
%
% A 3-dimensional varying atmospheric state is created.
% The atmospheric state consists of fields of:
% H2O, O2, N2, temperature, altitude,  
% surface pressure, and surface altitude.
% These variables are stored in atmdata or surfdata format. 
% The sources to the state are ECMWF and fascod data.
% The atmospheric fields are slightly perturbed.
%
% Spectra around the 183 GHz water vapour line are simulated, for a number of
% positions along a hypothetical orbit over the atmospheric domain. The spectra
% are for 35 deg out of nadir.

  
%-------------------------------------------------------
%------------ Basic settings ---------------------------
%-------------------------------------------------------
f_grid   = 183.31e9 + symgrid( [ 0, 1, 1.8, 3, 4.5, 7 ] )'*1e9;
p_grid   = vec2col( z2p_simple( [-1e3:500:30e3] ) );
lat_grid = vec2col( [-8 : 8] );
lon_grid = vec2col( [-8 : 8] );
mjd      = date2mjd( 2014, 8, 8, 1 );
grids    = { p_grid, lat_grid, lon_grid, mjd };



% Common settings for "disturbances" (TYPE and SI set below)
%
RND.FORMAT    = 'param';
RND.SEPERABLE = true;
RND.CCO       = 0.01;               % Cut-off for correlation values 
RND.DATALIMS  = [0];                % Do not allow negative values
RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
RND.CL1_GRID1 = [1100e2 10e2 1e-3];    
RND.CFUN2     = 'lin';              % Linear correlation function for lat-dim
RND.CL2       = 0.5;                % Corr. length 0.5 deg everywhere
RND.CFUN3     = 'lin';              % Linear correlation function for lon-dim
RND.CL3       = 0.5;                % Corr. length 0.5 deg everywhere



%-------------------------------------------------------
%------------ Import of data ---------------------------
%-------------------------------------------------------

%This is a demonstration how to import data to atmdata or 
%surfdata structures from various sources - fascod and ecmwf

fascod_data_path = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', ...
                                    'Earth', 'Fascod', 'tropical' );


ecmwf            = false;
%
% this option means that no ecmwf data from chalmers will be used,
% if set to true, h2o, o3, temperature, and surface pressure will
% imported from chalmers ecmwf data
% 
if ecmwf
  % Some initial stuff to make use the ECMWF at GEM.
  % Search for ecmwf-files 6 hours around specified mjd. 
  ecmwf_files    = find_ecmwf_files( mjd - 0.25, mjd + 0.25);
  % extract data from ECMWF files within the below defined limits
  lat_limits     = [ lat_grid(1)-1, lat_grid(end)+1 ];
  lon_limits     = [ lon_grid(1)-1, lon_grid(end)+1 ];
end


% H2O, from ECMWF or fascod
%
if ecmwf;
  G{1}           = ecmwf2atmdata( ecmwf_files, 'H2O' , p_grid, ...
                                                   lat_limits, lon_limits);
else
  datafile       = fullfile( fascod_data_path, 'tropical.H2O.xml' );
  G{1}           = gf_artsxml( datafile, 'H2O', 'vmr_field' );
end
%
i_h2o            = length( G );



% O2, from fascod 
%
datafile         = fullfile(fascod_data_path, 'tropical.O2.xml');
G{end+1}         = gf_artsxml(datafile, 'O2' , 'vmr_field');
i_o2             = length( G );



% N2, set to fixed value  (0.781)
%
G{end+1}         = atmdata_scalar(0.781);
G{end}.NAME      = 'N2';
G{end}.DATA_NAME = 'Volume mixing ratio';
G{end}.DATA_UNIT = '-';
i_n2             = length( G );


% Temperature, from ECMWF or fascod
%
if ecmwf;
  G{end+1}       = ecmwf2atmdata( ecmwf_files, 'Temperature', p_grid, ...
                                                 lat_limits, lon_limits );
else
  datafile       = fullfile( fascod_data_path, 'tropical.t.xml' );
  G{end+1}       = gf_artsxml( datafile, 'temperature' , 't_field' );
end
%
i_t              = length( G );



% surface elevation, set to fixed scalar value (0)
%
G{end+1}         = surfdata_scalar(0);
G{end}.NAME      = 'Surface elevation';
G{end}.DATA_NAME = 'Altitude';
G{end}.DATA_UNIT = 'm';
%
i_z0             = length( G );



% surface pressure, from ECMWF or set to scalar value
%
if ecmwf
  G{end+1}         = ecmwf2surfdata( ecmwf_files, 'Surface pressure', ...
                                                   lat_limits, lon_limits);
else
  G{end+1}         = surfdata_empty(2);
  G{end}.NAME      = 'Surface pressure';
  G{end}.SOURCE    = 'Set in demo script';
  G{end}.DATA_NAME = 'Pressure';
  G{end}.DATA_UNIT = 'Pa';
  G{end}.DATA      = repmat( 1013e2, length(lat_grid), length(lon_grid) );
  G{end}.GRID1     = lat_grid;
  G{end}.GRID2     = lon_grid;
end
%
i_p0               = length( G );



% surface skin temperature
%
% Obtained by interpolating t_field.
%
G{end+1}         = surfdata_empty(2);
G{end}.NAME      = 'Surface skin temperature';
G{end}.SOURCE    = 'Set in demo script';
G{end}.DATA_NAME = 'Temperature';
G{end}.DATA_UNIT = 'K';
G{end}.DATA      = zeros( length(lat_grid), length(lon_grid) );
G{end}.GRID1     = lat_grid;
G{end}.GRID2     = lon_grid;
% Here we need two version depending if t_field is 1D or 3D
% 1D:
if size( G{i_t}.DATA, 2 ) == 1
  for i = 1 : length(lat_grid)
    for j = 1 : length(lon_grid)
      G{end}.DATA(i,j) = interpp( G{i_t}.GRID1, G{i_t}.DATA, ...
                                                G{i_p0}.DATA(i,j) );
    end
  end  
% 3D:
else
  for i = 1 : length(lat_grid)
    for j = 1 : length(lon_grid)
      G{end}.DATA(i,j) = interpp( G{i_t}.GRID1, G{i_t}.DATA(:,i,j), ...
                                                G{i_p0}.DATA(i,j) );
    end
  end
end



%------------------------------------------------------------------
%----- Merge and modify imported data -----------------------------
%------------------------------------------------------------------

% Regrid data on common grids
%
[G] = asg_regrid( G, grids );


% Disturbe the temperature field
%
RND.TYPE     = 'abs';              % Absolute disturbance
RND.SI       = 2;                  % 1 K 
G{i_t}       = atmdata_rndmz_by_covar( G{i_t}, RND );


% Disturb the H2O field
%
RND.TYPE     = 'rel';            % Relative disturbances as default
RND.SI       = 0.3;              % 30 %
G{i_h2o}     = atmdata_rndmz_by_covar( G{i_h2o}, RND );


% Create an altitude field based on hydrostat
%
G{end+1}     = asg_hydrostat( G{i_t}, G{i_h2o}, G{i_p0}, G{i_z0} );
i_z          = length( G );



%------------------------------------------------------------------
%------------- Surface-RT-settings --------------------------------
%------------------------------------------------------------------
  

in_angle    = vec2col( [0:10:90] );     % incidence angles
stokes      = vec2col( [1, 2] );        % stokes element
t_grid      = vec2col( [250:10:310] );
dza_down    = -5 + 10*randn(1);         % perturbation parameter see below


% specify surface rt-properties: 'surface_reflectivity' or 'surface_refractive_index'

% you can use one of the six options below

% surf=1: scalar reflectivity (scalar)
% surf=2: vector reflectivity (frequency variation)
% surf=3: matrix reflectivity (frequency, incidence angle, latitude, longitude)
% surf=4: matrix reflectivity (frequency, polarisation, polarisation, incidence angle, latitude, longitude)
% surf=5: surface_complex_refr_index (frequency, temperature, complex) 
% surf=6: surface_complex_refr_index (frequency, temperature, complex, latitude, longitude)
%
% In this demo ARTS will be setup to simulate specular reflection from a flat
% surface for the specified surface properties, in a modified way. To take into
% account of non-specular scattering in the ARTS simulations, we perturb the
% directions for which to calculate downwelling radiation when considering a
% surface reflection. The ARTS surface_los variable calculated by e.g. the ARTS
% method surfaceFlatScalarReflectivity will be scaled by dza_down.

surf = 6;
switch surf;

  case 1
    % specify a scalar reflectivity value
    G{end+1}    = surfrtdata_empty( 'surface_reflectivity', 0 );
    G{end}.DATA = 0.3;
    % randomize surface reflectivity data
    si          = 0.05; %standard deviation
    G{end}.DATA = G{end}.DATA + randn(1)*si;

  case 2
    % specify a reflectivity vector
    G{end+1}     = surfrtdata_empty( 'surface_reflectivity', 1 );
    G{end}.GRID1 = f_grid;
    G{end}.DATA  = 0.3*ones( size(f_grid));
    %randomize surface reflectivity data
    si           = 0.05; %standard deviation
    S            = si^2*eye(length(f_grid));    % covmat without correlation
    G{end}.DATA  = randmvar_normal2( G{end}.DATA, S, 1 );

  case 3
    %specify a reflectivity matrix
    G{end+1}     = surfrtdata_empty('surface_reflectivity',4);
    G{end}.GRID1 = f_grid;
    G{end}.GRID2 = in_angle;
    G{end}.GRID3 = lat_grid;
    G{end}.GRID4 = lon_grid;
    G{end}.DATA  = 0.3*ones( length(f_grid), length(in_angle), ...
                             length(lat_grid), length(lon_grid) );
 
  case 4
    %specify a reflectivity matrix 
    G{end+1}     = surfrtdata_empty('surface_reflectivity',6);
    G{end}.GRID1 = f_grid;
    G{end}.GRID2 = stokes;
    G{end}.GRID3 = stokes;
    G{end}.GRID4 = in_angle;
    G{end}.GRID5 = lat_grid;
    G{end}.GRID6 = lon_grid;
    G{end}.DATA  = 0.3*ones( length(f_grid), length(stokes), ...
                     length(stokes), length(in_angle), ...
                     length(lat_grid), length(lon_grid) );

  case 5
    % use refractive index of water
    G{end+1}     = surfrtdata_empty( 'surface_refractive_index', 3 );
    G{end}.GRID1 = f_grid;
    G{end}.GRID2 = t_grid;
    G{end}.GRID3 = {'real','imag'}';
    G{end}.DATA  = zeros( length(G{end}.GRID1), ...
                          length(G{end}.GRID2), ...
                          length(G{end}.GRID3) );
    for i=1:size(G{end}.DATA,1)
      for j=1:size(G{end}.DATA,2)
        n = sqrt(eps_water_liebe93( G{end}.GRID1(i), G{end}.GRID2(j)));
        G{end}.DATA(i,j,1) = real(n);
        G{end}.DATA(i,j,2) = imag(n);
      end
    end

  case 6
    % use refractive index of water with a possibility to add lat/lon variation
    G{end+1}     = surfrtdata_empty( 'surface_refractive_index', 5 );
    G{end}.GRID1 = f_grid;
    G{end}.GRID2 = t_grid;
    G{end}.GRID3 = {'real','imag'}';
    G{end}.GRID4 = lat_grid;
    G{end}.GRID5 = lon_grid;
    G{end}.DATA  = zeros( length(G{end}.GRID1), ...
                          length(G{end}.GRID2), ...
                          length(G{end}.GRID3), ...
                          length(G{end}.GRID4), ...
                          length(G{end}.GRID5) ); 
    for i=1:size(G{end}.DATA,1)
      for j=1:size(G{end}.DATA,2)
        n = sqrt(eps_water_liebe93( G{end}.GRID1(i), G{end}.GRID2(j)));
        for k=1:size(G{end}.DATA,4)
          for l=1:size(G{end}.DATA,5)
            G{end}.DATA(i,j,1,k,l) = real(n);
            G{end}.DATA(i,j,2,k,l) = imag(n);
         end
       end
     end
   end
  
end
%
G{end}.DZA_DOWN = dza_down;
i_surfrt        = length( G );



%----------------------------------------------------------------------------
%------------QARTS-RT-SETTINGS----------------------------------------------
%--------------------------------------------------------------------------

% Set ARTS absoprtion properties to atmospheric species
%
G{i_h2o}.PROPS{1} = 'H2O-PWR98';
G{i_o2}.PROPS{1}  = 'O2-PWR93';
G{i_n2}.PROPS{1}  = 'N2-SelfContStandardType';


% Create a workfolder
%  
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


% Set basic parts of Qarts structure
%
Q                 = qarts;
%
Q.INCLUDES        = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                      fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                      fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                      fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };
%
Q.P_GRID          = grids{1};
Q.LAT_GRID        = grids{2};
Q.LON_GRID        = grids{3};
Q.LAT_TRUE        = grids{2};
Q.LON_TRUE        = grids{3};
Q.F_GRID          = f_grid;  
Q.STOKES_DIM      = 2;
Q.ATMOSPHERE_DIM  = 3;
Q.CLOUDBOX_DO     = false;
Q.J_DO            = false;
Q.SENSOR_DO       = false;
%
% Agendas:
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA          = { 'ppath_step_agenda__GeometricPath'    };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiation_agenda__Planck'  };
Q.IY_SPACE_AGENDA            = { 'iy_space_agenda__CosmicBackground'   };
Q.IY_SURFACE_AGENDA          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA             = { 'iy_main_agenda__Emission'            };
%
Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
 
  
% Transfer the atmospheric and surface fields
% to the Q structure
%
Q = asg2q(G, Q, workfolder);


%
% Absorption is here precalculated. 
%
Q.ABS_LINES_FORMAT       = 'None';
Q.ABS_NLS                = G{i_h2o}.PROPS;
%
Q                        = qarts_abstable( Q, 8, 30, ...
                                                 [0.05 0.2 0.5 1 3 10 50]' );
Q.ABS_LOOKUP             = arts_abstable( Q, workfolder );        
%                                                     
Q.ABSORPTION             = 'LoadTable';



%= Set RTE variables (refraction is here neglected)
%
Q.YCALC_WSMS  = { 'yCalc' };
%
Q.PPATH_LMAX  = 200;
Q.IY_UNIT     = 'RJBT';
%
zplat         = 600e3;
ny            = 5;
Q.SENSOR_POS  = [ repmat(zplat,ny,1), linspace( -3.5, 3.5, ny )', ...
                                      linspace( -1.0, 1.0, ny )' ];
%
Q.SENSOR_LOS  = repmat( [ 145, 85 ], size(Q.SENSOR_POS,1), 1);


%- Calll ARTS and repack y
%
y = arts_y( Q, workfolder );
%
Y = reshape( y(1:Q.STOKES_DIM:end), length(Q.F_GRID), ny );


plot( Q.F_GRID/1e9, Y )
xlabel( 'Frequency' )
ylabel( 'Tb [K]' )


