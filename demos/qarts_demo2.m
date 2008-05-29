% QARTS_DEMO   A demonstration of Qarts
%
%    A more advanced example on usage of Qarts (compared to *qarts_demo*).
%
% FORMAT   [Q,f,y] = qarts_demo2( [ ztan, atmdim ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
% OPT   ztan       Tangent altitude. Default is 30 km.
%       atmdim     Atmospheric dimensionality. Default is 1.

% 2008-05-27   Updated to ARTS2 by Patrick Eriksson.
% 2007-08-23   Created by Patrick Eriksson (based qarts_demo).


function [Q,f,y] = qarts_demo2( ztan, atmdim )

  
%= Set defualts
%
atmdim_DEFAULT   = 1;
ztan_DEFAULT     = 30e3;
%
set_defaults;



%= Init Q structures
%
Q  = qarts;


%= Overall settings
%
Q.CLOUDBOX_DO       = 0;
Q.J_DO              = 0;
%
Q.INCLUDES          = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'continua.arts' )};


%= General part
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
Q.STOKES_DIM        = 1;
%
Q.ABS_SPECIES{1}{1} = 'ClO';
Q.ABS_SPECIES{2}{1} = 'O3';
Q.ABS_SPECIES{3}{1} = 'N2O';
Q.ABS_SPECIES{4}{1} = 'H2O-*-490e9-510e9';   % Some local lines not in PWR98
Q.ABS_SPECIES{4}{2} = 'H2O-PWR98';
Q.ABS_SPECIES{5}{1} = 'N2-SelfContStandardType';


%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = atmdim;
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
%
if atmdim == 1
  Q.RAW_ATM_EXPAND_1D = 0;
else
  %
  Q.RAW_ATM_EXPAND_1D = 1;
  Q.LAT_GRID          = -10:10;
  %
  if atmdim == 3
    Q.LON_GRID = -10:10;      
  end
end
%
Q.R_GEOID        = constants( 'EARTH_RADIUS' );
Q.Z_SURFACE      = 500;


%= Load atmospheric and surface variables
%
% This step is here unnecessary. It is just a demonstration for how a 1D
% atmosphere can be expanded by ARTS and obtained fields can be loaded for
% some modification. 
%
Q.USE_RAW_ATMOSPHERE = 0;
%
[Q.T_FIELD,Q.Z_FIELD,Q.VMR_FIELD,Q.R_GEOID,Q.Z_SURFACE] = arts_atmfields( Q );


%= Absorption
%
% Absorption is here precalculated. The look-up table is here loaded (into
% Q.ABS_LOOKUP), which will be followed by a saving of data. This
% unnecessary loading/saving can be avoided by giving *arts_abstable* a
% folder where the look-up can be saved: Q.ABS_LOOKUP = arts_abstable(Q,folder);
%
Q.ABS_LINES_FORMAT = 'Arts';
Q.ABS_LINES        = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_NLS          = [];
%
Q                  = qarts_abstable( Q );
Q.ABS_LOOKUP       = arts_abstable( Q );
%
Q.ABSORPTION       = 'LoadTable';



%= Sensor
%
% Simple example, only including a narrow antenna pattern.
%
% Sensor reponse is here pre-calculated. Considerations around
% loading/saving are identical to absorption, commented above.
%
if 1
  Q.SENSOR_DO = 0;
else
H                 = qartsSensor;
%
Q.MBLOCK_ZA_GRID  = [-0.04:0.02:0.04];
H.ANTENNA_LOS     = 0;
H.ANTENNA_DIAGRAM = fullfile( atmlab_example_data, 'antenna.xml' );
%
Q.SENSOR_DO       = 1;
Q.SENSOR_RESPONSE = H;
%
% Pre-calculation not yet activated as reading of sparse matrices appear 
% not to work.
%
%Q.OUTPUT_FILE_FORMAT = 'ascii';  % Temporary solution until reading of
%                                 % binary sparse works.
Q = arts_sensor( Q );
end


%= Set RTE variables (refraction is here neglected)
%
Q.PPATH_LMAX        = 20e3;
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric' };
Q.Y_UNIT            = 'RJBT';
%
zplat               = 600e3;
Q.SENSOR_POS        = [ Q.R_GEOID(1,1) + zplat, -23, 0 ];
Q.SENSOR_POS        = Q.SENSOR_POS(1:atmdim);
%
Q.SENSOR_LOS        = geomztan2za( Q.R_GEOID(1,1), zplat, ztan );
if atmdim == 3
  Q.SENSOR_LOS      = [ Q.SENSOR_LOS, 5 ];
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

