% QARTS_DEMO   A simple demonstration of Qarts
%
%    Gives an example on basic usage of Qarts.
%
% FORMAT   [Q,f,y] = qarts_demo( [ ztan ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
% OPT   ztan       Tangent altitude. Default is 30 km.

% 2007-08-21   Cleaned and updated by Patrick Eriksson.
% 2005-01-26   Sensor part added by Mattias Ekstrom.
% 2004-??-??   Created by Patrick Erikssom.


function [Q,f,y] = qarts_demo( ztan )

%= Set defualts
%
ztan_DEFAULT     = 30e3;
%
set_defaults;



%= Init Q structures
%
Q  = qarts;



%= General part
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
%
Q.ABS_SPECIES{1}{1} = 'ClO';
Q.ABS_SPECIES{2}{1} = 'O3';
Q.ABS_SPECIES{3}{1} = 'N2O';
Q.ABS_SPECIES{4}{1} = 'H2O';
Q.ABS_SPECIES{4}{2} = 'H2O-MPM89';
Q.ABS_SPECIES{5}{1} = 'N2-SelfContStandardType';



%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
%
Q.USE_RAW_ATMOSPHERE  = 1;
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
%
Q.Z_SURFACE      = 500;



%= Absorption
%
Q.ABSORPTION       = 'OnTheFly';
Q.ABS_LINES_FORMAT = 'Arts';
Q.ABS_LINES        = fullfile( atmlab_example_data , 'lines501.4' );



%= Set RTE variables
%
Q.STOKES_DIM        = 1;
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{20e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat               = 600e3;
Q.SENSOR_POS        = Q.R_GEOID + zplat;
Q.SENSOR_LOS        = geomztan2za( Q.R_GEOID, zplat, ztan );


  
%= Sensor
%
% Simple example, only including a narrow antenna pattern.
%
H                 = qartsSensor;
%
Q.MBLOCK_ZA_GRID  = [-0.04:0.02:0.04];
H.ANTENNA_LOS     = 0;
H.ANTENNA_DIAGRAM = fullfile( atmlab_example_data, 'antenna.xml' );
%
Q.SENSOR_DO       = 1;
Q.SENSOR_RESPONSE = H;



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

