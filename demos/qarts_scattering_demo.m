% QARTS_SCATTERING_DEMO  Demonstration of scattering calculations by Qarts
%
%   ARTS has two modules for performing scattering calculations: DOIT and
%   MC. The DOIT method is implemented for both 1D and 3D, but is only
%   recommended for 1D. MC is only implemented for 3D. This function
%   runs a simple scenario with DOIT-1D or MC. 
%
%   The 1D scenario used for DOIT is expanded to 3D for MC. The cloud is then
%   given a rectangular shape (in lat and lon). The 1D cloud values are applied
%   inside a range of [-1.5,-1.5] degrees, in both latitude and longitude.
%   This extended by a linear transition to clear sky conditions over 0.5
%   degrees. That is, a perfect match between DOIT and MC can not be
%   expected as the "3D cloud" has a smaller extension than the 1D one.
%
% FORMAT [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo( ztan, do_mc, mc_err )
%
%  OUT   Q          Qarts setting structure.
%        f          Frequency grid.
%        ztan       Set of tangent altitudes used.
%        y_c        Calcualted clearsky radiances [RJ BT].
%        y          Calculated cloudy randiances  [RJ BT].
%        dy         Error estimate. Only valid for MC.
% OPT    ztan       Tangent altitudes. Default is [7 10 13] km.
%        do_mc      Flag to run MC instead of DOIT. Default is 0.
%        mc_err     Target calculation accuracy for MC, in K. Deafult is 5K.

% 2007-07-27  Extended to also handle MC by Patrick Eriksson.
% 2005-06-13  Created by Claudia Emde


function [Q,f,ztan,y_c,y,dy] = qarts_scattering_demo( ztan, do_mc, mc_err )

%- Set default values
%
ztan_DEFAULT   = [7 10 13]*1e3;
do_mc_DEFAULT  = 0;
mc_err_DEFAULT = 5;
%
set_defaults;



%= Init Q structure
%
Q  = qarts;


%= Overall settings
%
Q.CLOUDBOX_DO       = 0;
Q.J_DO              = 0;
Q.SENSOR_DO         = 0;
%
Q.INCLUDES          = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'continua.arts' )};


%= General part
%
f                   = linspace( 501.18e9, 501.58e9, 3 );
Q.F_GRID            = f;
Q.STOKES_DIM        = 2;
%
Q.ABS_SPECIES{1}{1} = 'ClO';
Q.ABS_SPECIES{2}{1} = 'O3';
Q.ABS_SPECIES{3}{1} = 'N2O';
Q.ABS_SPECIES{4}{1} = 'H2O-*-490e9-510e9';   % Some local lines not in PWR98
Q.ABS_SPECIES{4}{2} = 'H2O-PWR98';
Q.ABS_SPECIES{5}{1} = 'N2-SelfContStandardType';


%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.USE_RAW_ATMOSPHERE  = 1;
Q.RAW_ATM_EXPAND_1D   = 0;
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
%
Q.R_GEOID             = constants( 'EARTH_RADIUS' );
Q.Z_SURFACE           = 500;


%= Absorption
%
Q.ABS_LINES_FORMAT = 'Arts';
Q.ABS_LINES        = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_NLS          = [];
%
Q                  = qarts_abstable( Q );


%= Set RTE variables
%
Q.WSMS_BEFORE_RTE    = { 'atm_checkedCalc' };
Q.YCALC_WSMS         = { 'yCalc' };
%
Q.PPATH_LMAX        = 5e3;
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric' };
Q.Y_UNIT            = 'RJBT';
%
zplat        = 600e3;
sensor_pos   = Q.R_GEOID + zplat;
Q.SENSOR_POS = repmat( sensor_pos, length(ztan), 1 );
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, ztan )';



% Calculate clearsky
%
y_c = arts_y( Q );



%= Setting structure for cloudbox and scattering solution method
%
C = qartsCloudbox;


%- Define 1D cloudbox and particles

