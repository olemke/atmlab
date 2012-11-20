% Work in progress !!!!

function [y0,yd,ym,ymerror] = qarts_mcdoit_demo( varargin )
%
[mcprec,iwp,dpart,rsurf] = optargs( varargin, { 1, 0.5, 1e-3, 0.1 } );



%= Create a temporary workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );
  
  
%= Init Q structure
%
Q  = qarts;


%= Overall settings
%
Q.CLOUDBOX_DO       = false;
Q.J_DO              = false;
Q.SENSOR_DO         = false;
%
Q.INCLUDES          = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'continua.arts' )};


%= General part
%
Q.F_GRID            = 89e9;
Q.STOKES_DIM        = 4;
%
Q.ABS_SPECIES(1).TAG{1} = 'H2O-PWR98';
Q.ABS_SPECIES(2).TAG{1} = 'N2-SelfContStandardType';
Q.ABS_SPECIES(3).TAG{1} = 'O2-PWR93';


%= Define atmosphere
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [-200:200:10e3 11e3:1e3:25e3] )';
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                     'Fascod', 'midlatitude-winter', 'midlatitude-winter' );
Q.RAW_ATM_EXPAND_1D   = false;


%= Surface
%
Q.REFELLIPSOID        = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE           = 0;
%
R        = zeros( 1, Q.STOKES_DIM, Q.STOKES_DIM ); 
R(1,:,:) = rsurf*eye( Q.STOKES_DIM );

R(1,1,2) = rsurf*0.1; 
R(1,2,1) = rsurf*0.1; 

fname = fullfile(workfolder,'surface_reflectivity.xml');
xmlStore( fname, R, 'Tensor3' );
Q.WSMS_AT_START{1} = sprintf('ReadXML(surface_reflectivity,"%s")',fname);
%
Q.SURFACE_RTPROP_AGENDA{1} = 'specular_losCalc';
Q.SURFACE_RTPROP_AGENDA{2} = 'InterpAtmFieldToRtePos(surface_skin_t,';
Q.SURFACE_RTPROP_AGENDA{3} = '  atmosphere_dim, p_grid, lat_grid,';
Q.SURFACE_RTPROP_AGENDA{4} = '  lon_grid, z_field, rte_pos, t_field )';
Q.SURFACE_RTPROP_AGENDA{5} = 'surfaceFlatReflectivity';


%= Create an absorption table
%
Q.ABS_LINES_FORMAT    = 'none';
%
Q.ABS_NLS             = [];
Q                     = qarts_abstable( Q );
arts_abstable( Q, workfolder );


%= Set RTE variables
%
Q.IY_UNIT             = 'RJBT';
Q.YCALC_WSMS          = { 'sensor_checkedCalc', 'yCalc' };
%
Q.PPATH_LMAX          = 5e3/max([1,iwp/0.5]);
Q.PPATH_LMAX 

%
Q.SENSOR_POS          = 830e3;
Q.SENSOR_LOS          = 145;


% Calculate clearsky
%
y0 = arts_y( Q, workfolder );


%= Setting structure for cloudbox and scattering solution method
%
C               = qartsCloudbox;

%- Define 1D cloudbox and particles

C.LIMITS = [ 1e3 6e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = [240 270];   % MC does not accept a single temperature!


% Create scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
fgrid     = Q.F_GRID + [-1e6,1e6]';  
rfr_index = zeros( length(fgrid), length(T_grid) );
%
for i = 1 : length(T_grid)     % Note .' below. We do not want to conjugate
  rfr_index(:,i) = sqrt(eps_ice_matzler06(fgrid, T_grid(i) ) ).';
end

% Scattering angles
theta = 0:10:180;
% Particle size [m]
r = dpart/2;
% cloud altitude
alt = [3e3 5e3];

% Calculate scattering data using Mie
C.SCAT_DATA{1} = mie_arts_scat_data( fgrid,  T_grid, rfr_index, theta, r );

% Calculate a pnd field for a homogeneous cloud
C.PND_FIELD{1} = box_pnd_mono_size_1d( alt, iwp/diff(alt), r );

% Set up scattering method
%
C.METHOD                        = 'DOIT';
% Need a trick here for setting RJ
Q.IY_UNIT                       = '1';
Q.WSMS_BEFORE_RTE{1}            = 'StringSet(iy_unit,"RJBT")';  
% Angular grids
C.METHOD_PRMTRS.N_ZA_GRID       =  19;
C.METHOD_PRMTRS.N_AA_GRID       =  10;
C.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile( atmlab_example_data, ...
                                                         'doit_za_grid.xml');
C.METHOD_PRMTRS.EPSILON         = [ 0.1 0.01 0.01 0.01 ];
C.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'polynomial';
C.METHOD_PRMTRS.ALL_F           = false;
%
C.OPT_PROP_PART_AGENDA = { 'ext_matInit', 'abs_vecInit', 'ext_matAddPart', ...
                                                         'abs_vecAddPart' };
C.SPT_CALC_AGENDA = { 'opt_prop_sptFromMonoData' };


%- Activate cloudbox
%
Q.CLOUDBOX_DO = true;
Q.CLOUDBOX    = C;


%= DOIT
%
yd = arts_y( Q, workfolder );


%= Expand to 3D
%
latlon_grid = [-80:10:80]';
%
Q.ATMOSPHERE_DIM                = 3;
Q.RAW_ATM_EXPAND_1D             = true;
Q.LAT_GRID                      = latlon_grid;
Q.LON_GRID                      = latlon_grid;
Q.Z_SURFACE                     = repmat( Q.Z_SURFACE, length(latlon_grid),...
                                                       length(latlon_grid) );
%
C.LIMITS                        = [ C.LIMITS [-50 50 -50 50] ];
C.PND_FIELD{1}.grids{2}         = [ -90 -50 -40 40 50 90 ];
C.PND_FIELD{1}.grids{3}         = C.PND_FIELD{1}.grids{2};
p                               = C.PND_FIELD{1}.data;
C.PND_FIELD{1}.data             = zeros( length( C.PND_FIELD{1}.grids{1} ),...
                                         length( C.PND_FIELD{1}.grids{2} ),...
                                         length( C.PND_FIELD{1}.grids{3} ) );
C.PND_FIELD{1}.data(:,3:4,3:4)  = repmat(p,[1 2 2]);
%  
Q.SENSOR_POS(:,2)               = -5;
Q.SENSOR_POS(:,3)               = 1;
Q.SENSOR_LOS(:,2)               = 0;


%- Change settings to fit MC
%
C.METHOD                        = 'MC';
%
C.METHOD_PRMTRS.STD_ERR         = mcprec;
C.METHOD_PRMTRS.MAX_TIME        = -1;
C.METHOD_PRMTRS.MAX_ITER        = -1;
C.METHOD_PRMTRS.MIN_ITER        = 100;
%
Q.CLOUDBOX                      = C;
Q.IY_MAIN_AGENDA                = { 'Ignore( rte_pos2 )', 'iyMC', ...
                                    'Touch(ppath)' };
Q.IY_AUX_VARS                   = { 'Error (uncorrelated)' };
Q.IY_UNIT                       = 'RJBT';
Q.WSMS_BEFORE_RTE               = {};

  
%= MC
%
[ym,ydata,y_aux] = arts_y( Q );
ymerror = y_aux{1};

