% SIMPLECLOUD_INIT   Definition of simple cloud scenario.
%
%    The cloud scenario is described by a structure C that can be used as
%    input to SIMPLECLOUD_GET to extract the ice and water content for
%    an arbitrary position. Full fields  are obtained by SIMPLECLOUD_FIELD.
%    
%    The cloud scenario is described by answering a number of questions.
%    The scenario can either be 1D or 3D.
%    
%    The vertical variation of IWC, LWC and rain is described by three
%    piece-wise linear profiles. The profiles are specified by the abundance
%    at the brakepoints. The profiles for IWC and LWC are treated to be zero 
%    outside the altitude range covered. The abundance at the end points
%    must accordingly be zero. The upper end of the rain profile is defined
%    in the same way, but the rain profile is assumed to be constant from the 
%    lowest altitude down to ground level. For 3D cases, the profiles are 
%    valid for centre position of the cloud.
%   
%    To faciliate the specification of the vertical variation, a number
%    of cloud types are pre-defined. The IWC and LWC profiles are then
%    described by the variables:
%       content    : The ice or liquid water content [g/m3].
%       altitude   : Centre altitude of the cloud [km]
%       thickness  : Thickness over which *content* is constant [km].
%       lower edge : Length of transition from *content* down to 0 
%                    lower side of cloud [km]. Min allowed value is 100 m.
%       upper edge : Length of transition from *content* down to 0 
%                    upper side of cloud [km]. Min allowed value is 100 m.
%    The rain profile is deswcribed as:
%       rate       : Rain rate [mm/h].
%       height     : Height (from 0) over which *rate* is constant [km].
%       upper edge : Length of transition from *rate* down to 0 upper
%                    side of rain cell [km]. Min allowed value is 100 m.
%     
%     For each cloud type there exist default values for these variables,
%     which either can be accepted or be changed.
%
%     For 3D, also the horisontal variation must be described. There exist
%     two functional forms: rectangular and gaussian. Rectangular clouds
%     are described in the same manner as the IWC and LWC profiles, but with
%     the same edge length on all sides. The latitude and longitude size
%     of gaussian clouds is the distance over which the abundande 
%     is > exp(-1). So, the size is somewhat bigger than FWHM in the 
%     direction of concern.
%
% FORMAT   C = simplecloud_init
%
% OUT      C   Setting structure.


% HISTORY: 2003-03-07  Created by Patrick Eriksson


function C = simplecloud_init


%--- Min/max values
%
minedge  = 100;   % Smallest length of edges
maxiwc   = 5;     % Max IWC value [g/m³]
maxlwc   = 5;     % Max LWC value [g/m³]
maxrain  = 100;   % Max rain rate [mm/h]


%--- Atmospheric dimensionality
%
C.dim = ascii_menu( 'Select atmospheric dimensionality', 2, '1D', '3D' );
C.dim = 2 * C.dim - 1;


%--- Cloud scenario
%
%- Default for internal variables
do_manual       = 0;
do_iwc          = 0;
iwc_content     = 0;
iwc_altitude    = 0;
iwc_thickness   = 0;
iwc_edgelow     = minedge; 
iwc_edgehigh    = minedge; 
do_lwc          = 0;
lwc_content     = 0;
lwc_altitude    = 0;
lwc_thickness   = 0;
lwc_edgelow     = minedge; 
lwc_edgehigh    = minedge; 
do_rain         = 0;
rain_rate       = 0;
rain_height     = 0;
rain_edgehigh   = minedge; 
hspape          = 1;
latlength       = 100e3;
lonlength       = 100e3;
hedge           = 10e3;
%
s = ascii_menu( 'Select cloud scenario', [], ...
      'Manual, IWC', ...
      'Manual, LWC', ...
      'Manual, IWC+LWC', ...
      'Manual, LWC+rain', ...
      'Manual, IWC+LWC+rain', ...
      'Altostratos (LWC)', ...
      'Cirrus (IWC)', ...
      'Cumulonimbus (IWC+LWC)', ...
      'Cumulonimbus, precipitating (IWC+LWC+rain)', ...
      'Cumulus (LWC)', ...
      'Nimbostratus, precipitating (LWC+rain)' );