C.LIMITS = [ 7e3 14e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = [200 270];   % MC does not accept a single temperature


% Create scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
rfr_index = zeros( length(Q.F_GRID), length(T_grid) );
%
for i = 1 : length(T_grid)     % Note .' below. We do not want to conjugate
  rfr_index(:,i) = sqrt(eps_ice_matzler06( Q.F_GRID, T_grid(i) ) ).';
end


% Scattering angles
theta = 0:10:180;
% Particle size [m]
r = 50e-6;
% ice mass content
imc = 0.005*1e-3;
% cloud altitude
alt = [10e3 13e3];

% Calculate scattering data using Mie
C.SCAT_DATA{1} = mie_scat_data( Q.F_GRID,  T_grid, rfr_index, theta, r );

% Calculate a pnd field for a homogeneous cloud
C.PND_FIELD{1} = box_pnd_mono_size_1d( alt, imc, r );


% Set up scattering method

%- Agenda used by both DOIT and MC
%
C.OPT_PROP_GAS_AGENDA = { 'ext_matInit', 'abs_vecInit', 'ext_matAddGas', ...
                                                        'abs_vecAddGas' };

if do_mc

  %- Expand to 3D
  Q.ATMOSPHERE_DIM                = 3;
  Q.RAW_ATM_EXPAND_1D             = 1;
  Q.LAT_GRID                      = -15:5:15;
  Q.LON_GRID                      = -15:5:15;
  %  
  Q.SENSOR_POS                    = repmat( Q.SENSOR_POS, 1, 3 );
  Q.SENSOR_POS(:,2)               = -23;
  Q.SENSOR_POS(:,3)               = 0;
  Q.SENSOR_LOS                    = repmat( Q.SENSOR_LOS, 1, 2 );
  Q.SENSOR_LOS(:,2)               = 0;
  %
  csize                           = 1;
  C.LIMITS                        = [ C.LIMITS csize*[-2 2 -2 2] ];
  C.PND_FIELD{1}.grids{2}         = [ -90 csize*[-2 -1.5 1.5 2] 90 ];
  C.PND_FIELD{1}.grids{3}         = C.PND_FIELD{1}.grids{2};
  p                               = C.PND_FIELD{1}.data;
  C.PND_FIELD{1}.data             = zeros( length( C.PND_FIELD{1}.grids{1} ),...
                                           length( C.PND_FIELD{1}.grids{2} ),...
                                           length( C.PND_FIELD{1}.grids{3} ) );
  C.PND_FIELD{1}.data(:,3:4,3:4)  = repmat(p,[1 2 2]);

  %- MC variables
  C.METHOD                        = 'MC';
  %
  Q.IY_CLEARSKY_AGENDA            = { 'iyMC' };    
  %
  C.METHOD_PRMTRS.STD_ERR         = mc_err;
  C.METHOD_PRMTRS.MAX_TIME        = -1;
  C.METHOD_PRMTRS.MAX_ITER        = -1;
  C.METHOD_PRMTRS.Z_FIELD_IS_1D   = Q.RAW_ATM_EXPAND_1D;
  %
else
  %
  C.METHOD                        = 'DOIT';
  % Angular grids
  C.METHOD_PRMTRS.N_ZA_GRID       =  19;
  C.METHOD_PRMTRS.N_AA_GRID       =  10;
  C.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile(atmlab_example_data, ...
                                                           'doit_za_grid.xml');
  C.METHOD_PRMTRS.EPSILON         = [0.1 0.01 0.01 0.01];
  C.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'linear';
  C.METHOD_PRMTRS.ALL_F           = 0;
  %
  C.OPT_PROP_PART_AGENDA = { 'ext_matInit', 'abs_vecInit', 'ext_matAddPart', ...
                                                         'abs_vecAddPart' };
  C.SPT_CALC_AGENDA = { 'opt_prop_sptFromMonoData' };
end



%- Activate cloudbox
%
Q.CLOUDBOX_DO = 1;
Q.CLOUDBOX    = C;



% Calculate radiances with scattering
%
[y,ydata,dy] = arts_y( Q );


return
