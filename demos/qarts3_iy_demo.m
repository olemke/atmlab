% QARTS3_IY_DEMO   Doing an iyCalc calculation with Qarts3
%
%    A simple demonstration of how to use Qarts3 for peforming a
%    monochromatic pencil beam calculations using ARTS' iyCalc method, and
%    how to use iy_aux and ppath also outputted by iyCalc.
%
%    See the code for details. If the function is called with no output
%    arguments, a set of figures are produced with sample results.
%
%    The script has been kept as similar as possible to *qarts_iy_demo* and can
%    thus be an help to understand the differences between Qarts and Qarts3.
%
% FORMAT   [iy,iy_aux,ppath] = qarts3_iy_demo
%        
% OUT      iy      As the ARTS WSV with the same name.
%          iy_aux  As the ARTS WSV with the same name.
%          ppath   As the ARTS WSV with the same name.

% 2020-08-20   Created by Patrick Eriksson.

function [iy,iy_aux,ppath] = qarts3_iy_demo

  
%- Atmlab settings
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
arts_includes     = atmlab( 'ARTS_INCLUDES' );
if isnan( arts_xmldata_path ) 
  error( 'You need to set ARTS_XMLDATA_PATH to run this exmaple.' );
end
if isnan( arts_includes )
  error( 'You need to ARTS_INCLUDES to run this example.' );
end                                                      
%
fascod = fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod' );


%- Init Q
%
Q = qarts3;
%
Q.INCLUDES            = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };
Q.ATMOSPHERE_DIM      = 1;
Q.stokes_dim          = 1;
Q.J_DO                = false;
Q.SCATTERING_DO       = false;


%= Define agendas
%
% Here we do it by using the predefined agenda templates 
%   (found in arts/controlfiles/general/agendas.arts)
% This works only if the pre-defined agenda is names following the pattern:
%   name_of_agenda__(Something)
%
Q.ppath_agenda               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.ppath_step_agenda          = { 'ppath_step_agenda__GeometricPath'    };
Q.iy_space_agenda            = { 'iy_space_agenda__CosmicBackground'   };
Q.iy_surface_agenda          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.iy_main_agenda             = { 'iy_main_agenda__Emission'            };


%= Absorption
%
Q.ABS_SPECIES(1).TAG{1} = 'O3';
Q.ABS_SPECIES(2).TAG{1} = 'H2O-PWR98';
Q.ABS_SPECIES(3).TAG{1} = 'N2-SelfContStandardType';
Q.ABS_SPECIES(4).TAG{1} = 'O2-PWR98';
%
Q.ABSORPTION            = 'OnTheFly';  % A simple, but slow, option!
Q.ABS_LINES_FORMAT      = 'ARTSCAT';
Q.ABS_LINES           = fullfile( atmlab_example_data, 'o3line111ghz' );
Q.ABS_LINESHAPE         = 'VP';
Q.ABS_LINESHAPE_CUTOFF  = -1;
Q.ABS_LINESHAPE_FACTOR  = 'VVH';



%= Define atmosphere and surface
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


%- Frequency grid
%
Q.f_grid                 = qarts_get( fullfile( atmlab_example_data , ...
                                                'f_grid_111ghz.xml' ) );


%- Radiative transfer
%
Q.iy_unit             = 'RJBT'; 
%
Q.ppath_lmax          = 250;
%
Q.rte_pos2            = [];   % Here a dummy value
%
Q.rte_pos             = 2.3e3;
Q.rte_los             = 70;
%
Q.iy_aux_vars         = { 'Optical depth' };
%
Q.WSMS_AT_END         = { 'iyCalc', '<OUTPUT> iy', '<OUTPUT> iy_aux', ...
                          '<OUTPUT> ppath' };


%- Calculate
%
U = qarts3_run( Q, [], 'All', false );
%
iy     = U.iy;
iy_aux = U.iy_aux;
ppath  = U.ppath;


%- Plot?
%
if nargout == 0
  
  figure(1)
  f = qarts_get( Q.f_grid );
  plot( f/1e9, iy )
  xlabel( 'Frequency [GHz]' );
  ylabel( 'Brightness temperature [K]' );
  title( 'Monochromatic pencil beam spectrum' );

  figure(2)
  plot( f/1e9, iy_aux{1}(:,1,1,end) )
  xlabel( 'Frequency [GHz]' );
  ylabel( 'OPtical depth [-]' );
  title( 'Corresponding optical depths' );
  
  figure(3)
  plot( ppath.pos(:,1)/1e3, ppath.los )
  xlabel( 'Altitude [km]' );
  ylabel( 'Zenith angle [deg]' );
  title( 'Change of zenith angle with height of ppath' );

end