%
switch s

  case 1;    % Manual IWC
    do_manual = 1;
    do_iwc    = 1;

  case 2;    % Manual LWC
    do_manual = 1;
    do_lwc    = 1;

  case 3;    % Manual IWC+LWC
    do_manual = 1;
    do_iwc    = 1;
    do_lwc    = 1;

  case 4;    % Manual LWC+rain
    do_manual = 1;
    do_lwc    = 1;
    do_rain   = 1;

  case 5;    % Manual IWC+LWC+rain
    do_manual = 1;
    do_iwc    = 1;
    do_lwc    = 1;
    do_rain   = 1;

  case 6;    % Altostratos (LWC)
    do_lwc          = 1;
    lwc_content     = 0.4;
    lwc_altitude    = 4.5e3;
    lwc_thickness   = 600;
    lwc_edgehigh    = 200; 
    hspape          = 1;
    latlength       = 200e3;
    lonlength       = 200e3;
    hedge           = 10e3;

  case 7;    % Cirrus (IWC)
    do_iwc          = 1;
    iwc_content     = 0.05;
    iwc_altitude    = 7e3;      % I have found several sources saying that 
    iwc_thickness   = 1.7e3;    % cirrus is only found > 6 km
    iwc_edgehigh    = 300; 
    hspape          = 1;
    latlength       = 100e3;
    lonlength       = 100e3;
    hedge           = 10e3;

  case {8,9};    % Cumulonimbus (IWC+LWC), + rain version
    do_iwc          = 1;
    iwc_content     = 0.5;   % ????
    iwc_altitude    = 8.5e3; 
    iwc_thickness   = 3e3; 
    iwc_edgelow     = 4e3; 
    iwc_edgehigh    = 1e3; 
    do_lwc          = 1;
    lwc_content     = 4;
    lwc_altitude    = 2e3;
    lwc_thickness   = 2e3;
    lwc_edgehigh    = 4e3; 
    hspape          = 1;
    latlength       = 10e3;
    lonlength       = 10e3;
    hedge           = 1e3;
    if s == 9                       % Note this case number
      do_rain         = 1;
      rain_rate       = 30;
      rain_height     = 3e3;
      rain_edgehigh   = 1e3; 
    end

  case 10;    % Cumulus (LWC)
    do_lwc          = 1;
    lwc_content     = 1;
    lwc_altitude    = 2e3;
    lwc_thickness   = 300;
    lwc_edgehigh    = 300; 
    hspape          = 2;
    latlength       = 100e3;
    lonlength       = 100e3;

  case 11;    % Nimbostratus, precipitating (LWC+rain)
    do_iwc          = 1;
    iwc_content     = 0.1;   % ????
    iwc_altitude    = 6e3; 
    iwc_thickness   = 2e3; 
    iwc_edgelow     = 2e3; 
    iwc_edgehigh    = 1e3; 
    do_lwc          = 1;
    lwc_content     = 0.6;    % ???
    lwc_altitude    = 2e3;
    lwc_thickness   = 2e3;
    lwc_edgehigh    = 2e3; 
    do_rain         = 1;
    rain_rate       = 10;
    rain_height     = 3e3;
    rain_edgehigh   = 1e3; 
    hspape          = 1;
    latlength       = 200e3;
    lonlength       = 200e3;

  otherwise
    error('Data are missing for some scenario.');

end


%--- Set vertical profiles for IWC, LWC and rain
%
C.do_iwc  = do_iwc;
C.do_lwc  = do_lwc;
C.do_rain = do_rain;
%
%- Manual selection
%
if do_manual   
  %
  if do_iwc
    fprintf('\n----- Ice water profile -----\n\n');
    fprintf('Breakpoints shall be given as a vector with min 4 values.\n');
    zs = input_vector( 'Profile breakpoints [km]', 1, 4 ) * 1e3;
    C.iwc = [ vec2col(zs), zeros( length(zs), 1 ) ];
    for i = 1 : length(zs)
      s = [ 'IWC at ', num2str(zs(i)/1e3), ' km [g/m3]' ];
      if i == 1  |  i == length(zs)
        fprintf('%s = 0\n',s); 
      else
        C.iwc(i,2) = input_scalar( s, 0, maxiwc );
      end
    end
  end
  %
  if do_lwc
    fprintf('\n----- Liquid water profile -----\n\n');
    fprintf('Breakpoints shall be given as a vector with min 4 values.\n');
    zs = input_vector( 'Profile breakpoints [km]', 1, 4 ) * 1e3;
    C.lwc = [ vec2col(zs), zeros( length(zs), 1 ) ];
    for i = 1 : length(zs)
      s = [ 'LWC at ', num2str(zs(i)/1e3), ' km [g/m3]' ];
      if i == 1  |  i == length(zs)
        fprintf('%s = 0\n',s); 
      else
        C.lwc(i,2) = input_scalar( s, 0, maxlwc );
      end
    end
  end
  %
  if do_rain
    fprintf('\n----- Rain profile -----\n\n');
    fprintf('Breakpoints shall be given as a vector with min 2 values.\n');
    fprintf('Rain is constant from lowest breakepoint down to ground.\n');
    zs = input_vector( 'Profile breakpoints [km]', 1, 2 ) * 1e3;
    C.rain = [ vec2col(zs), zeros( length(zs), 1 ) ];
    for i = 1 : length(zs)
      if i == 1
        s = [ 'Rain up to ', num2str(zs(i)/1e3), ' km [mm/h]' ];
      else
        s = [ 'Rain at ', num2str(zs(i)/1e3), ' km [mm/h]' ];
      end
      if i == length(zs)
        fprintf('%s = 0\n',s); 
      else
        C.rain(i,2) = input_scalar( s, 0, maxrain );
      end
    end
  end



