% SIMPLE_MW_SIMS  Simple simulations of microwave radiances
%
%   The function calculates microwave brightness temperatures as a function
%   of frequency and zenith angle, using the ARTS forward model. Atmospheric
%   scenario is selected by the argument *atm*, and there are five options:
%     'tro' = tropical
%     'mls' = mid-latitude summer
%     'mlw' = mid-latitude winter
%     'sas' = sub-arctic summer 
%     'saw' = sub-arctic winter 
%
%   Default is to calculate absorption using the three following models:
%     N2-SelfContStandardType, O2-PWR98 and H2O-PWR98
%
%   The absorption species can also be specified, by *abs_species*. If this
%   option is used, *hitran_path* must be set. As when using ARTS directly,
%   be careful when using both full absorption models and transitions from
%   HITRAN, to not include some transitions twice. 
%
%   Also down-looking directions are handled. The surface is then treated a
%   perfectly flat (specular reflection), with an adjustable reflection
%   coefficient (*r_surface*). This requires that 'z_surface* is set.
%  
% FORMAT Y = simple_mw_sims(f,za,z_obs,p_grid,atm[,abs_species,hitran_path,
%                                                  z_surface,r_surface,tb_unit])
%
% OUT   Y           Simulated brightness temperatures.
% IN    f           Set of frequencies.
%       za          Set of zenith angles.
%       z_obs       Observation altitude.
%       p_grid      Pressure grid to use. Note that ppath_lmax is set to -1,
%                   and the spacing of this grids affects the calcualtion accuracy.
%       atm         Atmospheric scenario, see above.
% OPT   abs_species Absorption species. Default is {}.
%       hitran_path Path to HIRAN file. Default is [].
%       z_surface   Surface altitude. Default is NaN.
%       r_surface   Surface reflection coefficient. Default is 0.
%       tb_unit     Version of Tb. Default is PlanckBT.

% 2018-04-27   Patrick Eriksson


function Y = simple_mw_sims(f,za,z_obs,p_grid,atm,varargin)
%
[abs_species,hitran_path,z_surface,r_surface,tb_unit] = optargs( varargin, ...
                                                  { {}, [], NaN, 0, 'PlanckBT' } );


%= Expand atm settings
%
switch lower(atm)
 case 'tro'
  atmlong = 'tropical';
 case 'mls'
  atmlong = 'midlatitude-summer';
 case 'mlw'
  atmlong = 'midlatitude-winter';
 case 'sas'
  atmlong = 'subarctic-summer';
 case 'saw'
  atmlong = 'subarctic-winter';
 otherwise
  error( 'Unknown option for *atm*.' );
end
  

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
Q.SENSOR_DO             = false;


%= Define agendas
%
Q.PPATH_AGENDA          = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA     = { 'ppath_step_agenda__GeometricPath'    };
Q.IY_SPACE_AGENDA       = { 'iy_space_agenda__CosmicBackground'   };
Q.IY_SURFACE_AGENDA     = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA        = { 'iy_main_agenda__Emission'            };
Q.SURFACE_RTPROP_AGENDA = { ...
 'surface_rtprop_agenda__Specular_NoPol_ReflFix_SurfTFromt_field' };

%= Define atmosphere
%
Q.ATMOSPHERE_DIM        = 1;
Q.P_GRID                = p_grid;
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                    'Fascod', atmlong, atmlong );
Q.RAW_ATM_EXPAND_1D     = false;


%= Absorption species
%
%
if isempty( abs_species )
  Q.ABS_SPECIES(1).TAG{1} = 'N2-SelfContStandardType';
  Q.ABS_SPECIES(2).TAG{1} = 'O2-PWR98';
  Q.ABS_SPECIES(3).TAG{1} = 'H2O-PWR98';
  Q.ABS_LINES_FORMAT      = 'None';
else
  for i = 1 : length( abs_species )
    Q.ABS_SPECIES(i).TAG{1} = abs_species{i};
  end
  if isempty( hitran_path )
    error( 'When abs species is set, also *hitran_path* must be set.' );
  end
  Q.ABS_LINES           = hitran_path;
  Q.ABS_LINES_FORMAT    = 'Hitran';
  df                    = 5e9;
  Q.ABS_LINES_FLIMS     = [ max(0.1e9,f(1)-df), f(end)+df ];
end


%= Calculation of absorption
%
%
Q.ABSORPTION            = 'OnTheFly';


%= Surface variables
%
if all( za <= 90 )
  Q.Z_SURFACE           = z_obs;
else
  if isnan(z_surface)
    error( 'If any *za* > 90, *z_surface* must be set.' );
  end
  Q.Z_SURFACE           = z_surface;
end
%
Q.WSMS_AT_START{end+1}  = sprintf( ...
    'VectorSet( surface_scalar_reflectivity, [%.4f] )', r_surface );


%= Some radiative transfer settings
%
Q.STOKES_DIM            = 1;
Q.IY_UNIT               = tb_unit;
Q.PPATH_LMAX            = -1;
Q.F_GRID                = vec2col( f );
Q.YCALC_WSMS            = { 'yCalc' };


%= Measurement geometry
%
Q.SENSOR_POS            = repmat( z_obs, length(za), 1 );
Q.SENSOR_LOS            = vec2col( za );


%= Calculate and repack
%
y = arts_y( Q );
%
Y = reshape( y, length(f), length(za) );