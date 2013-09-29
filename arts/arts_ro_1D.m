% ARTS_RO_1D   Simulation of 1D radio occultation
%
%    The function simulates an occultation measurement between two
%    satellites, denoted as GPS and LEO, respectively. The occultation is
%    considered to take place exactly in the LEO orbit plane. The GPS
%    satellite can be be assumed to be static or moving (inside the LEO
%    plane), see further below. Angular distances are denoted as "latitude"
%    following the ARTS nomenclature. The latitude gives here the angular
%    distance from the GPS satellite. 
%
%    The results are gathered into the structure R having the fields
%       z_impact : The impact altitude, ie. the non-refracted tangent 
%                  altitude. Returned as monotonously descreasing values.
%       z_tan    : Tangent altitude.
%       lat_tan  : Latitude of tangent point.
%       lat_distance: The latitude distance between the satellites.
%       bangle   : Bending angle.
%       slta     : Stright line tangent altitude.
%       l_excess : The excess propgation length (optical path - geometrical
%                  distance between the satellites).
%       defocus  : Defocusing factor (1 = no defocusing).
%       t        : Time relative to the occulation with max z_impact.
%   Hence, R haolds data as a function *z_impact*.
%
%   The occultation is specied by the structure O having the fields
%      leo_altitude : Altitude of LEO orbit.
%      gps_altitude : Altitude of GPS orbit.
%      gps_movement : String describing movement. Options are 'none',
%                     'approaching' or 'disappering'.
%      frequency    : Frequency of signal.
%      lmax         : As ARTS WSV *lmax*. This setting affects here mainly
%                     accuracy of tangent point.
%      lraytrace    : As ARTS WSV *lraytrace*. Determines the overall
%                     accuracy. A value in the order of 100 m should be OK.
%      z_surface    : Surface altitude.
%      z_impact_max : Start altitude of occultation.
%      z_impact_dz  : Vertical spacing between path calculations.
%
%   Finally, the atmosphere is specified by the structure A having at least
%   these fields
%      planet  : The planet to model, such as 'earth'.
%      atmfunc : Handle to function inserting an atmosphere, such as
%                @arts_include_fascode.
%   The structure A is passed on to the atmosphere function. That is, A
%   likely also includes fields demanded of the "atmfunc". See
%   *arts_include_fascode* for how such a function is assumed to work
%
% FORMAT   R = arts_ro_1D(O,A)
%        
% OUT   R   Result structure, see above.
% IN    O   Occultation structure, see above. If empty, some default 
%           values used.
%       A   Atmospheric structure, see above. If empty, Fascode tropical 
%           is selected.

% 2013-09-29   Created by Patrick Eriksson.

function R = arts_ro_1D(O,A)
%
if isempty(O)
  O.leo_altitude = 820e3;
  O.gps_altitude = 20200e3;
  O.gps_movement = 'disappearing';
  O.frequency    = 1575.42e6;
  O.lmax         = 1e3;
  O.lraytrace    = 100;
  O.z_surface    = 0;

  O.z_impact_max = 30e3;
  O.z_impact_dz  = 100;
end
%
if isempty(A)
  A.planet       = 'earth';
  A.atmfunc      = @arts_include_fascode;
  A.fascode_atm  = 'tropical';
end


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


%- Relate LEO position to time
%
% SLTA = 0m is usefd as reference point
%- Allocate variables for key variables
%
R.z_impact = [ O.z_impact_max : -O.z_impact_dz : O.z_surface ]';
n0         = length( R.z_impact );
%
[R.z_tan,R.lat_tan,R.bangle,R.lat_distance] = deal( repmat( NaN, n0, 1 ) );
[R.slta,R.l_excess,R.defocus,lr,lt]         = deal( repmat( NaN, n0, 1 ) );


%- Radiii
%
r_leo     = Q.REFELLIPSOID(1) + O.leo_altitude;
r_gps     = Q.REFELLIPSOID(1) + O.gps_altitude;


