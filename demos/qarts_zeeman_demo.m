% QARTS_ZEEMAN_DEMO   A demonstration of including Zeeman in Qarts
%
%    Calculates a limb sounding spectrum at 118.75 GHz, with and without
%    activating the Zeeman part.
%
% FORMAT   [f,y0,y] = qarts_zeeman_demo( [ ztan, stokes_rotation ] )
%        
% OUT   f          Frequency grid
%       y0         Calculated spectrum without activating Zeeman.
%       y          Calculated spectrum with Zeeman.
% OPT   ztan       Tangent altitude. Default is 95 km.
%       pol_response    Polarisation response, following codong for ARTS' 
%                       WSV sensor_pol. Default is 5 (which equals V).
%       stokes_rotation As the ARTS WSV with same name. Default is [], which
%                       means that the WSM sensor_responseStokeRotation not
%                       is called at all. A value of 0, will include the
%                       WSM but should not change the result.

% 2013-06-27   Created by Patrick Eriksson.


function [f,y0,y,L2] = qarts_zeeman_demo( varargin )
%
[ztan,pol_response,stokes_rotation] = optargs( varargin, { 95e3, 5, [] } );


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
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };


%= De-activate parts not used
%
Q.CLOUDBOX_DO           = false;
Q.J_DO                  = false;


%= Define agendas
%
% Here we do it by using the predefined agenda templates.
% This works only if the pre-defined agenda is names following the pattern:
%    name_of_agenda__(Something)
%
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA          = { 'ppath_step_agenda__GeometricPath'    };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiation_agenda__Planck'  };
Q.IY_SPACE_AGENDA            = { 'iy_space_agenda__CosmicBackground'   };
Q.IY_SURFACE_AGENDA          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA             = { 'iy_main_agenda__Emission'            };


%= Atmospheric species
%
Q.ABS_SPECIES(1).TAG{1}  = 'O2';
Q.ABS_SPECIES(1).ATMDATA = gf_artsxml( fullfile( fascod, 'subarctic-summer', ...
                            'subarctic-summer.O2.xml' ), 'O2', 'vmr_field' ); 
%
% H2O required for apllication of HSE
Q.ABS_SPECIES(2).TAG{1}  = 'H2O';
Q.ABS_SPECIES(2).ATMDATA = gf_artsxml( fullfile( fascod, 'subarctic-summer', ...
                            'subarctic-summer.H2O.xml' ), 'H2O', 'vmr_field' ); 
  


%= Temperature and geoemtrical altitudes are taken from CIRA86
%
Q.T.ATMDATA    = gf_artsxml( fullfile( arts_xmldata_path, ...
                       'planets', 'Earth', 'CIRA86', 'climatology', ... 
                       'cira86.t.xml' ), 'Temperature', 't_field' );
