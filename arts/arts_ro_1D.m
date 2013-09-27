function [t] = arts_ro_1D
  
O.leo_altitude = 820e3;
O.gps_altitude = 20200e3;
O.frequency    = 1575.42e6;
O.lmax         = 5e3;
O.lraytrace    = 100;
O.z_surface    = 0;

O.zimp_max     = 30e3;
O.zimp_dz      = 1e3;



A.planet       = 'earth';
A.atmfunc      = @arts_include_fascode;
A.fascode_atm  = 'tropical';

%- Create a temporary workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );
%
cfile = fullfile( workfolder, 'cfile.arts' );


%- Set basic and observation related fields of Q
%
Q = q_basic_local( O, workfolder );


%- Set basic and ppath parts of Q
%
Q = q_planet_local( Q, A, workfolder );


%- Impact heights to consider
%


%- Allocate variables for key variables
%
zimp0 = [ O.zimp_max : -O.zimp_dz : O.z_surface ]';
n0    = length( zimp0 );
%
[ztan0,lattan0] = deal( repmat( NaN, n0, 1 ) );

%- Run ARTS
%
for i = 1 : n0

  Q.SENSOR_LOS = geomztan2za( Q.REFELLIPSOID(1), O.leo_altitude, zimp0(i) );

  % Run ARTS
  %
  S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                        'RteSet', 'CloseF' }, workfolder );
  strs2file( cfile, S );  
  notok = arts( cfile, true );
  %
  if notok
    error('\n!!! Error while running ARTS !!!\n');
  end

  ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );   

  if strcmp( ppath.background, 'space' )
  
    % Extract tangent point
    [u,j]      = min( ppath.pos(:,1) );
    ztan0(i)   = ppath.pos(j,1);
    lattan0(i) = ppath.pos(j,2);
  end
end

keyboard

return







%----------------------------------------------------------------------------
function Q = q_basic_local(O,workfolder)
  %
  Q  = qarts;
  %
  Q.INCLUDES            = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'continua.arts' ) };
  %
  Q.ATMOSPHERE_DIM        = 1;
  Q.STOKES_DIM            = 1;
  Q.F_GRID                = O.frequency;
  Q.PPATH_LMAX            = O.lmax;
  Q.PPATH_LRAYTRACE       = O.lraytrace;
  %
  Q.CLOUDBOX_DO           = false;
  Q.J_DO                  = false;
  %
  Q.PPATH_AGENDA          = { 'ppath_agenda__FollowSensorLosPath'   };
  Q.PPATH_STEP_AGENDA     = { 'ppath_step_agenda__RefractedPath'    };
  %
  Q.SENSOR_POS            = O.leo_altitude;
  %
  Q.Z_SURFACE             = O.z_surface;
  %
  Q.WSMS_AT_END         = { 
    'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")', ...
    'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")', ...
    'VectorSet(rte_pos2,[])', ...
    'ppathCalc', ...
    sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder) };
  %
return


%----------------------------------------------------------------------------
function Q = q_planet_local(Q,A,workfolder)
  %
  rqre_field( A, 'planet' );
  rqre_field( A, 'atmfunc' );
  %
  if ~isa( A.atmfunc, 'function_handle' )
    error( 'The field A.atmfunc must be a function handle' ); 
  end
  if ~exist( func2str(A.atmfunc), 'file' )
    error( 'The function *%s* is not found (selected by A.atmfunc).', ...
                                                        func2str(A.atmfunc) ); 
  end
  %
  switch upper( A.planet )

   case 'EARTH'
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    %
    Q.ABS_SPECIES(1).TAG{1} = 'N2';
    Q.ABS_SPECIES(2).TAG{1} = 'O2';
    Q.ABS_SPECIES(3).TAG{1} = 'H2O';
    if A.atmfunc( Q, 'query', 'free_electrons_supported' );
      Q.ABS_SPECIES(4).TAG{1} = 'free_electrons';
      Q.REFR_INDEX_AIR_AGENDA = { ...
                           'refr_index_air_agenda__GasMWgeneralAndElectrons' };
    else
      Q.REFR_INDEX_AIR_AGENDA = { ...
                                       'refr_index_air_agenda__GasMWgeneral' };
    end
    
   otherwise
    error( 'Unrecognised choice for A.planet (%s).', A.planet );
  end
  %
  % Include atmospheric specific data
  Q = A.atmfunc( A, Q, workfolder );
  %  
return