%- Modifying a standard scenario
%
else
  %
  if do_iwc
    fprintf('\n----- Ice water profile -----\n\n');
    iwc_content = ...
            input_scalar( 'Ice water content [g/m3]', 0, maxiwc, iwc_content );
    iwc_altitude = 1e3 * ...
               input_scalar( 'Centre altitude [km]', 0, 10, iwc_altitude/1e3 );
    iwc_thickness = 1e3 * ...
              input_scalar( 'Layer thickness [km]', 0, 10, iwc_thickness/1e3 );
    iwc_edgelow = 1e3 * input_scalar( 'Thickness of lower edge [km]', ...
                                             minedge/1e3, 5, iwc_edgelow/1e3 );
    iwc_edgehigh = 1e3 * input_scalar( 'Thickness of upper edge [km]', ...
                                            minedge/1e3, 5, iwc_edgehigh/1e3 );

    C.iwc = [ iwc_altitude-iwc_thickness/2-iwc_edgelow,  0;
              iwc_altitude-iwc_thickness/2,              iwc_content;
              iwc_altitude+iwc_thickness/2,              iwc_content;
              iwc_altitude+iwc_thickness/2+iwc_edgehigh, 0 ];
  else
    C.iwc = [];
  end
  %
  if do_lwc
    fprintf('\n----- Liquid water profile -----\n\n');
    lwc_content = ...
         input_scalar( 'Liquid water content [g/m3]', 0, maxlwc, lwc_content );
    lwc_altitude = 1e3 * ...
               input_scalar( 'Centre altitude [km]', 0, 10, lwc_altitude/1e3 );
    lwc_thickness = 1e3 * ...
              input_scalar( 'Layer thickness [km]', 0, 10, lwc_thickness/1e3 );
    lwc_edgelow = 1e3 * input_scalar( 'Thickness of lower edge [km]', ...
                                             minedge/1e3, 5, lwc_edgelow/1e3 );
    lwc_edgehigh = 1e3 * input_scalar( 'Thickness of upper edge [km]', ...
                                            minedge/1e3, 5, lwc_edgehigh/1e3 );

    C.lwc = [ lwc_altitude-lwc_thickness/2-lwc_edgelow,  0;
              lwc_altitude-lwc_thickness/2,              lwc_content;
              lwc_altitude+lwc_thickness/2,              lwc_content;
              lwc_altitude+lwc_thickness/2+lwc_edgehigh, 0 ];
  else
    C.lwc = [];
  end
  %
  if do_rain
    fprintf('\n----- Rain profile -----\n\n');
    rain_rate = input_scalar( 'Rain rate [mm/h]', 0, maxrain, rain_rate );
    rain_height = 1e3 * input_scalar( 'Height [km]', 0, 6, rain_height/1e3 );
    rain_edgehigh = 1e3 * input_scalar( 'Thickness of upper edge [km]', ...
                                           minedge/1e3, 5, rain_edgehigh/1e3 );

    C.rain = [ rain_height,               rain_rate;
               rain_height+rain_edgehigh, 0 ];
  else
    C.rain = [];
  end

end



%=== 3D 

if C.dim == 3

  %=== Centre position
  %
  fprintf('\n----- Centre position -----\n\n');
  C.lat = input_scalar( 'Latitude', -90, +90 );
  C.lon = input_scalar( 'Longitude', -180, 180 );
  
  %=== Horisontal shape
  %
  C.hshape = ascii_menu( 'Select horisontal shape', 1, ...
      'Rectangular', ...
      'Gaussian' );

  %=== Horisontal size
  fprintf('\n----- Horisontal size -----\n\n');
  C.latlength = input_scalar( 'Latitude length [km]', 1, [], ...
                                                         latlength/1e3 ) * 1e3;
  C.lonlength = input_scalar( 'Longitude length [km]', 1, [], ...
                                                         lonlength/1e3 ) * 1e3;
  if C.hshape == 1
    C.hedge = input_scalar( 'Horisontal edge length [km]', ...
                                            minedge/1e3, [], hedge/1e3 ) * 1e3;
  end
end