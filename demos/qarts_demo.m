% QARTS_DEMO   A demonstration of Qarts
%
%    Gives an example on how Qarts can be used.
%
% FORMAT   [Q,f,y,Y] = qarts_demo( [ ztan, do_batch ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
%       Y          Batc spectra
% OPT   ztan       Tangent altitude. Default is 30 km.
%       do_batch   Flag to include batch calculations. Default is false.
%                  Set to true, *Y* will include 3 spectra with random
%                  shift in tangent altitude.

% 2005-05-26   Batch part added by Patrick Eriksson
% 2005-01-26   Sensor part added by Mattias Ekström.
% 2004-??-??   Created by Patrick Erikssom.


function [Q,f,y,Y] = qarts_demo( ztan, do_batch )

%= Set defualts
%
ztan_DEFAULT     = 30e3;
do_batch_DEFAULT = false;
%
set_defaults;


%= Make sure that AMI is in the search path. Needed to read/write ARTS1 files
%
addpath_ami;


%= Init Q structures
%
Q  = qarts;
Q1 = qarts1;
H  = qarts_sensor;


%= Atmosphere
%
Q.ATMOSPHERE_DIM      = 1;
Q.USE_RAW_ATMOSPHERE  = 1;
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                       'fascod', 'subarctic-winter' );
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
Q.P_GRID              = z2p_simple( [200:500:45e3 46e3:1e3:90e3] );


%= Spectroscopy
%
Q.GAS_SPECIES{1}{1} = 'ClO';
Q.GAS_SPECIES{2}{1} = 'O3';
Q.GAS_SPECIES{3}{1} = 'N2O';
Q.GAS_SPECIES{4}{1} = 'H2O';
Q.GAS_SPECIES{4}{2} = 'H2O-MPM89';
Q.GAS_SPECIES{5}{1} = 'N2-SelfContStandardType';
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
Q.F_GRID            = linspace( 501.18e9, 502.4e9, 201 );
Q.STOKES_DIM        = 1;
%
Q1.LINEFORMAT       = 'Arts';
Q1.LINEDATA         = fullfile( atmlab_example_data , 'lines501.4' );


%= Create absorption lookup table by ARTS1
%
Q.GAS_ABS_LOOKUP = arts_abstable_from_arts1( Q, Q1, linspace(-40,40,3) );


%= RTE 
%
Q.Z_SURFACE      = 500;
Q.SURFACE_PROP_AGENDA = ...
   { 'InterpAtmFieldToRteGps(surface_skin_t,t_field){}', ...
     'surfaceFlat{"water-liebe93"}' };
%
%
Q.IY_SPACE_AGENDA = { 'Copy(iy,i_space){}' };
Q.PRE_RTE_WSMS    = { 'MatrixCBR(i_space,f_grid){}' };
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{5e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
Q.SENSOR_POS = Q.R_GEOID + zplat;
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, ztan );


%= Sensor
%
H.MBLOCK_ZA_GRID  = [-0.04:0.01:0.04];
H.ANTENNA_LOS     = 0;
H.ANTENNA_DIAGRAM = fullfile( atmlab_example_data, 'antenna.xml' );
Q.SENSOR_RESPONSE = H;


%= Batch calculations
%
% This example creates 3 spectra with slightly different tangent altitudes
% (selected in a random way).
%
if do_batch
  Q.BATCH              = qarts_batch;
  Q.BATCH.N            = 3;
  Q.BATCH.DATA{1}.WSV  = 'sensor_los'; 
  Q.BATCH.DATA{1}.TYPE = 'Matrix';
  Q.BATCH.DATA{1}.X    = Q.SENSOR_LOS + 0.1*randn(5,1,1);
end

if nargout == 1
  return
end


%= Calculate spectrum/spectra
%
f = Q.F_GRID;
y = arts_y( Q );
%
if do_batch
  Y = arts_batch( Q );
else
  Y = [];
end


%= Plot
%
if ~nargout
  h1 = plot( Q.F_GRID/1e9, y, 'LineWidth', 2 );
  if do_batch
    hold on
    h2=plot( Q.F_GRID/1e9, Y );
    hold off
    legend([h1;h2],'y','Y(1)','Y(2)','Y(3)')
  end 
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
end

