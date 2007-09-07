% QARTS_DOIT_DEMO  A demonstration of a simple 1D DOIT scattering
%                  calculation
%
% FORMAT [Q,f,y_c,y] = qarts_doit_demo( [ztan] )
%
%  OUT   Q          Qarts setting structure.
%        f          Frequency grid.
%        y_c        Calcualted clearsky radiances [RJ BT].
%        y          Calculated cloudy randiances  [RJ BT].
% OPT    ztan       Tangent altitudes (can be a vector). 
%
% 2005-06-13  Created by Claudia Emde

function [Q,f,y_c,y,ztan] = qarts_doit_demo( ztan )

% Set default
% Since in DOIT the whole radiation field is calculated, one can
% calculate several tangent altitudes at the same time
ztan_DEFAULT = [3 6 9 12]*1e3; 
%
set_defaults;



%= Init Q structure
%
Q  = qarts;



%= General part
%
f                   = linspace( 501.18e9, 501.58e9, 3 );
Q.F_GRID            = f; 
Q.STOKES_DIM        = 2;
%
Q.ABS_SPECIES{1}{1} = 'O3';
Q.ABS_SPECIES{2}{1} = 'H2O';
Q.ABS_SPECIES{2}{2} = 'H2O-MPM89';
Q.ABS_SPECIES{3}{1} = 'N2-SelfContStandardType';



%= Define atmosphere and surface
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:100e3] );
%
Q.USE_RAW_ATMOSPHERE  = 1;
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
%
Q.Z_SURFACE      = 500;



%= Absorption
%
Q.ABS_LINES_FORMAT = 'Arts';
Q.ABS_LINES        = fullfile( atmlab_example_data , 'lines501.4' );
%
Q                  = qarts_abstable( Q );



%= Set RTE variables
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{5e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
sensor_pos   = Q.R_GEOID + zplat;
Q.SENSOR_POS = ones(length(ztan),1).*sensor_pos; 
Q.SENSOR_LOS =  geomztan2za( Q.R_GEOID, zplat, ztan )';



% Calculate clearsky
%
y_c = arts_y( Q );



% Scattering
%
H=create_tmpfolder;
%
C.METHOD                        = 'DOIT';
% Angular grids
C.METHOD_PRMTRS.N_ZA_GRID       =  19;
C.METHOD_PRMTRS.N_AA_GRID       =  10;
C.METHOD_PRMTRS.ZA_GRID_OPT_FILE = fullfile(atmlab_example_data, ...
                                                           'doit_za_grid.xml');
C.METHOD_PRMTRS.EPSILON         = [0.1 0.01 0.01 0.01];
%
C.METHOD_PRMTRS.SCAT_ZA_INTERP  = 'linear';
C.METHOD_PRMTRS.I_REINIT        = 1;
%
C.LIMITS = [ 7e3 14e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = 250;

% Create scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
rfr_index = sqrt(eps_ice_liebe93( Q.F_GRID, T_grid ) )';


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
Q.CLOUDBOX_DO = 1;
Q.CLOUDBOX    = C;  


% Calculate radiances with scattering
%
y = arts_y( Q );


delete_tmpfolder(H);

return