% QARTS_DOIT_DEMO  A demonstration of a simple 1D DOIT scattering
%                  calculation
%
% FORMAT [Q,f,y] = qarts_doit_demo( [ztan] )
%
%  OUT   Q          Qarts setting structure.
%        f          Frequency grid.
%        y_c        Calcualted clearsky radiances [RJ BT].
%        y          Calculated cloudy randiances  [RJ BT].
% OPT    ztan       Tangent altitudes (can be a vector). 
%
% 2005-06-13  Created by Claudia Emde

function [Q,f,y_c,y] = qarts_doit_demo( ztan)

% Set default
% Since in DOIT the whole radiation field is calculated, one can
% calculate several tangent altitudes at the same time
ztan_DEFAULT = [3 6 9 12]*1e3; 
atmdim_DEFAULT = 1;
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
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );


%= Spectroscopy
%
Q.GAS_SPECIES{1}{1} = 'O3';
Q.GAS_SPECIES{2}{1} = 'H2O';
Q.GAS_SPECIES{2}{2} = 'H2O-MPM89';
Q.GAS_SPECIES{3}{1} = 'N2-SelfContStandardType';
%
f = linspace( 501.18e9, 501.58e9, 3);
Q.F_GRID            = f; 
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
Q.IY_SURFACE_AGENDA =  { 'NumericSet(surface_skin_t){290.}',...
      'surfaceBlackbody{}', 'surfaceCalc{}'}
%
Q.IY_SPACE_AGENDA = { 'Copy(iy,i_space){}' };
Q.PRE_RTE_WSMS    = { 'MatrixCBR(i_space,f_grid){}' };
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{5e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
sensor_pos = Q.R_GEOID + zplat;
Q.SENSOR_POS = ones(length(ztan),1).*sensor_pos; 
Q.SENSOR_LOS =  geomztan2za( Q.R_GEOID, zplat, ztan )';
%

% Calculate clearsky
y_c = arts_y( Q );

% Scattering
%
H=create_tmpfolder;

C.METHOD                        = 'DOIT';
% Angular grids
C.METHOD_PRMTRS.N_ZA_GRID       =  19;
C.METHOD_PRMTRS.N_AA_GRID       =  10;
C.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile(atmlab_example_data, 'doit_za_grid.xml');
C.METHOD_PRMTRS.EPSILON         = [0.1] % 0.01 0.01 0.01];
%
C.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'linear';
%
C.LIMITS = [ 7e3 14e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = 250;

% Creare scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
for f_i = 1:length(Q.F_GRID)
  rfr_index(f_i,1) = sqrt(epsice(T_grid, Q.F_GRID(f_i)*1e-9));
end

% Scattering angles
theta = 0:10:180;
% Particle size [m]
r = 50e-6;
% ice mass content
imc = 0.01*1e-3; 
% cloud altitude
alt = [9e3 12e3]; 

% Calculate scattering data using Mie
scat_data = mie_scat_data(Q.F_GRID,  T_grid, rfr_index, theta, r); 
xmlStore([H,'/scat_data.xml'] , scat_data, 'SingleScatteringData' );
C.SCAT_DATA{1} = [H,'/scat_data.xml'];

% Calculate a pnd field for a homogeneous cloud
pnd_field = box_pnd_mono_size_1d(alt, imc, r);
xmlStore([H,'/pnd_field.xml'] , pnd_field, 'GriddedField3' );
C.PND_FIELD{1} = [H,'/pnd_field.xml'];
%

Q.CLOUDBOX = C;  
%

% Calculate scattered radiances
%
y = arts_y( Q );

delete_tmpfolder(H);

return