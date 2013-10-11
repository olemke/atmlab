% ARTS_RADIOOCC_1D_POWER   Simulation of 1D radio occultation
%
%    This function is very similar to *arts_radioocc_1d*, but considers also
%    attenuation quantitities, and can thus be used to estimate recieved power.
%    The drawback is that this function is (much) slower and can fail to
%    provide results for impact heights. The drawbacks come from the fact that
%    here the path between two specified positions are determined, that is
%    handled by slow and not completly stable algorithm. In *arts_radioocc_1d*
%    the calculations are performed for a set of precalculated viewing
%    directions.
%
%    See *arts_radioocc_1d* for overall nomenclature, the basic geometry
%    assumed, comments around *A* and the purpose of the structure *T*. Note
%    that the occultation here is specied by SLTA, while in *arts_radioocc_1d*
%    impact height is used.
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
%       tr_total    : Total transmission over the link. This transmission
%                     is the product of the ones below.
%       tr_space    : Transmission due to free space loss alone.
%       tr_atmos    : Transmission due to atmospheric attenuation  alone.
%       tr_space    : Transmission due to defocusing alone.
%   The data in *R* are for an equidistant *R.lat_distance*.
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
%      slta_max     : Max SLTA of occultation.
%      slta_min     : Min SLTA of occultation.
%      slta_n       : Number of SLTA to include.
%      z_impact4t0  : The impact height used as time reference (t=0 here).
%      f_sampling   : Sampling frequency for data in T.
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

function [R,T] = arts_radioocc_1D_power(Q,O,A)
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

  O.slta_max     = 30e3;
  O.slta_min     = -100e3;
  O.slta_n       = 101;

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


%- Set basic and ppath parts of Q
%
[Q,M] = q_planet_local( Q, A, workfolder );


%- Radiii
%
r_leo     = Q.REFELLIPSOID(1) + O.leo_altitude;
r_gps     = Q.REFELLIPSOID(1) + O.gps_altitude;


%- Determine latitude distances to use and set-up R
%
dlat_min = acosd( (Q.REFELLIPSOID(1)+O.slta_max) / r_gps ) + ...
           acosd( (Q.REFELLIPSOID(1)+O.slta_max) / r_leo );
dlat_max = acosd( (Q.REFELLIPSOID(1)+O.slta_min) / r_gps ) + ...
           acosd( (Q.REFELLIPSOID(1)+O.slta_min) / r_leo );
%
R.lat_distance = linspace( dlat_min, dlat_max, O.slta_n );
n0             = length( R.lat_distance );
%
[R.z_tan,R.lat_tan,R.bangle,R.z_impact]         = deal( repmat( NaN, n0, 1 ) );
[R.slta,R.l_geometric,R.l_optpath,R.l_proppath] = deal( repmat( NaN, n0, 1 ) );
[R.tr_total,R.tr_space,R.tr_atmos,R.tr_defoc]   = deal( repmat( NaN, n0, 1 ) );



