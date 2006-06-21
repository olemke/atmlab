% QARTS_JACOBIAN_DEMO   A demonstration of Jacobian calculations with Qarts
%
%    See code for how jacobians are defined
%
% FORMAT   [Q,f,y,J,ji] = qarts_jacobian_demo( [ ztan, atmdim ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
%       J          Jacobian
%       ji         Index for each retrieval quantity.
% OPT   ztan       Tangent altitude. Default is 30 km.
%       atmdim     Atmospheric dimensionality. Default is 2.

% 2005-06-16   Created by Patrick Eriksson.


function [Q,f,y,J,ji] = qarts_jacobian_demo( ztan, atmdim )

%= Set defualts
%
ztan_DEFAULT     = 30e3;
atmdim_DEFAULT   = 2;
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
%
Q.JACOBIAN_DO = 1;


%= Atmosphere
%
Q.ATMOSPHERE_DIM      = atmdim;
Q.USE_RAW_ATMOSPHERE  = 1;
if atmdim > 1
  Q.RAW_ATM_EXPAND_1D = 1;
end
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.P_GRID              = z2p_simple( 0:1e3:100e3 );
if atmdim >= 2
  Q.LAT_GRID          = -10:10;  
end


%= Spectroscopy
%
Q.GAS_SPECIES{1}{1}         = 'ClO';
Q.GAS_SPECIES_JAC{1}.DO     = 1;
Q.GAS_SPECIES_JAC{1}.METHOD = 'analytical';
%Q.GAS_SPECIES_JAC{1}.METHOD = 'perturbation';
%Q.GAS_SPECIES_JAC{1}.DX     = 0.01;
Q.GAS_SPECIES_JAC{1}.UNIT   = 'rel';
Q.GAS_SPECIES_JAC{1}.P_GRID = z2p_simple( [11e3:2e3:71e3] );
if atmdim >= 2
  Q.GAS_SPECIES_JAC{1}.LAT_GRID = -5:5;  
end
%
Q.GAS_SPECIES{2}{1}         = 'O3';
Q.GAS_SPECIES_JAC{2}        = Q.GAS_SPECIES_JAC{1};
%
Q.GAS_SPECIES{3}{1}         = 'N2O';
Q.GAS_SPECIES_JAC{3}        = Q.GAS_SPECIES_JAC{1};
Q.GAS_SPECIES{4}{1}         = 'H2O';
Q.GAS_SPECIES{4}{2}         = 'H2O-MPM89';
Q.GAS_SPECIES_JAC{4}        = Q.GAS_SPECIES_JAC{1};
Q.GAS_SPECIES{5}{1}         = 'N2-SelfContStandardType';
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
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
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{10e3}' };
Q.Y_UNIT            = '1';
%
zplat        = 600e3;
Q.SENSOR_POS = Q.R_GEOID + zplat;
if atmdim >= 2
  Q.SENSOR_POS = [ Q.SENSOR_POS -23 ];
end
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, ztan );


if nargout == 1
  return
end


%= Calculate spectrum/spectra
%
f        = Q.F_GRID;
[y,dy,J,jq,ji] = arts_y( Q );


%= Plot
%
if ~nargout
  
  figure(1);
  h1 = plot( f/1e9, y, 'LineWidth', 2 );
  hold on
  h2 = plot( f/1e9,J*ones(size(J,2),1) );
  hold off
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
  legend( [h1 h2], 'Spectrum', 'J\timesones(nx,1)' );

  figure(3);
  i   = 149;
  ind = ji{2}{1}:ji{2}{2};
  z   = p2z_simple( Q.GAS_SPECIES_JAC{2}.P_GRID );
  if atmdim == 1
    plot(full(J(i,ind)),z/1e3);
    xlabel( 'J [K/1]' )
  elseif atmdim == 2
    lat = Q.GAS_SPECIES_JAC{2}.LAT_GRID;
    contourf(lat,z/1e3,reshape(full(J(i,ind)),length(z),length(lat)));
    shading flat
    xlabel( 'Latitude [deg]' )
    ylabel( 'Altitude [km]' )
    title( 'Weighting function for frequency at ozone line centre' );
    colorbar
  end
  ylabel( 'Altitude [km]' )
end