Q.Z.ATMDATA    = gf_artsxml( fullfile( arts_xmldata_path, ...
                       'planets', 'Earth', 'CIRA86', 'climatology', ... 
                       'cira86.z.xml' ), 'Altitude', 'z_field' );


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM       = 3;
%
Q.P_GRID               = z2p_simple( [-1e3:1e3:120e3]' );
%
Q.LAT_GRID             = [60:2:88]'; 
Q.LON_GRID             = [0:4:40]'; 
%
Q.REFELLIPSOID         = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE            = repmat( 500, length(Q.LAT_GRID), length(Q.LON_GRID));
%
mjd                    = date2mjd( 2008, 2, 15 ); % A dummy date
%
Q.VMR_FIELD            = qarts_vmr_field( Q );
Q.T_FIELD              = qarts_atm_field( Q, 't', mjd );
Q.Z_FIELD              = qarts_atm_field( Q, 'z', mjd );


%= Absorption
%
Q.F_GRID               = 1.187503430e+11 + linspace( -5e6, 5e6, 201 )';
%
Q.ABS_LINES_FORMAT     = 'Hitran';
Q.ABS_LINES            = fullfile( atmlab_example_data , ...
                                              'HITRAN2012_o2line_118GHz.par' );
%
Q.ABS_LINESHAPE        = 'Faddeeva_Algorithm_916';
Q.ABS_LINESHAPE_FACTOR = 'VVH';
Q.ABS_LINESHAPE_CUTOFF = 750e9;
%
Q.ABSORPTION           = 'OnTheFly';


%- Determine altitudes through HSE
%
Q.HSE.ON       = true;
Q.HSE.P        = Q.P_GRID(1);
Q.HSE.ACCURACY = 0.1;


%= Set RTE variables
%
Q.YCALC_WSMS           = { 'yCalc' };
%
Q.STOKES_DIM           = 4;
Q.PPATH_LMAX           = 5e3;
Q.IY_UNIT              = 'RJBT';
%
zplat                  = 600e3;
Q.SENSOR_POS           = [ zplat, 49, 12 ];
%
Q.SENSOR_LOS           = [ geomztan2za(Q.REFELLIPSOID(1),zplat,ztan), 5 ];


%= Make sure magnetic fields are zero
%
Q.MAG_U_FIELD          = [];
Q.MAG_V_FIELD          = [];
Q.MAG_W_FIELD          = [];


%= Sensor responses considered
%
H                      = qartsSensor;
%
H.SENSOR_POL           = { 5 }; 
%
if ~isempty(stokes_rotation)
  H.STOKES_ROTATION      = stokes_rotation;
end
%
H.SENSOR_NORM          = true;
Q.ANTENNA_DIM          = 1;
Q.MBLOCK_DLOS_GRID     = [0];    
Q.SENSOR_DO            = true;
Q.SENSOR_RESPONSE      = H;

  
  
%= Calculate spectrum
%
y0 = arts_y( Q );
%
f = Q.F_GRID;


% Repeat with Zeeman activated
%
magdatafolder  = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', ...
                                                          'Earth', 'IGRF' );

Q.ABS_SPECIES(1).TAG{1}   = 'O2-Z-66';
%
Q.PROPMAT_CLEARSKY_AGENDA = { 'propmat_clearsky_agenda__OnTheFly_Zeeman' };
%
Q.WSMS_AT_START{end+1} = [ 'ReadXML( isotopologue_quantum, "', ...
                    fullfile( atmlab('ARTS_XMLDATA_PATH'), 'spectroscopy',...
                           'QuantumConstants', 'zeeman_constants.xml'), '")' ];
%
Q.MAG_U.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_u.xml.gz' ),...
                                     'Magnetic u-component', 'mag_field' ); 
Q.MAG_V.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_v.xml.gz' ),...
                                     'Magnetic v-component', 'mag_field' ); 
Q.MAG_W.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_w.xml.gz' ),...
                                     'Magnetic w-component', 'mag_field' ); 
% Qpack2 makes this automatically:
Q.MAG_U_FIELD          = qarts_atm_field( Q, 'mag_u', mjd );
Q.MAG_V_FIELD          = qarts_atm_field( Q, 'mag_v', mjd );
Q.MAG_W_FIELD          = qarts_atm_field( Q, 'mag_w', mjd );
%
y = arts_y( Q );
  

%= Plot
%
if ~nargout
  figure(1)
  plot( Q.F_GRID/1e9, y0, Q.F_GRID/1e9, y );
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  legend( 'I without Zeeman', 'I with Zeeman' )
end



%
%
%  Test of retrieval. 
%
%
  
%
% Activate retrieval of all three magnetic field components
% 
Q.MAG_U.RETRIEVE = true;   
Q.MAG_U.L2       = true;
Q.MAG_U.GRIDS    = { Q.P_GRID(1:2:end), mean(Q.LAT_GRID), mean(Q.LON_GRID) };
Q.MAG_U.SX       = covmat1d_from_cfun( Q.MAG_U(1).GRIDS{1}, 10e-6, ...
                                                    'lin', 1, 0.00, @log10 );
%
Q.MAG_V.RETRIEVE = Q.MAG_U.RETRIEVE; 
Q.MAG_V.L2       = Q.MAG_U.L2;      
Q.MAG_V.GRIDS    = Q.MAG_U.GRIDS;
Q.MAG_V.SX       = Q.MAG_U.SX;
%
Q.MAG_W.RETRIEVE = Q.MAG_U.RETRIEVE; 
Q.MAG_W.L2       = Q.MAG_U.L2;      
Q.MAG_W.GRIDS    = Q.MAG_U.GRIDS;
Q.MAG_W.SX       = Q.MAG_U.SX;


