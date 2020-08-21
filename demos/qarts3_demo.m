% QARTS3_DEMO   A simple demonstration of Qarts3
%
%    Gives an example on basic usage of Qarts. All agendas are defined in
%    the file (agendas.arts not used).
%
%    The example simulated Odin-SMR observations around 501 GHz, but 
%    with a simplified set-up. 
%
%    The script has been kept as similar as possible to *qarts_demo* and can
%    thus be an help to understand the differences between Qarts and Qarts3.
%
% FORMAT   [Q,f,y] = qarts3_demo( [ ztan ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
% OPT   ztan       Tangent altitude. Default is 30 km.

% 2020-08-18 Patrick Eriksson

function [Q,f,y] = qarts3_demo( varargin )
%
[ztan] = optargs( varargin, { 30e3 } );


%= Init Q structures
%
Q  = qarts3;
%
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };


%= De-activate parts not used
%
Q.SCATTERING_DO         = false;
Q.J_DO                  = false;
  

%= Some basic settings
%
Q.output_file_format    = 'ascii';


%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM        = 1;
%
Q.p_grid                = z2p_simple( [0:500:45e3 46e3:1e3:95e3]' );
%
arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                            'Fascod', 'tropical', 'tropical' );
Q.RAW_ATM_EXPAND_1D     = false;
%
Q.wind_u_field          = [];
Q.wind_v_field          = [];
Q.wind_w_field          = [];
Q.mag_u_field           = [];
Q.mag_v_field           = [];
Q.mag_w_field           = [];
%
Q.refellipsoid          = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE             = { 'Arts2{', 'Extract( z_surface, z_field, 0 )', '}' };


%= To enforce detailed hydrostatic equilibrium 
%
% This demands that a geographical position is specified, through LAT/LON_TRUE.
%
Q.HSE.ON                = true;
Q.HSE.P                 = Q.p_grid(1);
Q.HSE.ACCURACY          = 1;
%
Q.lat_true              = 15;
Q.lon_true              = -30;


%= Absorption species
%
Q.ABS_SPECIES(1).TAG{1} = 'ClO';
Q.ABS_SPECIES(2).TAG    = { 'O3' };   % Note the different way to set TAG!
Q.ABS_SPECIES(3).TAG{1} = 'N2O';
Q.ABS_SPECIES(4).TAG{1} = 'H2O-*-490e9-510e9';   % Some local lines not in PWR98
Q.ABS_SPECIES(4).TAG{2} = 'H2O-PWR98';
Q.ABS_SPECIES(5).TAG{1} = 'N2-SelfContStandardType';


%= Calculation of absorption
%
Q.ABSORPTION            = 'OnTheFly';  % A simple, but slow, option!
Q.ABS_LINES_FORMAT      = 'ARTSCAT';
Q.ABS_LINES             = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_LINESHAPE         = 'VP';
Q.ABS_LINESHAPE_CUTOFF  = -1;
Q.ABS_LINESHAPE_FACTOR  = 'VVH';


%= Set RTE variables (refraction is here neglected)
%
Q.iy_main_agenda        = { 'ppathCalc', 'iyEmissionStandard' };
Q.iy_space_agenda       = { 'Ignore(rtp_pos)', 'Ignore(rtp_los)', ...
                            'MatrixCBR(iy,stokes_dim,f_grid)' };
Q.surface_rtprop_agenda = { 'Ignore(rtp_pos)', 'Ignore(rtp_los)', ...
                           ['InterpAtmFieldToPosition(out=surface_skin_t,', ...
                                                         'field=t_field)'], ...
                            'surfaceBlackbody' };
Q.iy_surface_agenda     = { 'SurfaceDummy', 'iySurfaceRtpropAgenda' };
Q.iy_aux_vars           = [];
%
Q.ppath_lmax            = 10e3;
Q.ppath_step_agenda     = { 'Ignore(t_field)', 'Ignore(vmr_field)', ... 
                            'Ignore(f_grid)', ... 
                            'Ignore(ppath_lraytrace)', 'ppath_stepGeometric' };
Q.ppath_agenda          = { 'Ignore(rte_pos2)', 'ppathStepByStep' };
%
Q.stokes_dim            = 1;
Q.iy_unit                = 'RJBT';
%
zplat                   = 600e3;
Q.sensor_pos            = zplat;
Q.sensor_los            = geomztan2za( Q.refellipsoid(1), zplat, ztan );
Q.transmitter_pos       = [];

  
%= Sensor
%
Q.f_grid                = linspace( 501.18e9, 501.58e9, 201 )';
% Simple example, either no sensor at all or just only including a narrow
% antenna pattern.
%
if 0
  Q.SENSOR_DO           = false;
else    
  Q.SENSOR_DO           = true;
  Q.antenna_dim         = 1;
  Q.mblock_dlos_grid    = [-0.04:0.02:0.04]';
  %
  H                     = qartsSensor;
  H.SENSOR_NORM         = true;
  H.ANTENNA_DO          = true;
  H.ANTENNA_DLOS        = 0;
  H.ANTENNA_RESPONSE    = fullfile( atmlab_example_data, 'antenna.xml' );
  %
  Q.SENSOR              = H;
end


%= Specify calculations and output
%
Q.WSMS_AT_END = { 'yCalc', '<OUTPUT> y' };


if nargout == 1
  return
end


%= Calculate
%
U = qarts3_run( Q, [], 'All', false );
%
y = U.y;
f = Q.f_grid;


%= Plot
%
if ~nargout
  plot( f/1e9, y, 'LineWidth', 2 );
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
end