%- Run ARTS
%
for i = 1 : n0

  Q.SENSOR_LOS = geomztan2za( Q.REFELLIPSOID(1), O.gps_altitude, ...
                                                           R.z_impact(i) );

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
    [u,j]        = min( ppath.pos(:,1) );
    R.z_tan(i)   = ppath.pos(j,1);
    R.lat_tan(i) = ppath.pos(j,2);

    % Bending angle
    R.bangle(i) = ppath.start_los(1) - ppath.end_los(1) + ppath.start_pos(2);

    % Calculate angular distance between transmitter and receiver
    c                 = ppath.r(end) * sind(ppath.start_los);
    za_leo            = asind(c/r_leo);  % Here for true ppath
    dlat              = ppath.start_los - za_leo;
    R.lat_distance(i) = ppath.start_pos(2) + dlat;

    % Optical path 
    % Part covered by ppath
    lopt = ppath.end_lstep + sum( ppath.lstep .* ( 0.5 * ...
                               (ppath.ngroup(1:end-1)+ppath.ngroup(2:end)) ) );
    % Add remaining part
    lopt = lopt + r_leo * sind(dlat) / sind(ppath.start_los); 
    
    % SLTA and geometrical distance
    lgeom        = sqrt( r_leo^2 + r_gps^2 - 2*r_leo*r_gps*...
                                                     cosd(R.lat_distance(i)) );
    R.slta(i)    = r_leo * r_gps * sind(R.lat_distance(i)) / lgeom - ...
                                                             Q.REFELLIPSOID(1);
    R.l_excess(i) = lopt - lgeom;
    
    % Defocusing
    r_tan2 = Q.REFELLIPSOID(1) + R.z_tan(i);
    lr(i)  = sqrt( r_leo^2 + r_tan2 ); 
    lt(i)  = sqrt( r_gps^2 + r_tan2 ); 

  end
end


% Speed of increase in angular distance 
%
G         = constants( 'GRAVITATIONAL_CONSTANT' );
M         = constants( 'EARTH_MASS' );
t_leo     = sqrt( (4*pi^2*r_leo^3) / (G*M) );
degpersec = 360 / t_leo;
%
switch lower(O.gps_movement)
 case 'none'
  ;
 case 'approaching'
  t_gps     = sqrt( (4*pi^2*r_gps^3) / (G*M) );
  degpersec = degpersec - 360 / t_gps;
 case 'disappearing'
  t_gps     = sqrt( (4*pi^2*r_gps^3) / (G*M) );
  degpersec = degpersec + 360 / t_gps;
 otherwise
  error( 'Unrecognised choice for *O.gps_movement* (%s).', O.gps_movement );
end


% Relative arrival time
%
R.t = ( R.lat_distance - R.lat_distance(1) ) / degpersec;

% Defocusing
%
for i = 1 : n0
  if ~isnan( lr(i) )
    
    fac = (pi/180) * (lr(i)*lt(i)) / (lr(i)+lt(i));
    
    if i == 1
      R.defocus(i) = 1 / ( 1 - fac*(  R.bangle(i+1)  -  R.bangle(i)  ) /  ...
                                   ( R.z_impact(i+1) - R.z_impact(i) ) );
    elseif i == n0
      R.defocus(i) = 1 / ( 1 - fac*(  R.bangle(i)  -  R.bangle(i-1)  ) /  ...
                                   ( R.z_impact(i) - R.z_impact(i-1) ) );
    else
      R.defocus(i) = 1 / ( 1 - fac*(  R.bangle(i+1)  -  R.bangle(i-1)  ) /  ...
                                   ( R.z_impact(i+1) - R.z_impact(i-1) ) );
    end
  end
end

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
  Q.SENSOR_POS            = O.gps_altitude;
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

  if 0   % Set to 1 if you want to test without refraction
    Q.REFR_INDEX_AIR_AGENDA = { 'refr_index_air_agenda__NoRefrac' };
  end
  
  % Include atmospheric specific data
  Q = A.atmfunc( A, Q, workfolder );
  %  
return
