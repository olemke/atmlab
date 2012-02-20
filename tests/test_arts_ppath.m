function test_arts_ppath( atmosphere_dim, n  )

%- Fixed settings
%
Q = qarts;
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ) };
Q.ATMOSPHERE_DIM        = atmosphere_dim;
Q.F_GRID                = 100e9;
Q.ABS_SPECIES(1).TAG{1} = 'H2O';
Q.RAW_ATMOSPHERE        = fullfile( atmlab('ARTS_XMLDATA_PATH'), ...
                                'atmosphere', 'fascod', 'midlatitude-winter' );
Q.PPATH_STEP_AGENDA     = { 'ppath_stepGeometric' };
%
if atmosphere_dim == 1
  Q.WSMS_AT_START       = { 'refellipsoidEarth( refellipsoid, "Sphere" )' };
  Q.RAW_ATM_EXPAND_1D   = false;
else
  Q.WSMS_AT_START     = { 'refellipsoidEarth( refellipsoid, "WGS84" )' };  
  Q.RAW_ATM_EXPAND_1D = true;
end


%- Number of pressure level
%
np                    = 30 + round( 170*rand(1,1) );

%- Number of latitude and longitude grid points
%
if atmosphere_dim < 2
  nlat                = 1;
else
  nlat                = 10 + round( 240*rand(1,1) );
end
if atmosphere_dim < 3
  nlon                = 1;
else
  nlon                = 10 + round( 240*rand(1,1) );
end

Q.P_GRID              = z2p_simple( linspace( 0, 80e3, np )' );
if nlat > 1
  Q.LAT_GRID          = linspace( -120, 120, nlat );
end
if nlat > 1
  Q.LON_GRID          = linspace( -120, 120, nlat );
end



Q.Z_SURFACE           = repmat( 500, nlat, nlon );
Q.PPATH_LMAX          = 10e3;
Q.SENSOR_POS          = 600e3;
Q.SENSOR_LOS          = 113;


%- Create a workfolder
%
workfolder = create_tmpfolder;


%- Define calculation part
%
Q.WSMS_AT_END         = { 
    'basics_checkedCalc', ...
    'cloudbox_checkedCalc', ...
    'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")', ...
    'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")', ...
    'ppathCalc', ...
    sprintf('WriteXML("ascii",ppath,"%s/ppath.xml")',workfolder) };




%- Rund ARTS and load result
%
S = qarts2cfile( Q, ... 
                 { 'Generl', 'AtmSrf', 'AbsrptSave', 'RteSet', 'CloseF' }, ...
                 workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );
%
ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );



%- Remove workfolder
%
delete_tmpfolder( workfolder );


keyboard