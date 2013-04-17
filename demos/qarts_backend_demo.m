% QARTS_BACKEND_DEMO   Example on how to introduce a passband filter backend
%
%    A simple simulation of a ground-based temperature radiometer, having
%    passbbands of different widths.
%
% FORMAT   [f,y] = qarts_backend_demo( zplat, za )
%        
% OUT   f          Centre frequency of passbands.
%       y          Simulated brightness temperature (RJTB)
% IN    zplat      Platform altitude.
%       za         Zenith angle.

% 2013-04-17   Created, Patrick Eriksson.

function [f,y] = qarts_backend_demo(zplat,za)

  
%= Atmlab settings
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
%
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
fascod = fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod' );

  
%= Init Q structures
%
Q  = qarts;
%
Q.INCLUDES               = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                             fullfile( 'ARTS_INCLUDES', 'continua.arts' )};


%= Species
%
Q.ABS_SPECIES(1).TAG{1} = 'N2-SelfContStandardType';;
Q.ABS_SPECIES(2).TAG{1} = 'H2O-PWR98';
Q.ABS_SPECIES(3).TAG{1} = 'O2-PWR93';


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM         = 1;
%
Q.P_GRID                 = z2p_simple( [-100:250:50e3]' );
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'atmosphere', ...
                                              'fascod', 'midlatitude-summer' );
Q.RAW_ATM_EXPAND_1D     = false;
%
Q.R_GEOID               = constants( 'EARTH_RADIUS' );
Q.Z_SURFACE             = 0;


%= Absorption
%
Q.ABS_LINES_FORMAT       = 'none';
%                                                     
Q.ABSORPTION             = 'OnTheFly';


%= Various
%
Q.CLOUDBOX_DO       = false;
Q.J_DO              = false;
%
Q.STOKES_DIM        = 1;
Q.PPATH_LMAX        = -1;
%
Q.YCALC_WSMS        = { 'yCalc' };
%
Q.Y_UNIT            = 'RJBT';


%= Define spectrometer passbands
%
fc                  = 1e9 * [ 51.26 52.28 53.86 54.94 56.66 57.3 58.0 ]';
df                  = 1e6 * [   230   230   230   230   600 1000 2000 ]';


%= Init sensor definition
%
Q.SENSOR_POS        = Q.R_GEOID + zplat;
Q.SENSOR_LOS        = za;    
%
H                   = qartsSensor;
H.SENSOR_NORM       = true;
H.ANTENNA_DO        = false;


%= Include spectrometer
%
H.BACKEND_DO        = true;
H.F_BACKEND         = fc;
%
B.name              = 'Spectrometer channel response function';
B.gridnames         = {'Frequency'};
B.dataname          = 'Response';
B.data              = [1 1];
%
% Here we need to define one response for each channel, but only the
% width differs
for i = 1 : length(df)
  B.grids  = { df(i)/2*[-1 1] };
  H.BACKEND_CHANNEL_RESPONSE{i} = B;
end


%= Frequency grid 
%
Q.F_GRID            = linspace( fc(1)-df(1)*0.51, fc(end)+df(end)*0.51, 100 )';


%= One option to manage with a shorter F_GRID is to use "filling", but make
%  very careful tests before starting to use it:
%
%H.FILL_FGRID        = [ 4 5 ];


%= Finalise sensor definition
%
Q.SENSOR_RESPONSE   = H;
Q.SENSOR_DO         = true;



%= Calculate spectrum/spectra
%
[y,ydata] = arts_y( Q );
%
f = ydata.f;
