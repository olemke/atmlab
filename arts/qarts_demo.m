function qarts_demo( ztan )

if nargin == 0
  ztan = 30e3;
end


%= Make sure that AMI is in the search path. Needed to read/write ARTS1 files
%
addpath_ami;


%= Init Q structures
%
Q  = qarts;
Q1 = qarts1;


%= Atmosphere
%
Q.ATMOSPHERE_DIM      = 1;
Q.USE_RAW_ATMOSPHERE  = 1;
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, ...
                        fullfile( 'atmosphere', ...
                        fullfile( 'fascod', 'tropical' ) ) );
Q.P_GRID              = z2p_simple( [0:500:45e3 46e3:1e3:80e3] );


%= Spectroscopy
%
Q.GAS_SPECIES{1}{1} = 'ClO';
Q.GAS_SPECIES{2}{1} = 'O3';
Q.GAS_SPECIES{3}{1} = 'N2O';
Q.GAS_SPECIES{4}{1} = 'H2O';
Q.GAS_SPECIES{4}{2} = 'H2O-MPM89';
Q.GAS_SPECIES{5}{1} = 'N2-SelfContStandardType';
%
Q.F_GRID         = linspace( 501.18e9, 501.58e9, 201 );
Q.STOKES_DIM     = 1;
%
Q1.LINEFORMAT    = 'Arts';
Q1.LINEDATA      = fullfile( atmlab_example_data , 'lines501.4' );
%
Q.OPT_PROP_GAS_AGENDA = { 'ext_matAddGas{}', 'abs_vecAddGas{}' };


%= Create absorption lookup table by ARTS1
%
Q.GAS_ABS_LOOKUP = arts_abstable_from_arts1( Q, Q1, linspace(-40,40,3) );


%= RTE 
%
Q.Z_SURFACE      = 500;
Q.IY_SURFACE_AGENDA = ...
   { 'InterpAtmFieldToRteGps(surface_skin_t,t_field){}', ...
     'surfaceFlat{"water-liebe93"}', 'surfaceCalc{}' };
%
Q.IY_SPACE_AGENDA = { 'Copy(iy,i_space){}' };
Q.PRE_RTE_WSMS    = { 'MatrixCBR(i_space,f_grid){}' };
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{5e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
Q.SENSOR_POS = Q.R_GEOID + zplat;
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, ztan );


%= Calculate spectrum
%
y = arts_y( Q );


%= Plot
%
plot( Q.F_GRID/1e9, y )
xlabel( 'Frequency [GHz]' )
ylabel( 'Brightness temperature [K]' )
title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3 ) );