%
% Turn off retrieval of ABS_SPECIES and T
%
for i = 1 : length( Q.ABS_SPECIES )
  Q.ABS_SPECIES(i).RETRIEVE = false;
end
Q.T.RETRIEVE = false;


%- Define L2 structure (beside retrieval quantities below)
%
Q.L2_EXTRA     = { 'cost', 'dx', 'xa', 'y', 'yf', 'S', 'So', ...
                   'mresp', 'A', 'e', 'eo', 'es', 'date', 'J' };



%
% Create a Y structure for testing
%  
  
% Init Y
%
Y = qp2_y;

% Set a date
%
Y.YEAR  = 2008;
Y.MONTH = 2;
Y.DAY   = 25;

% Lat / lon
%

% An airborn measurement assumed here
%
Y.Z_PLATFORM = Q.SENSOR_POS(1);
Y.LATITUDE   = Q.SENSOR_POS(2);
Y.LONGITUDE  = Q.SENSOR_POS(3);
Y.ZA         = Q.SENSOR_LOS(1); 
Y.AA         = Q.SENSOR_LOS(2);

% Reference point for hydrostatic equilibrium
%
Y.HSE_P = 100e2;
Y.HSE_Z = 16e3;

% Set backend frequencies
%
Y.F = qarts_get( Q.F_GRID );

% Thermal noise standard deviation
%
Y.TNOISE = 0.5;


% Make new simulation with mag field components constant
%
% We must clear ATMDATA, otherwise qpack will overwrite the mag fields we
% set below
%
Q.MAG_U = rmfield( Q.MAG_U, 'ATMDATA' );
Q.MAG_V = rmfield( Q.MAG_V, 'ATMDATA' );
Q.MAG_W = rmfield( Q.MAG_W, 'ATMDATA' );
%
Q.MAG_U_FIELD(:) = mean( Q.MAG_U_FIELD(:) );
Q.MAG_V_FIELD(:) = mean( Q.MAG_V_FIELD(:) );
Q.MAG_W_FIELD(:) = mean( Q.MAG_W_FIELD(:) );
%
Y.Y = [];
%
Y = qpack2( Q, oem, Y );            % Dummy oem structure OK here 



% Change mag fields, to get a deviating a priori state
%
du = -2e-6;
dv =  5e-6;
dw = -1e-6;
%
Q.MAG_U_FIELD = Q.MAG_U_FIELD + du;
Q.MAG_V_FIELD = Q.MAG_V_FIELD + dv;
Q.MAG_W_FIELD = Q.MAG_W_FIELD + dw;


%- OEM variables
%
O = qp2_l2( Q );         % This ensures that OEM returns the variables needed 
%                          to fill the L2 structure, as defined in Q
O.linear = false;
%
if ~O.linear 
  O.itermethod = 'GN';
  O.stop_dx    = 0.01;
  O.maxiter    = 5;
end


%- Additional Q fields, needed for inversion
%
Q.TNOISE_C = speye( length(Q.F_GRID) );


%- Make inversion
%
L2 = qpack2( Q, O, Y );



%= Plot
%
if ~nargout
  figure(2)
  z = p2z_simple( L2.mag_u_p );
  plot( 1e6*(L2.mag_u_xa-du), z/1e3, 'b', 1e6*L2.mag_u_x, z/1e3, 'b--', ...
        1e6*(L2.mag_v_xa-dv), z/1e3, 'r', 1e6*L2.mag_v_x, z/1e3, 'r--', ...
        1e6*(L2.mag_w_xa-dw), z/1e3, 'k', 1e6*L2.mag_w_x, z/1e3, 'k--' );
  ylabel( 'Approx. altitude [km]' );
  xlabel( 'Magnetic field component [muT]' );
  legend( 'u, true', 'u, retrieved', 'v, true', 'v, retrieved', ...
          'w, true', 'w, retrieved', 'Location', 'South' );
end


