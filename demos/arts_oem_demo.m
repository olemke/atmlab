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


%= Set-up Q and R structures ==================================================

Q   = qarts;
Q.J = qarts_jacobian;
Q1  = qarts1;
R   = [];

%= Spectroscopy
%
Q = q_abs_species( Q, {'O3'}, 1, 'rel', 'analytical', 0, ...
                                                   z2p_simple( 0e3:1e3:90e3) );
%
R.SX.ABS_SPECIES(1).FORMAT    = 'param'; 
if strcmp( Q.J.ABS_SPECIES(1).UNIT, 'rel' )
  R.SX.ABS_SPECIES(1).SI        = 0.6;
else
  R.SX.ABS_SPECIES(1).SI        = 0.1e-6;
end
R.SX.ABS_SPECIES(1).CCO       = 0.01;  
R.SX.ABS_SPECIES(1).CFUN1     = 'exp';
R.SX.ABS_SPECIES(1).CL1       = 0.25*[1 1];
R.SX.ABS_SPECIES(1).CL1_GRID1 = [1100e2 1e-3];  
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
Q.IY_SPACE_AGENDA = { 'Ignore(rte_los){}', 'Ignore(rte_pos){}', ...
                      'MatrixCBR(iy,f_grid){}', 'MatrixScale(iy,iy){0}' };
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

%============================================================================



%= Create absorption lookup table by ARTS1
%
filename = 'abstable111ghz.xml';
%
if 0
  Q.ABS_LOOKUP = arts_abstable_from_arts1( Q, Q1, linspace(-40,40,3) );
  xmlStore( filename, Q.ABS_LOOKUP, 'GasAbsLookup' );
end
%
Q.ABS_LOOKUP = filename;
  


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
e = si*randn(size(Se,1),1);
%
y = 1.1 * arts_y(Q);


%= OEM
%
O.method  = 'GN';
O.stop_dx = 0.01;
O.maxiter = 10;
%
O.cost    = 1;
O.Xiter   = 1;
O.yf      = 1;
O.J       = 1;
O.A       = 1;
O.S       = 0;
O.So      = 0;
O.Ss      = 0;
O.d       = 0; 
O.do      = 1;
O.ds      = 0;
%
[Qoem,R,Sx,xa] = arts_oem_init( Q, R );
%
[x,P] = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%
arts_oem_init( 'clean', R );
clear Qoem O


z = p2z_simple( Q.J.ABS_SPECIES(1).GRID1 );

keyboard
return
