% 22 GHz forward modelling
%
% FORMAT y = oi22_y(P,A,O,io[,return_q])
%
% OUT   y    Simulated spectrum
%              or
%       Q    Qarts3 structure parly filled
% IN    P    Project settings structure
%       A    Atmosphere data structure
%       O    Observation data structure
%       io   Index of case in O to do
% OPT   return_q  If set to true, Q is returned insted of y. Default 
%                 is false. If Q returned, Q.WSMS_AT_END is left empty.

% 2021-02-07 Patrick Eriksson


function y = oi22_y(P,A,O,io,return_q)
%
if nargin < 5 | isempty(return_q), return_q = false; end


%- Init Q structures
%
Q  = qarts3;
%
datafiles               = fullfile( folder_of_fun('oi_init'), 'DataFiles' );
%
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                            fullfile( datafiles, 'continua_rttov.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };


%- Position of Onsala
%
Q.lat_true              = 57 + 23/60;
Q.lon_true              = 11 + 55/60;;
z_oso                   = 12;


%- Agendas
%
Q.abs_xsec_agenda       = { 'abs_xsec_agenda__noCIA'              };
Q.propmat_clearsky_agenda = { 'propmat_clearsky_agenda__OnTheFly' };
Q.ppath_agenda          = { 'ppath_agenda__FollowSensorLosPath'   };
Q.ppath_step_agenda     = { 'ppath_step_agenda__GeometricPath'    };
Q.iy_space_agenda       = { 'iy_space_agenda__CosmicBackground'   };
Q.iy_surface_agenda     = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.iy_main_agenda        = { 'iy_main_agenda__Emission'            };


%- Some basic settings
%
Q.output_file_format    = 'ascii';
Q.CHECKS_DO             = 1;
Q.PARTICLES             = [];
%
Q.ATMOSPHERE_DIM        = 1;
Q.stokes_dim            = 1;
Q.iy_unit               = 'RJBT'; 
Q.ppath_lmax            = 1e3;


%- Apply HSE on atmospheric data and set corresponding{ARTS variables
%
z = pt2z( A.p, A.t, A.h2o, O.p(io), z_oso, Q.lat_true );
%
Q.HSE.ON                = true;
Q.HSE.P                 = O.p(io);
Q.HSE.ACCURACY          = 1;


%- Set basic atmosphere and surface
%
Q.p_grid                = A.p;
Q.z_field               = A.z;
Q.t_field               = A.t;
Q.z_surface             = z_oso - 2;


%- Above general, below 22 GHz


%- Absorption species
%
Q.vmr_field              = [A.n2';A.o2';A.h2o'];
%
Q.GAS_SPECIES(1).TAG{1}  = 'N2-SelfContStandardType';
Q.GAS_SPECIES(2).TAG{1}  = 'O2-TRE05';
Q.GAS_SPECIES(3).TAG{1}  = 'H2O,H2O-MPM89';
%
Q.abs_lines              = fullfile( datafiles, ...
                                    'abs_lines_h2o_rttov_below340ghz.xml' );
Q.ABSORPTION{end+1}      = 'abs_lines_per_speciesCreateFromLines';


do_antenna = false;

%- Sensor
%
Q.f_grid                 = oi22_fgrid( O );
Q.sensor_pos             = z_oso;
Q.sensor_los             = 0;
%
Q.sensor_norm            = 1;
Q.antenna_dim            = 1;
if do_antenna
  Q.antenna_dlos         = 90 - [O.high(io); O.low(io)];
  Q.mblock_dlos_grid     = [-10:10:10 55:1:85]';
  Q.antenna_response     = oi22_antenna_response;
else
  Q.mblock_dlos_grid     = 90 - [O.high(io); O.low(io)];
end
%
Q.f_backend                       = O.freq;
Q.backend_channel_response        = oi22_channel_response( O );
%
Q.sensor_response_agenda{1}       = 'sensor_responseInit';
Q.sensor_response_agenda{end+1}   = 'Touch( mblock_dlos_grid )';
if do_antenna
  Q.sensor_response_agenda{end+1} = 'sensor_responseAntenna';
end
Q.sensor_response_agenda{end+1}   = 'sensor_responseBackend';
Q.sensor_response_agenda{end+1}   = 'sensor_responseBeamSwitching';
Q.sensor_response_agenda{end+1}   = 'sensor_checkedCalc';
%
Q.SENSOR{end+1}          = 'timeNow';
Q.SENSOR{end+1}          = 'ArrayOfTimeSetConstant( sensor_time, 1, time )';
Q.SENSOR{end+1}          = 'AgendaExecute( sensor_response_agenda )';
Q.SENSOR{end+1}          = 'sensor_checkedCalc';


%- Calculate?
%
if return_q
  %  
  y = Q;
  %
else
  %
  Q.J                      = [];
  Q.WSMS_AT_END            = { 'yCalc', '<OUTPUT> y' };
  %
  U = qarts3_run( Q, P.workfolder );
  y = U.y;
  %
end