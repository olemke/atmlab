% QARTS_DEMO   A simple demonstration of Qarts
%
%    Gives an example on basic usage of Qarts. No include files are used, beside
%    absorption model data, and all settings are done inside the file. 
%
%    The example simulated Odin-SMR observations around 501 GHz, but 
%    with a simplified set-up. 
%
% FORMAT   [Q,f,y] = qarts_demo( [ ztan ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
% OPT   ztan       Tangent altitude. Default is 30 km.

% 2008-05-27   Updated to ARTS2 by Patrick Eriksson.
% 2007-08-21   Cleaned and updated by Patrick Eriksson.
% 2005-01-26   Sensor part added by Mattias Ekstrom.
% 2004-??-??   Created by Patrick Eriksson.


function [Q,f,y] = qarts_demo( varargin )
%
[ztan] = optargs( varargin, { 30e3 } );


%= Init Q structures
%
Q  = qarts;


%= De-activate parts not used
%
Q.CLOUDBOX_DO           = false;
Q.J_DO                  = false;
  

%= Some basic settings
%
Q.OUTPUT_FILE_FORMAT    = 'ascii';


%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM        = 1;
%
Q.P_GRID                = z2p_simple( [0:500:45e3 46e3:1e3:100e3]' );
%
arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.RAW_ATM_EXPAND_1D     = false;
%
Q.WIND_U_FIELD          = [];
Q.WIND_V_FIELD          = [];
Q.WIND_W_FIELD          = [];
Q.MAG_U_FIELD           = [];
Q.MAG_V_FIELD           = [];
Q.MAG_W_FIELD           = [];
Q.EDENSITY_FIELD        = [];
%
Q.REFELLIPSOID          = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE             = 500;


%= To enforce detailed hydrostatic equilibrium 
%
% This demands that a geographical position is specified, through LAT/LON_TRUE.
%
Q.HSE.ON                = true;
Q.HSE.P                 = Q.P_GRID(1);
Q.HSE.ACCURACY          = 1;
%
Q.LAT_TRUE              = 15;
Q.LON_TRUE              = -30;


%= Absorption
%
Q.ABS_SPECIES(1).TAG{1} = 'ClO';
Q.ABS_SPECIES(2).TAG    = { 'O3' };   % Note the different way to set TAG!
Q.ABS_SPECIES(3).TAG{1} = 'N2O';
Q.ABS_SPECIES(4).TAG{1} = 'H2O-*-490e9-510e9';   % Some local lines not in PWR98
Q.ABS_SPECIES(4).TAG{2} = 'H2O-PWR98';
Q.ABS_SPECIES(5).TAG{1} = 'N2-SelfContStandardType';
%
Q.ABSORPTION            = 'OnTheFly';  % A simple, but slow, option!
% abs_n2 is set below
Q.ABS_LINES_FORMAT      = 'Arts';
Q.ABS_LINES             = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_LINESHAPE         = 'Voigt_Kuntz6';
Q.ABS_LINESHAPE_CUTOFF  = -1;
Q.ABS_LINESHAPE_FACTOR  = 'VVH';
%
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'continua.arts' ) };


%= Various basic settings
%
Q.WSMS_AT_START{end+1}  = 'VectorSet(abs_n2,[0.7808])';
Q.WSMS_AT_START{end+1}  = 'AgendaSet(g0_agenda){';
Q.WSMS_AT_START{end+1}  = '  Ignore(lon)';
Q.WSMS_AT_START{end+1}  = '  g0Earth }';
Q.WSMS_AT_START{end+1}  = 'NumericSet(molarmass_dry_air,28.966)';


%= Set RTE variables (refraction is here neglected)
%
Q.IY_CLEARSKY_AGENDA    = { 'iyEmissionStandardClearsky' };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiationPlanck' };
Q.IY_SPACE_AGENDA       = { 'Ignore(rte_pos)', 'Ignore(rte_los)', ...
                            'MatrixCBR(iy,stokes_dim,f_grid)' };
Q.SURFACE_RTPROP_AGENDA = { 'Ignore(rte_pos)', 'Ignore(rte_los)', ...
                           ['InterpAtmFieldToRtePos(surface_skin_t,',...
                            'atmosphere_dim, p_grid, lat_grid,', ...
                            'lon_grid, z_field, rte_pos, t_field)'], ...
                            'surfaceBlackbody' };
Q.IY_SURFACE_AGENDA    = { 'iySurfaceRtpropAgenda' };
%
Q.YCALC_WSMS            = { 'yCalc' };
%
Q.PPATH_LMAX            = 20e3;
Q.PPATH_STEP_AGENDA     = { 'Ignore(t_field)', 'Ignore(vmr_field)', ... 
                            'Ignore(edensity_field)', 'Ignore(f_index)', ... 
                            'ppath_stepGeometric' };
Q.PPATH_AGENDA          = { 'Ignore(mblock_index)', 'ppathStepByStep', ...
                            'Touch(rte_los)' };
Q.WSMS_AT_START{end+1}  = 'FlagOff( ppath_inside_cloudbox_do )';
%
Q.STOKES_DIM            = 1;
Q.Y_UNIT                = 'RJBT';
%
zplat                   = 600e3;
Q.SENSOR_POS            = zplat;
Q.SENSOR_LOS            = geomztan2za( Q.REFELLIPSOID(1), zplat, ztan );

  
%= Sensor
%
Q.F_GRID                = linspace( 501.18e9, 501.58e9, 201 )';
%
% Simple example, only including a narrow antenna pattern.
%
if 1   % Commit only with 1 here, to make *make_check* to work
  Q.SENSOR_DO           = false;
else
  H                     = qartsSensor;
  %
  H.SENSOR_NORM         = true;
  %
  Q.ANTENNA_DIM         = 1;
  Q.MBLOCK_ZA_GRID      = [-0.04:0.02:0.04]';
  H.ANTENNA_LOS         = 0;
  H.ANTENNA_RESPONSE    = fullfile( atmlab_example_data, 'antenna.xml' );
  %
  Q.SENSOR_DO           = true;
  Q.SENSOR_RESPONSE     = H;
end


if nargout == 1
  return
end


%= Calculate spectrum/spectra
%
[y,ydata] = arts_y( Q );
%
f = ydata.f;


%= Plot
%
if ~nargout
  plot( Q.F_GRID/1e9, y, 'LineWidth', 2 );
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
end

