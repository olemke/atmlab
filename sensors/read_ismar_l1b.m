% READ_ISMAR_L1B   Reading of ISMAR and MARSS L1B data  
%
%   All variables are extracted. Date and time data are combined and
%   returned as modified Julian date (MJD).
%   
%   Example result:
%     >> I=read_ismar_l1b('metoffice-ismar_faam_20150305_r014_b889.nc')
%     I = 
%                                      mjd: [11935x1 double]
%                                  channel: [21x7 char]
%                                    angle: [11935x1 double]
%                                 altitude: [11935x1 double]
%                                 latitude: [11935x1 double]
%                                longitude: [11935x1 double]
%                     platform_pitch_angle: [11935x1 double]
%                      platform_roll_angle: [11935x1 double]
%                     platform_orientation: [11935x1 double]
%                        sensor_view_angle: [11935x1 double]
%                     sensor_azimuth_angle: [11935x1 double]
%                    detected_polarisation: [21x11935 double]
%                   brightness_temperature: [21x11935 double]
%      brightness_temperature_random_error: [21x11935 double]
%    brightness_temperature_positive_error: [21x11935 double]
%    brightness_temperature_negative_error: [21x11935 double]
%         calibration_interpolation_factor: [21x11935 double]
%
%  Note that the field brightness_temperature_random_error is not at hand
%  for MARSS.
%
% FORMAT   I = read_ismar_l1b(file)
%
% OUT   I      Structure with L1b data.
% IN    file   Name of file to read.

% 2015-08-07  Mainly written by Bengt Rydberg. Polished and added to Atmlab
%             by Patrick.

function I = read_ismar_l1b(file)

% read time and reference time
time     = ncread( file, 'time', [1], [Inf] );
time     = double( time );
time_att = ncreadatt( file, 'time', 'units' );
pat      = [ 'seconds since (?<year>\w+)-(?<month>\w+)-(?<day>\w+) '...
             '(?<hour>\w+):(?<minute>\w+):(?<second>\w+)' ];
timeref  = regexp( time_att,pat, 'names' );
year     = str2num( timeref.year );
month    = str2num( timeref.month );
day      = str2num( timeref.day );
hour     = str2num( timeref.hour );
minute   = str2num( timeref.minute );
second   = str2num( timeref.second );
mjd0     = date2mjd( year, month, day, hour, minute, second );
I.mjd    = mjd0 + time/(60*60*24);



% read remaining variables

I.channel   = ncread( file, 'channel' )';

I.angle     = ncread( file, 'angle', [1], [Inf] );
I.angle     = double( I.angle );

I.altitude  = ncread( file, 'altitude', [1], [Inf] );
I.altitude  = double( I.altitude );

I.latitude  = ncread( file, 'latitude', [1], [Inf] );
I.latitude  = double( I.latitude );

I.longitude = ncread( file, 'longitude', [1], [Inf] );
I.longitude = double( I.longitude );

I.platform_pitch_angle   = ncread( file, 'platform_pitch_angle', [1], [Inf] );
I.platform_pitch_angle   = double( I.platform_pitch_angle );

I.platform_roll_angle    = ncread( file, 'platform_roll_angle', [1], [Inf] );
I.platform_roll_angle    = double( I.platform_roll_angle );

I.platform_orientation   = ncread( file, 'platform_orientation', [1], [Inf] );
I.platform_orientation   = double( I.platform_orientation );

I.sensor_view_angle      = ncread( file, 'sensor_view_angle', [1], [Inf] );
I.sensor_view_angle      = double( I.sensor_view_angle );

I.sensor_azimuth_angle   = ncread( file, 'sensor_azimuth_angle', [1], [Inf] );
I.sensor_azimuth_angle   = double( I.sensor_azimuth_angle );

I.detected_polarisation  = ncread( file, 'detected_polarisation', [1 1], [Inf Inf] );
I.detected_polarisation  = double( I.detected_polarisation );

I.brightness_temperature = ncread( file, 'brightness_temperature', ...
                                   [1 1], [Inf Inf] );
I.brightness_temperature = double( I.brightness_temperature );

try
  I.brightness_temperature_random_error = ...
      ncread( file, 'brightness_temperature_random_error', [1 1], [Inf Inf] );
  I.brightness_temperature_random_error = ...
      double( I.brightness_temperature_random_error );
end

I.brightness_temperature_positive_error = ...
    ncread( file, 'brightness_temperature_positive_error', [1 1], [Inf Inf] );
I.brightness_temperature_positive_error = ...
    double( I.brightness_temperature_positive_error );

I.brightness_temperature_negative_error = ...
    ncread( file, 'brightness_temperature_negative_error', [1 1], [Inf Inf] );
I.brightness_temperature_negative_error = ...
    double( I.brightness_temperature_negative_error );

I.calibration_interpolation_factor = ...
    ncread( file, 'calibration_interpolation_factor', [1 1], [Inf Inf] );
I.calibration_interpolation_factor = ...
    double( I.calibration_interpolation_factor );

