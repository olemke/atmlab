function Y = test_arts_Olevels


olevels = [0 2 4 0 2 4];
float   = [0 0 0 1 1 1];


%= Make quite
%
verbosity = atmlab( 'VERBOSITY' );
artsverb  = atmlab( 'FMODEL_VERBOSITY' );
%
atmlab( 'VERBOSITY', 0 );
atmlab( 'FMODEL_VERBOSITY', 0 );


Y = [];


for i = 1 : length( olevels )

  reconf( olevels(i), float(i) );

  Q = set_q;

  y = arts_y( Q );

  if i == 1
    y0 = y;
  else
    if float(i)
      s = 'float';
    else
      s = 'double';
    end
    S{i-1} = sprintf( 'O%d, %s : max diff = %.2e\n', ...
                                               olevels(i), s, max(abs(y-y0)) );
  end

  L{i} = int2str(i);

  Y = [Y y];
end


for i = 1 : length( olevels ) - 1
  fprintf( '%s\n', S{i} );
end


clf
plot(Q.F_GRID/1e9,Y-repmat(y0,1,length(olevels)))
xlabel('Frequency [GHz]');
ylabel('Tb diff [K]');
legend(L);


%= Reset verbosities
%
atmlab( 'VERBOSITY', verbosity );
atmlab( 'FMODEL_VERBOSITY', artsverb );


return


%----------------------------------------------------------------------------

function reconf(olevel,float)
  %
  s1 = sprintf( 'export CFLAGS=-O%d;export CXXFLAGS=-O%d;', olevel, olevel );
  %
  if float
    s2 = 'autogen.sh  --with-numeric-type=float';
  else
    s2 = 'autogen.sh';
  end
  system( [ s1, ' ', s2 ] );
  %
  cd src;
  system( 'make clean' );
  system( 'make arts' );
  %
  cd ..;
  %
return


%----------------------------------------------------------------------------

function Q = set_q

%= Init Q structures
%
Q  = qarts;
Q1 = qarts1;
H  = qarts_sensor;

%= Atmosphere
%
Q.ATMOSPHERE_DIM      = 2;
Q.USE_RAW_ATMOSPHERE  = 1;
if Q.ATMOSPHERE_DIM > 1
  Q.RAW_ATM_EXPAND_1D = 1;
end
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'atmosphere', ...
                                                        'fascod', 'tropical' );
Q.P_GRID              = z2p_simple( 0e3:1e3:100e3 );
if Q.ATMOSPHERE_DIM >= 2
  Q.LAT_GRID          = -10:10;  
end


%= Spectroscopy
%
Q.GAS_SPECIES{1}{1}         = 'O3';
Q.GAS_SPECIES_JAC{1}.DO     = 0;
Q.GAS_SPECIES_JAC{1}.METHOD = 'analytical';
Q.GAS_SPECIES_JAC{1}.DX     = 0.01;
Q.GAS_SPECIES_JAC{1}.UNIT   = 'rel';
Q.GAS_SPECIES_JAC{1}.P_GRID = z2p_simple( [21e3:4e3:71e3] );
if Q.ATMOSPHERE_DIM >= 2
  Q.GAS_SPECIES_JAC{1}.LAT_GRID = -9:3:9;  
end
%
Q.GAS_SPECIES{2}{1}         = 'ClO';
Q.GAS_SPECIES{3}{1}         = 'N2O';
Q.GAS_SPECIES{4}{1}         = 'H2O';
Q.GAS_SPECIES{4}{2}         = 'H2O-MPM89';
Q.GAS_SPECIES{5}{1}         = 'N2-SelfContStandardType';
%
Q.F_GRID            = linspace( 501.18e9, 501.58e9, 201 );
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
Q.SURFACE_PROP_AGENDA = ...
   { 'InterpAtmFieldToRteGps(surface_skin_t,t_field){}', ...
     'surfaceFlat{"water-liebe93"}' };
%
Q.IY_SPACE_AGENDA = { 'Copy(iy,i_space){}' };
Q.PRE_RTE_WSMS    = { 'MatrixCBR(i_space,f_grid){}' };
%
Q.PPATH_STEP_AGENDA = { 'ppath_stepGeometric{50e3}' };
Q.Y_UNIT            = 'RJ';
%
zplat        = 600e3;
Q.SENSOR_POS = Q.R_GEOID + zplat;
if Q.ATMOSPHERE_DIM >= 2
  Q.SENSOR_POS = [ Q.SENSOR_POS -23 ];
end
Q.SENSOR_LOS = geomztan2za( Q.R_GEOID, zplat, 25e3 );


%= Sensor
%
H.MBLOCK_ZA_GRID  = [-0.04:0.01:0.04];
H.ANTENNA_LOS     = 0;
H.ANTENNA_DIAGRAM = fullfile( atmlab_example_data, 'antenna.xml' );
Q.SENSOR_RESPONSE = H;
