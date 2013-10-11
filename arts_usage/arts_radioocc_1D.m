% ARTS_RADIOOCC_1D   Simulation of 1D radio occultation, no power
%
%    The function simulates an occultation measurement between two
%    satellites, denoted as GPS and LEO, respectively.  The occultation is
%    considered to take place exactly in the LEO orbit plane. The GPS
%    satellite can be be assumed to be static or moving (inside the LEO
%    plane), see further below. Angular distances are denoted as "latitude"
%    following the ARTS nomenclature. The latitude gives here the angular
%    distance from the GPS satellite. 
%
%    This function does not cover attenuation, use *arts_radioocc_1D_power* if
%    such quantities are needed.
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
%       l_proppath  : The propagation path length.
%       t           : Time relative to the occultation with max z_impact.
%   The data in *R* are for an equidistant *R.z_impact*.
%
%   The results are also returned as a function of time in the structure T. 
%   The field T.t is the time grid used. The spacing of this grid follows
%   O.f_sampling. The remaining fields of T are matrices (in contrast to R 
%   only having vector fields), where the columns represent "multi-pathing". 
%   That is, each column represents a path (not to be confused with the 
%   pencil beam paths used i ARTS). The limit between these paths correspond 
%   to discontinuities in the arrival time (for pencil beam paths).
%   This structure T contains the same fields as R. 
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
%      z_impact4t0  : The impact height used as time reference (t=0 here).
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
% FORMAT   R = arts_radioocc_1D(Q,O,A)
%        
% OUT   R   Result structure, see above.
% IN    Q   Initial settings of Q. If empty: Q = qarts;   
%       O   Occultation structure, see above. If empty, some default 
%           values set that work as demonstration.
%       A   Atmospheric structure, see above. If empty, some planet specific
%           settings are applied. For example, for Earth Fascode tropical is
%           used. Free electrons are not included automatically for any planet.

% 2013-09-29   Created by Patrick Eriksson.

function [R,T] = arts_radioocc_1D(Q,O,A)
%
if isempty(Q)
  Q = qarts;
end
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
  O.z_impact4t0  = 20e3;
  O.f_sampling   = 4;

end
%
if isempty(A)
  A.planet       = 'earth';
  A.atmfunc      = @qarts_add_fascode;
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
Q = q_basic_local( Q, O, workfolder );


%- Set basic and ppath parts of Q, and get mass of planet
%
[Q,M] = q_planet_local( Q, A, workfolder );


%- Set up z_impact grid and R
%
R.z_impact = [ O.z_impact_max : -O.z_impact_dz : O.z_surface ]';
n0         = length( R.z_impact );
%
[R.z_tan,R.lat_tan,R.bangle,R.lat_distance]     = deal( repmat( NaN, n0, 1 ) );
[R.slta,R.l_geometric,R.l_optpath,R.l_proppath] = deal( repmat( NaN, n0, 1 ) );

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

  if strcmp( ppath.background, 'space' )  &  ppath.np > 1
  
    % Extract tangent point
    [u,j]        = min( ppath.pos(:,1) );
    R.z_tan(i)   = ppath.pos(j,1);
    R.lat_tan(i) = ppath.pos(j,2);

    % Bending angle
    R.bangle(i) = ppath.start_los(1) - ppath.end_los(1) + ppath.start_pos(2);

    % Calculate angular distance between transmitter and receiver
    c                 = ppath.r(end) * sind(ppath.start_los);
    za_leo            = asind(c/r_leo); 
    dlat              = ppath.start_los - za_leo;
    R.lat_distance(i) = ppath.start_pos(2) + dlat;

    % Path lenghts 
    % Part covered by ppath
    lppath = ppath.end_lstep + sum( ppath.lstep );
    lopt   = ppath.end_lstep + sum( ppath.lstep .* ( 0.5 * ...
                               (ppath.nreal(1:end-1)+ppath.nreal(2:end)) ) );
    % Add remaining part
    lext   = r_leo * sind(dlat) / sind(ppath.start_los); 
    lppath = lppath + lext;
    lopt   = lopt   + lext;
    
    % SLTA and geometrical distance
    lgeom        = sqrt( r_leo^2 + r_gps^2 - 2*r_leo*r_gps*...
                                                     cosd(R.lat_distance(i)) );
    R.slta(i)    = r_leo * r_gps * sind(R.lat_distance(i)) / lgeom - ...
                                                             Q.REFELLIPSOID(1);
    R.l_proppath(i)  = lppath;
    R.l_optpath(i)   = lopt;
    R.l_geometric(i) = lgeom;

  end
