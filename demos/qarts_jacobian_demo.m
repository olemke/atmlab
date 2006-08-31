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
%
J  = qarts_jacobian;


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
Q.ABS_SPECIES{1}{1}         = 'ClO';
J.ABS_SPECIES(1).DO         = 1;
J.ABS_SPECIES(1).METHOD     = 'analytical';
%J.ABS_SPECIES(1).METHOD    = 'perturbation';
%J.ABS_SPECIES(1).DX        = 0.01;
J.ABS_SPECIES(1).UNIT       = 'rel';
J.ABS_SPECIES(1).GRID1      = z2p_simple( [11e3:2e3:71e3] );
if atmdim >= 2
  J.ABS_SPECIES(1).GRID2     = -5:5;  
end
%
Q.ABS_SPECIES{2}{1}         = 'O3';
J.ABS_SPECIES(2)            = J.ABS_SPECIES(1);
%
Q.ABS_SPECIES{3}{1}         = 'N2O';
J.ABS_SPECIES(3)            = J.ABS_SPECIES(1);
Q.ABS_SPECIES{4}{1}         = 'H2O';
Q.ABS_SPECIES{4}{2}         = 'H2O-MPM89';
J.ABS_SPECIES(4)            = J.ABS_SPECIES(1);
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
Q.STOKES_DIM        = 1;
%
Q1.LINEFORMAT       = 'Arts';
Q1.LINEDATA         = fullfile( atmlab_example_data , 'lines501.4' );


%= Create absorption lookup table by ARTS1
%
Q.ABS_LOOKUP = arts_abstable_from_arts1( Q, Q1, linspace(-40,40,3) );


%= RTE 
%
Q.Z_SURFACE      = 500;
Q.SURFACE_PROP_AGENDA = ...
   { 'InterpAtmFieldToRteGps(surface_skin_t,t_field){}', ...
     'surfaceFlat{"water-liebe93"}' };
%
Q.IY_SPACE_AGENDA = { 'Ignore(rte_los){}', 'Ignore(rte_pos){}', ...
                      'MatrixCBR(iy,f_grid){}', 'MatrixScale(iy,iy){0}' };
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{10e3}' };
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
Q.J = J;


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

