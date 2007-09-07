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
%       ji         Definition of retrieval quantities.
%       ji         Index for each retrieval quantity.
% OPT   ztan       Tangent altitude. Default is 30 km.
%       atmdim     Atmospheric dimensionality. Default is 2.

% 2005-06-16   Created by Patrick Eriksson.


function [Q,f,y,J,jq,ji] = qarts_jacobian_demo( ztan, atmdim )

%= Set defualts
%
ztan_DEFAULT     = 30e3;
atmdim_DEFAULT   = 2;
%
set_defaults;



%= Init setting structures
%
Q  = qarts;
%
J  = qartsJacobian;



%= Absorption species
%
Q.ABS_SPECIES{1}{1}         = 'ClO';
J.ABS_SPECIES(1).DO         = 1;
J.ABS_SPECIES(1).METHOD     = 'analytical';
%J.ABS_SPECIES(1).METHOD    = 'perturbation';
%J.ABS_SPECIES(1).DX        = 0.01;
J.ABS_SPECIES(1).UNIT       = 'rel';
J.ABS_SPECIES(1).GRID1      = z2p_simple( [11e3:2e3:61e3] );
if atmdim >= 2
  J.ABS_SPECIES(1).GRID2     = -7:0.5:7;  
end
%
Q.ABS_SPECIES{2}{1}         = 'O3';
J.ABS_SPECIES(2)            = J.ABS_SPECIES(1);
%
Q.ABS_SPECIES{3}{1}         = 'N2O';
J.ABS_SPECIES(3)            = J.ABS_SPECIES(1);
Q.ABS_SPECIES{4}{1}         = 'H2O';
%Q.ABS_SPECIES{4}{2}         = 'H2O-MPM89';
J.ABS_SPECIES(4)            = J.ABS_SPECIES(1);



%= Other variables of general part
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
Q.STOKES_DIM        = 1;



%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = atmdim;
%
Q.USE_RAW_ATMOSPHERE  = 1;
if atmdim > 1
  Q.RAW_ATM_EXPAND_1D = 1;
end
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
%
if atmdim >= 2
  Q.LAT_GRID          = -10:10;  
end
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.Z_SURFACE           = 500;



%= Atmosphere
%
Q.USE_RAW_ATMOSPHERE  = 1;
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.P_GRID              = z2p_simple( 0:1e3:100e3 );



%= Absorption
%
Q.ABS_LINES_FORMAT = 'Arts';
Q.ABS_LINES        = fullfile( atmlab_example_data , 'lines501.4' );
%
Q                  = qarts_abstable( Q );



%= Set RTE variables
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{20e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
Q.SENSOR_POS = Q.R_GEOID + zplat;
if atmdim >= 2
  Q.SENSOR_POS = [ Q.SENSOR_POS -23 ];
end
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, ztan );



%= Add jacobian part
%
Q.J_DO = true;
Q.J    = J;



if nargout == 1
  return
end



%= Calculate spectrum/spectra
%
f                    = Q.F_GRID;
[y,ydata,dy,J,jq,ji] = arts_y( Q );



%= Plot
%
if ~nargout

  figure(1);
  h1 = plot( f/1e9, y, 'LineWidth', 2 );
  hold on
  h2 = plot( f/1e9,J*ones(size(J,2),1), 'r--' );
  hold off
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
  legend( [h1 h2], 'Spectrum', 'J\timesones(nx,1)' );

  figure(2);
  i   = 149;
  ind = ji{2}{1}:ji{2}{2};
  z   = p2z_simple( Q.J.ABS_SPECIES(2).GRID1 );
  if atmdim == 1
    plot(full(J(i,ind)),z/1e3);
    xlabel( 'J [K/1]' )
  elseif atmdim == 2
    lat = Q.J.ABS_SPECIES(2).GRID2;
    contourf(lat,z/1e3,reshape(full(J(i,ind)),length(z),length(lat)));
    shading flat
    xlabel( 'Latitude [deg]' )
    ylabel( 'Altitude [km]' )
    title( 'Weighting function for frequency at ozone line centre' );
    colorbar
  end
  ylabel( 'Altitude [km]' )
end
