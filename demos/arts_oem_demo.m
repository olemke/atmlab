% ARTS_OEM_DEMO   Demonstration of inversions using ARTS and OEM
%
% FORMAT   arts_oem_demo

% 200x-xx-xx   Created by XXX.

function arts_oem_demo



%= Check if arts-xml-data is found
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
%
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end


%= Make sure that AMI is in the search path. Needed to read/write ARTS1 files
%
addpath_ami;


%= Set-up Q structures =======================================================

Q  = qarts;
Q1 = qarts1;

%= Spectroscopy
%
Q.ABS_SPECIES{1}{1} = 'O3';
%
Q1.LINEFORMAT       = 'Arts';
Q1.LINEDATA         = fullfile( atmlab_example_data , 'o3line111ghz' );


%= Atmosphere
%
Q.ATMOSPHERE_DIM      = 1;
Q.USE_RAW_ATMOSPHERE  = 1;
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                              'fascod', 'midlatitude-winter' );
Q.P_GRID              = z2p_simple( 0:500:90e3 );


%= RTE 
%
Q.Z_SURFACE           = 1e3;
Q.SURFACE_PROP_AGENDA = ...
   { 'InterpAtmFieldToRteGps(surface_skin_t,t_field){}', ...
     'Ignore(rte_los){}','surfaceBlackbody{}' };
%
Q.PRE_RTE_WSMS        = { 'MatrixCBR(i_space,f_grid){}' };
%
Q.PPATH_STEP_AGENDA   = { 'ppath_stepGeometric{', ...
                          '  lmax      = -1', ...
                          '}' };
Q.Y_UNIT              = 'RJ';
%
Q.SENSOR_LOS          = 0;
Q.SENSOR_POS          = Q.R_GEOID + Q.Z_SURFACE;
%
Q.F_GRID              = 1.108360400e+11 + linspace(-320e6,320e6,641);
%
Q.STOKES_DIM        = 1;


%= Jacobian
%
Q.JACOBIAN_DO                 = 1;
Q.ABS_SPECIES_JAC(1).DO       = 1;
Q.ABS_SPECIES_JAC(1).METHOD   = 'analytical';
Q.ABS_SPECIES_JAC(1).UNIT     = 'rel';
Q.ABS_SPECIES_JAC(1).P_GRID   = z2p_simple( 21e3:3e3:66e3 );
%
Q.ABS_SPECIES_SX(1).FORMAT    = 'param'; 
Q.ABS_SPECIES_SX(1).SI        = 1;
Q.ABS_SPECIES_SX(1).CCO       = 0.01;  
Q.ABS_SPECIES_SX(1).CFUN1     = 'exp';
Q.ABS_SPECIES_SX(1).CL1       = 0.25*[1 1];
Q.ABS_SPECIES_SX(1).CL1_GRID1 = [1100e2 1e-3];  

%============================================================================



%= Create absorption lookup table by ARTS1
%
Q.ABS_LOOKUP = arts_abstable_from_arts1( Q, Q1, linspace(-40,40,3) );



%= Create Se
%
si = 0.25;
%
D.FORMAT    = 'param';
D.SI        = si;
D.CCO       = 0;  
D.CFUN1     = 'drc';
%
Se = arts_covmat( 1, D, Q.F_GRID );


%= Measurement
%
y = 1.1 * arts_y(Q);


%= OEM
%
O.yf = 1;
O.A  = 1;
%
[Qoem,R,Sx,xa] = arts_oem_init( Q, [] );
%
[x,P] = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%
arts_oem_init( 'clean', R );
clear Qoem O


keyboard
return