end


% Speed of increase in angular distance 
%
G         = constants( 'GRAVITATIONAL_CONSTANT' );
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
ind = find( ~isnan( R.lat_distance ) );
%
R.t = ( R.lat_distance - interp1( R.z_impact(ind), R.lat_distance(ind), ...
                                                O.z_impact4t0 ) ) / degpersec;

if nargout == 1
  return;   % --->
end

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
[T.slta,T.l_geometric,T.l_proppath]          = deal( repmat( NaN, nt, np ) );
[T.l_optpath,T.defocus,T.z_impact]           = deal( repmat( NaN, nt, np ) );
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
  T.l_proppath(it,i)   = interp1( R.t(ir), R.l_proppath(ir),   T.t(it) );
  T.l_optpath(it,i)    = interp1( R.t(ir), R.l_optpath(ir),    T.t(it) );
  T.z_impact(it,i)     = interp1( R.t(ir), R.z_impact(ir),     T.t(it) );

end


R = orderfields( R );
T = orderfields( T );

return


%----------------------------------------------------------------------------
function Q = q_basic_local(Q,O,workfolder)
  %
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'general.arts' );
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'agendas.arts' ); 
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'continua.arts' );
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
  Q.WSMS_AT_END{end+1} = 'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")';
  Q.WSMS_AT_END{end+1} = 'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")';
  Q.WSMS_AT_END{end+1} = 'VectorSet(rte_pos2,[])';
  %
  Q.WSMS_AT_END{end+1} = 'ppathCalc';
  Q.WSMS_AT_END{end+1} = ...
      sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder);
  %
return


%----------------------------------------------------------------------------
function [Q,M] = q_planet_local(Q,A,workfolder)
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

   case 'VENUS'
    %
    M = 4.8676e24;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_venus.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalVenus' );
   
   case 'EARTH'
    %
    M = constants( 'EARTH_MASS' );
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    %
    if ~isfield( A, 'ABS_SPECIES' )
      A.ABS_SPECIES(1).TAG{1} = 'N2';
      A.ABS_SPECIES(2).TAG{1} = 'O2';
      A.ABS_SPECIES(3).TAG{1} = 'H2O';
      A.ABS_SPECIES(4).TAG{1} = 'free_electrons';
    end

   case 'MARS'
    %
    M = 6.4185e23;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_mars.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalMars' );
    
   case 'JUPITER'
    %
    M = 1.8986e27;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_jupiter.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalJupiter' );
   
   otherwise
    error( 'Unrecognised choice for A.planet (%s).', A.planet );
  end

  switch upper( A.planet )
   case 'EARTH'
    %
    Q.REFR_INDEX_AIR_AGENDA = { 
        'NumericSet( refr_index_air, 1.0 )', ...
        'NumericSet( refr_index_air_group, 1.0 )',...
        'refr_index_airThayer', ...
        'refr_index_airFreeElectrons( demand_vmr_value = 0 )' };
    %
   otherwise 
    %
    Q.REFR_INDEX_AIR_AGENDA = { 
        'NumericSet( refr_index_air, 1.0 )', ...
        'NumericSet( refr_index_air_group, 1.0 )',...
        'refr_index_airMWgeneral', ...
        'refr_index_airFreeElectrons( demand_vmr_value = 0 )' };
    %
  end
  
  % Include atmospheric specific data
  Q = A.atmfunc( A, Q, workfolder );
  
  if 0   % Set to 1 if you want to test without refraction
    Q.REFR_INDEX_AIR_AGENDA = { 'refr_index_air_agenda__NoRefrac' };
  end
    
return
