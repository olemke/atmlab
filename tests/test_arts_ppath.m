% TEST_ARTS_PPATH   Testing of ARTS ppath calculations
%
%    Random test cases are generated. The following variables are
%    randomised:
%       length of p_grid
%       length of lat_grid
%       length of lon_grid
%       z_surface
%       sensor_pos
%       sensor_los
%
%    A ppath calculation for ARTS is performed for each test case. A basic check
%    of the ARTS calculations performed, by using atmlab functions. If any
%    error is found, "keyboard" is called. The work folder is then left for
%    debugging purposes.
%
%
% FORMAT   test_arts_ppath( atmosphere_dim, n, [re_sphere] )
%        
% IN    atmosphere_dim   Atmospheric dimensionality
%       n                Run n cases
% OPT   re_sphere        Flag to also use a spherical reference ellipsoid
%                        for 2D and 3D. Default is false.

% 2012-02-22   Created by Patrick.

function test_arts_ppath( atmosphere_dim, n, varargin  )
%
[re_sphere] = optargs( varargin, { false } );
  
  
%- Fixed settings
%
Q = qarts;
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ) };
Q.ATMOSPHERE_DIM        = atmosphere_dim;
Q.F_GRID                = 100e9;
Q.ABS_SPECIES(1).TAG{1} = 'H2O';
Q.PPATH_STEP_AGENDA     = { 'ppath_stepGeometric' };
Q.PPATH_LMAX            = 10e3;
%
if atmosphere_dim == 1  ||  re_sphere
  refell                = ellipsoidmodels( 'SphericalEarth' );
  re_string             = 'refellipsoidEarth( refellipsoid, "Sphere" )';
else
  refell                = ellipsoidmodels( 'WGS84' );
  re_string             = 'refellipsoidEarth( refellipsoid, "WGS84" )'; 
end


%- Load a test atmosphere
%
atmtest =  fullfile( atmlab('ARTS_XMLDATA_PATH'), ...
                                'atmosphere', 'fascod', 'midlatitude-winter' );
Az      = xmlLoad( [ atmtest, '.z.xml' ] ); 
At      = xmlLoad( [ atmtest, '.t.xml' ] ); 
Ah2o    = xmlLoad( [ atmtest, '.H2O.xml' ] ); 



%- Create a workfolder
%
workfolder = create_tmpfolder;



%- Run through n random cases

for c = 1 : n

  fprintf(' > Doing %d/%d\r',c,n)

  %- Pressure grid
  %
  np                    = 30 + round( 170*rand );
  Q.P_GRID              = z2p_simple( linspace( 0, 80e3, np )' );

  %- Number of latitude and longitude grid points
  %
  nlat                = 1;
  nlon                = 1;
  %
  if atmosphere_dim == 2
    nlat                = 10 + round( 350*rand );
    Q.LAT_GRID          = linspace( -135, 135, nlat )';
    nlon                = 1;
  elseif atmosphere_dim == 3
    nlat                = 10 + round( 350*rand );
    nlon                = 10 + round( 350*rand );
    Q.LAT_GRID          = linspace( -90, 90, nlat )';
    Q.LON_GRID          = linspace( -180, 180, nlon )';
  end

  % Atmospheric fields
  Q.Z_FIELD = repmat( interpp( Az.grids{1}, Az.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  Q.T_FIELD = repmat( interpp( At.grids{1}, At.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  Q.VMR_FIELD = repmat( interpp( Ah2o.grids{1}, Ah2o.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  Q.VMR_FIELD = reshape( Q.VMR_FIELD, [1 np nlat nlon ] );
  
  %- Surface altitude
  %
  Q.Z_SURFACE           = 500 + 1e3*rand + 1e3*rand( nlat, nlon );

  %- Sensor pos/los
  %
  lat0                  = 0;
  lon0                  = 0;
  aa0                   = 0;
  %
  if rand < 0.5
    Q.SENSOR_POS        = 3e3 + 50e3*rand;
    Q.SENSOR_LOS        = 90  + 90*rand;    
  else
    Q.SENSOR_POS        = 700e3 + 50e3*randn;
    Q.SENSOR_LOS        = 180*rand;    
  end
  %
  if atmosphere_dim == 2
    lat0                = -90 + 180*rand;
    Q.SENSOR_POS(2)     = lat0;
    if rand < 0.5
      Q.SENSOR_LOS      = -Q.SENSOR_LOS;
      aa0               = 180;
    end
  elseif atmosphere_dim == 3
    lat0                = -90 + 180*rand;    
    lon0                = -180 + 360*rand;    
    Q.SENSOR_POS(2)     = lat0;
    Q.SENSOR_POS(3)     = lon0;
    aa0                 = -180 + 360*rand;
    Q.SENSOR_LOS(2)     = aa0;
  end

  %- Define calculation part
  %
  Q.WSMS_AT_END         = { 
    re_string,  ...
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
  notok = arts( cfile, true );
  %
  if notok
    fprintf('\n!!! Error while running ARTS !!!\n');
    keyboard
  end
  %
  ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );


  %- Check result
  %
  if ppath.np > 1
    if atmosphere_dim == 1  ||  re_sphere
      re = refell(1);
    else
      re = interp1( Q.LAT_GRID, ellipsoidradii(refell,Q.LAT_GRID), lat0 );
    end
    
    [x0,y0,z0,dx,dy,dz] = geocentricposlos2cart( re+Q.SENSOR_POS(1), ...
                                       lat0, lon0, abs(Q.SENSOR_LOS(1)), aa0 );

    % Check ppath points
    lt = ppath.l_space + [ 0; cumsum(ppath.l_step) ];
    for i = 1 : size(ppath.pos,1)
      if atmosphere_dim == 3
        lont = ppath.pos(i,2);
      else
        lont = 0;
      end
      
      [xt,yt,zt] = geocentric2cart( ppath.r(i), ppath.pos(i,2), lont );
      dd = norm( [ xt-(x0+lt(i)*dx), yt-(y0+lt(i)*dy), zt-(z0+lt(i)*dz) ] );
      if dd > 1e-4
        fprintf('\n!!! Deviating ppath point found !!!\n');
        [rt,latt,lont,zat,aat] = cartposlos2geocentric( x0+lt(i)*dx, ...
                                        y0+lt(i)*dy, z0+lt(i)*dz, dx, dy, dz );
        keyboard
      end
    end
    
    % Special check for end point
    if strcmp( ppath.background, 'surface' )
      if atmosphere_dim == 1
        dz = abs( ppath.pos(end,1) - Q.Z_SURFACE );
      elseif atmosphere_dim == 2
        dz = abs( ppath.pos(end,1) - interp1( Q.LAT_GRID, Q.Z_SURFACE, ...
                                                          ppath.pos(end,2) ) );
      else
        dz = abs( ppath.pos(end,1) - interp2( Q.LAT_GRID, Q.LON_GRID, ...
                           Q.Z_SURFACE, ppath.pos(end,2), ppath.pos(end,3) ) );
      end
      %
      if dz > 1e-3
        fprintf('\n!!! Deviating surface point found !!!\n');
        keyboard        
      end  
    end
  end
end

fprintf('\n')

%- Remove workfolder
%
delete_tmpfolder( workfolder );

