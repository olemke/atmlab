% ARTS_RADIOOCC_1D   Simulation of 1D radio occultation
%
%    The function simulates an occultation measurement between two
%    satellites, denoted as GPS and LEO, respectively. The occultation is
%    considered to take place exactly in the LEO orbit plane. The GPS
%    satellite can be be assumed to be static or moving (inside the LEO
%    plane), see further below. Angular distances are denoted as "latitude"
%    following the ARTS nomenclature. The latitude gives here the angular
%    distance from the GPS satellite. 
%
%    The basic results are gathered into the structure R having fields
%       z_impact    : The impact altitude, ie. the non-refracted tangent 
%                     altitude. Returned as monotonously decreasing values.
%       z_tan       : Tangent altitude.
%       lat_tan     : Latitude of tangent point.
%       lat_distance: The latitude distance between the satellites.
%       bangle      : Bending angle.
%       slta        : Straight line tangent altitude.
%       l_geometric : The (straight line) geometrical distance between the 
%                     satellites.
%       l_optpath   : The optical path length.
%       t           : Time relative to the occultation with max z_impact.
%   Hence, R holds data as a function of *z_impact*.
%
%   The results are also returned as a function of time in the structure T. 
%   The field T.t is the time grid used. The spacing of this grid follows
%   O.f_sampling. The remaining fields of T are matrices (in contrast to R 
%   only having vector fields), where the columns represent "multi-pathing". 
%   That is, each column represents a path (not to be confused with the 
%   pencil beam paths used i ARTS). The limit between these paths correspond 
%   to discontinuities in the arrival time (for pencil beam paths).
%   This structure T contains mainly the same fields as R. Additional fields
%   are
%       defocus     : Defocusing factor (1 = no defocusing). Calculation
%                     inaccuracy can give negative values. Such values are
%                     kept to indicate possibly problematic data, but should
%                     be set to zero if actually used.
%
%   The occultation is specified by the structure O having the fields
%      leo_altitude : Altitude of LEO orbit.
%      gps_altitude : Altitude of GPS orbit.
%      gps_movement : String describing movement. Options are 'none',
%                     'approaching' or 'disappearing'.
%      frequency    : Frequency of signal.
%      lmax         : As ARTS WSV *lmax*. This setting affects here mainly
%                     accuracy of tangent point.
%      lraytrace    : As ARTS WSV *lraytrace*. Determines the overall
%                     accuracy. A value in the order of 100 m should be OK.
%      z_surface    : Surface altitude.
%      z_impact_max : Start altitude of occultation.
%      z_impact_dz  : Vertical spacing between path calculations.
%      f_sampling   : Sampling frequency for data in T.
%
%   Finally, the atmosphere is specified by the structure A having at least
%   these fields
%      planet  : The planet to model, such as 'earth'.
%      atmfunc : Handle to function inserting an atmosphere, such as
%                @arts_include_fascode.
%   The structure A is passed on to the atmosphere function. That is, A
%   likely also includes fields required by the "atmfunc". See
%   *arts_include_fascode* for how such a function is assumed to work
%
% FORMAT   R = arts_radioocc_1D(O,A)
%        
% OUT   R   Result structure, see above.
% IN    O   Occultation structure, see above. If empty, some default 
%           values set that work as demonstration.
%       A   Atmospheric structure, see above. If empty, some planet specific
%           settings are applied. For example, for Earth Fascode tropical is
%           used. Free electrons are not included automatically for any planet.

% 2013-09-29   Created by Patrick Eriksson.

function [R,T] = arts_radioocc_1D(O,A)
%
if isempty(O)
  O.leo_altitude = 820e3;
  O.gps_altitude = 20200e3;
  O.gps_movement = 'disappearing';
  O.frequency    = 1575.42e6;
  O.lmax         = 2e3;
  O.lraytrace    = 100;
  O.z_surface    = 0;

  O.z_impact_max = 30e3;
  O.z_impact_dz  = 200;
  O.f_sampling   = 4;
end
%
if isempty(A)
  A.planet       = 'earth';
  A.atmfunc      = @qarts_add_fascode;
  A.fascode_atm  = 'tropical';
  % 
  % A.ABS_SPECIES set below, adopted to planet. Free electrons NOT included.
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
[R.z_tan,R.lat_tan,R.bangle,R.lat_distance]  = deal( repmat( NaN, n0, 1 ) );
[R.slta,R.l_geometric,R.l_optpath,R.defocus] = deal( repmat( NaN, n0, 1 ) );


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
    R.l_optpath(i)   = lopt;
    R.l_geometric(i) = lgeom;
    
    % Defocusing
    %r_tan2 = Q.REFELLIPSOID(1) + R.z_tan(i);
    %lr(i)  = sqrt( r_leo^2 + r_tan2 ); 
    %lt(i)  = sqrt( r_gps^2 + r_tan2 ); 

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


% Create T
%
% Time grid to use
T.t   = min(R.t) : 1/O.f_sampling : max(R.t);
%
% Find start and end of each time chunck
istart = [];
iend   = [];
i1     = NaN; % Start of present chunck%

for i = 1 : n0
  % If Nan, then we are inbetween chuncks
  if isnan( R.t(i) )
    i1 = NaN;

  else
    % If i1==NaN, this is the start of a new chunck
    if isnan(i1)
      i1 = i;
    end
    
    % End point if last point or next is NaN
    if i == n0 | isnan(R.t(i+1))
      if i > i1 % Ignore length-1 chuncks
        istart = [ istart i1 ];
        iend   = [ iend   i  ];
      end
      i1     = NaN;
    
    % Also end point if sign change of t-derivate
    elseif i>1  &  ~isnan(R.t(i-1))  &  ...
          sign(R.t(i+1)-R.t(i)) ~= sign(R.t(i)-R.t(i-1))
      istart = [ istart i1 ];
      iend   = [ iend   i  ];
      i1     = i;      
    end    
  end
