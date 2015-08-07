% READ_ISMAR_L1B   Reading of ISMAR and MARSS L1B data  
%
%   All variables are extracted. Date and time data are combined and
%   returned as modified julain date (MJD).
%   
%   Example result:
%     >> I=read_ismar('marss_20150308_b891_firstlook.nc')
%     I = 
%
%                            mjd: [102240x1 double]
%                        channel: [5x9 char]
%                          angle: [102240x1 double]
%                       altitude: [102240x1 double]
%                       latitude: [102240x1 double]
%                      longitude: [102240x1 double]
%           platform_pitch_angle: [102240x1 double]
%            platform_roll_angle: [102240x1 double]
%           platform_orientation: [102240x1 double]
%              sensor_view_angle: [102240x1 double]
%          detected_polarisation: [5x102240 double]
%         brightness_temperature: [5x102240 double]
%
% FORMAT   I = read_ismar_l1b(file)
%
% OUT   I      Structure with L1b data.
% IN    file   Name of file to read.

% 2015-08-07  Mainly written byu Bent Rydberg. Polished and added to Atmlab
% by Patrick.

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
I.mjd    = time;


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

I.detected_polarisation  = ncread( file, 'detected_polarisation', ...
                                   [1 1], [Inf Inf] );
I.detected_polarisation  = double( I.detected_polarisation );

I.brightness_temperature = ncread( file, 'brightness_temperature', ...
                                   [1 1], [Inf Inf] );
I.brightness_temperature = double( I.brightness_temperature );