%- Run ARTS
%
for i = 1 : n0

  Q.TRANSMITTER_POS = [ O.leo_altitude, R.lat_distance(i) ];

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

  ppath  = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );   
  iy     = xmlLoad( fullfile( workfolder, 'iy.xml' ) );   
  iy_aux = xmlLoad( fullfile( workfolder, 'iy_aux.xml' ) );   

  if strcmp( ppath.background, 'transmitter' )
  
    % Extract tangent point
    [u,j]        = min( ppath.pos(:,1) );
    R.z_tan(i)   = ppath.pos(j,1);
    R.lat_tan(i) = ppath.pos(j,2);

    % Impact height
    R.z_impact(i) = ppath.constant - Q.REFELLIPSOID(1);
    
    % Bending angle
    R.bangle(i) = ppath.start_los(1) - ppath.end_los(1) + ppath.start_pos(2);

    % Path lenghts 
    lppath = ppath.start_lstep + ppath.end_lstep + sum( ppath.lstep );
    lopt   = ppath.start_lstep + ppath.end_lstep + sum( ppath.lstep .* ...
                       ( 0.5 * (ppath.ngroup(1:end-1)+ppath.ngroup(2:end)) ) );

    % SLTA and geometrical distance
    lgeom        = sqrt( r_leo^2 + r_gps^2 - 2*r_leo*r_gps*...
                                                     cosd(R.lat_distance(i)) );
    R.slta(i)    = r_leo * r_gps * sind(R.lat_distance(i)) / lgeom - ...
                                                             Q.REFELLIPSOID(1);
    R.l_proppath(i)  = lppath;
    R.l_optpath(i)   = lopt;
    R.l_geometric(i) = lgeom;

    R.tr_total(i)  = iy(1);
    R.tr_space(i)  = iy_aux{1};
    R.tr_atmos(i)  = iy_aux{2};
    R.tr_defoc(i)  = iy_aux{3}; 
    
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
ind = find( ~isnan( R.z_impact ) );
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
[T.z_tan,T.lat_tan,T.bangle,T.lat_distance]   = deal( repmat( NaN, nt, np ) );
[T.slta,T.l_geometric,T.l_proppath]           = deal( repmat( NaN, nt, np ) );
[T.l_optpath,T.defocus,T.z_impact]            = deal( repmat( NaN, nt, np ) );
[T.tr_total,T.tr_space,T.tr_atmos,T.tr_defoc] = deal( repmat( NaN, n0, 1 ) );
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

  T.tr_total(it,i)     = interp1( R.t(ir), R.tr_total(ir),     T.t(it) );
  T.tr_space(it,i)     = interp1( R.t(ir), R.tr_space(ir),     T.t(it) );
  T.tr_atmos(it,i)     = interp1( R.t(ir), R.tr_atmos(ir),     T.t(it) );
  T.tr_defoc(it,i)     = interp1( R.t(ir), R.tr_defoc(ir),     T.t(it) );
  
end


% Defocusing
%
for ip = 1 : np
  for it = 1 : nt
    
    if ~isnan( T.bangle(it,ip) )
      
      r_tan2 = ( Q.REFELLIPSOID(1) + T.z_tan(it,ip) )^2;
      lr     = sqrt( r_leo^2 - r_tan2 ); 
      lt     = sqrt( r_gps^2 - r_tan2 ); 
      
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
  Q.PPATH_AGENDA          = { 'ppath_agenda__TransmitterReceiverPath'   };
  Q.PPATH_STEP_AGENDA     = { 'ppath_step_agenda__RefractedPath'    };
  %
  Q.SENSOR_POS            = O.gps_altitude;
  Q.SENSOR_LOS            = [];
  %
  Q.Z_SURFACE             = O.z_surface;
  %
  Q.WSMS_AT_END{end+1} = 'VectorSet(rte_los,[])';
  Q.WSMS_AT_END{end+1} = 'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")';
  Q.WSMS_AT_END{end+1} = ...
                   'VectorExtractFromMatrix(rte_pos2,transmitter_pos,0,"row")';
  %
  Q.ABSORPTION         = 'OnTheFly';
  Q.ABS_LINES_FORMAT   = 'None';
  %
  Q.IY_TRANSMITTER_AGENDA = { 'iy_transmitter_agenda__UnitUnpolIntensity' };
  %
  Q.WSMS_AT_END{end+1} = 'AgendaSet( iy_main_agenda ){';
  
  Q.WSMS_AT_END{end+1} = sprintf('  iyRadioLink( defocus_method = %d ) }',...
                                    safegetfield( O, 'defocus_method', 2 ) );
  Q.WSMS_AT_END{end+1} = [ 'ArrayOfStringSet(iy_aux_vars,[',...
                '"Free space loss","Atmospheric loss","Defocusing loss"])' ];
  Q.WSMS_AT_END{end+1} = 'iyCalc';
  Q.WSMS_AT_END{end+1} = ...
                      sprintf('WriteXML("ascii",iy,"%s/iy.xml")',workfolder);
  Q.WSMS_AT_END{end+1} = ...
                sprintf('WriteXML("ascii",iy_aux,"%s/iy_aux.xml")',workfolder);
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
      A.ABS_SPECIES(1).TAG{1} = 'N2-SelfContStandardType';
      A.ABS_SPECIES(2).TAG{1} = 'O2-PWR98';
      A.ABS_SPECIES(3).TAG{1} = 'H2O-PWR98';
      A.ABS_SPECIES(4).TAG{1} = 'free_electrons';
    end

   case 'MARS'
    %
    M = 6.4185e23;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_mars.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    
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