end
%
np    = length( istart );
nt    = length( T.t );
%  
[T.z_tan,T.lat_tan,T.bangle,T.lat_distance]  = deal( repmat( NaN, nt, np ) );
[T.slta,T.l_geometric,T.l_optpath,T.defocus] = deal( repmat( NaN, nt, np ) );
[T.z_impact]                                 = deal( repmat( NaN, nt, np ) );
%
for i = 1 : np

  % Interpolate over time of chunk
  ir = istart(i) : iend(i);
  tmin = min( [ R.t(ir([1,end])) ] );
  tmax = max( [ R.t(ir([1,end])) ] );
  it = find( T.t >= tmin  &  T.t < tmax );  
  
  T.z_tan(it,i)        = interp1( R.t(ir), R.z_tan(ir),        T.t(it) );
  T.lat_tan(it,i)      = interp1( R.t(ir), R.lat_tan(ir),      T.t(it) );
  T.lat_distance(it,i) = interp1( R.t(ir), R.lat_distance(ir), T.t(it) );
  T.bangle(it,i)       = interp1( R.t(ir), R.bangle(ir),       T.t(it) );
  T.slta(it,i)         = interp1( R.t(ir), R.slta(ir),         T.t(it) );
  T.l_geometric(it,i)  = interp1( R.t(ir), R.l_geometric(ir),  T.t(it) );
  T.l_optpath(it,i)    = interp1( R.t(ir), R.l_optpath(ir),    T.t(it) );
  T.z_impact(it,i)     = interp1( R.t(ir), R.z_impact(ir),     T.t(it) );

end


% Defocusing
%
for ip = 1 : np
  for it = 1 : nt
    
    if ~isnan( T.bangle(it,ip) )
      
      r_tan2 = ( Q.REFELLIPSOID(1) + T.z_tan(it,ip) )^2;
      lr     = sqrt( r_leo^2 + r_tan2 ); 
      lt     = sqrt( r_gps^2 + r_tan2 ); 
      
      fac = (pi/180) * (lr*lt) / (lr+lt);

      if it == 1  |  isnan(T.bangle(it-1,ip))
        if it < nt   % If at upper end, we have to leave a NaN
          T.defocus(it,ip) = 1 / ( 1 - fac * ...
                            (  T.bangle(it+1,ip)  -  T.bangle(it,ip)  ) /  ...
                            ( T.z_impact(it+1,ip) - T.z_impact(it,ip) ) );
        end
      elseif it == nt  |  isnan(T.bangle(it+1,ip))
        if it > 1  % If at lower end, we have to leave a NaN
          T.defocus(it,ip) = 1 / ( 1 - fac * ...
                            (  T.bangle(it,ip)  -  T.bangle(it-1,ip)  ) /  ...
                            ( T.z_impact(it,ip) - T.z_impact(it-1,ip) ) );
        end
      else
        T.defocus(it,ip) = 1 / ( 1 - fac * ...
                          (  T.bangle(it+1,ip)  -  T.bangle(it-1,ip)  ) /  ...
                          ( T.z_impact(it+1,ip) - T.z_impact(it-1,ip) ) );
      end
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
    error( 'The field *A.atmfunc* must be a function handle' ); 
  end
  if ~exist( func2str(A.atmfunc), 'file' )
    error( 'The function *%s* is not found (selected by A.atmfunc).', ...
                                                        func2str(A.atmfunc) ); 
  end

  % Set basics and default for planet:
  %
  switch upper( A.planet )

   case 'EARTH'
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    %
    if ~isfield( A, 'ABS_SPECIES' )
      A.ABS_SPECIES(1).TAG{1} = 'N2';
      A.ABS_SPECIES(2).TAG{1} = 'O2';
      A.ABS_SPECIES(3).TAG{1} = 'H2O';
    end

   case 'MARS'
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_mars.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    
   otherwise
    error( 'Unrecognised choice for A.planet (%s).', A.planet );
  end

  % Include atmospheric specific data
  Q = A.atmfunc( A, Q, workfolder );

  % Set stuff dependent on call above
  switch upper( A.planet )

   case 'EARTH'
    %
    nofreee_agenda = 'refr_index_air_agenda__GasThayer';
    general_agenda = 'refr_index_air_agenda__GasThayerAndElectrons';
   
   otherwise
    %
    nofreee_agenda = 'refr_index_air_agenda__GasMWgeneral';
    general_agenda = 'refr_index_air_agenda__GasMWgeneralAndElectrons';
  
  end

  i = 0; fe_found = false;
  while i <  length(Q.ABS_SPECIES) &  ~fe_found
    i        = i + 1;
    fe_found = strcmp( arts_tgs2species( Q.ABS_SPECIES(i).TAG{1} ), ...
                                                          'free_electrons' );
  end
  
  if fe_found
    Q.REFR_INDEX_AIR_AGENDA = { general_agenda };
  else
    Q.REFR_INDEX_AIR_AGENDA = { nofreee_agenda };
  end
  
  if 0   % Set to 1 if you want to test without refraction
    Q.REFR_INDEX_AIR_AGENDA = { 'refr_index_air_agenda__NoRefrac' };
  end
    
return
