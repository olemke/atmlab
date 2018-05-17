% READ_MHS_DATA READS METOP MHS DATA FILES
%
% The function reads data from a single METOP /
% Microwave Humidity Sounder(MHS) level1b file.
% The MHS instrument scans the surface of the Earth,
% taking 90 pixels across the Earth view each scan.
% At nadir, the instrument footprint corresponds to a
% circle of diameter approximately 16 km. The full swath
% of the instrument is approximately 1920 km.
%
% FORMAT DATA = READ_MHS_DATA(filename)
%
% IN  filename  Full file name of the level1b file to read
%
% OUT data      Structure with fields
%                 latitude
%                    latitude [degrees north] [-90 to 90]
%                  longitude
%                    longtude [degrees east] [-180 to 180]
%                  satellite_zenith
%                    angular relation for the earth view
%                  satellite_azimuth
%                    angular relation for the earth view
%                  solar_zenith
%                    angular relation for the earth view
%                  solar_azimuth
%                    angular relation for the earth view
%                  degraded_proc_MDR
%                    Quality of MDR has been degraded due to
%                    a processing degradation
%                  degraded_ins_MDR
%                    Quality of MDR has been degraded due to
%                    an instrument degradation
%                  surface_properties
%                    (0 = WATER, 1 = MIXED,COAST, 2 = LAND)
%                  terrain_elevation
%                    average terrain elevation
%                  tb_channel_1
%                    brightness temperature channel 1 (89.0 GHz)
%                  tb_channel_2
%                    brightness temperature channel 2 (157 GHz)
%                  tb_channel_3
%                    brightness temperature channel 3 (183.3 +/- 1.0 GHz)
%                  tb_channel_4
%                    brightness temperature channel 4 (183.3 +/- 3.0 GHz)
%                  tb_channel_5
%                    brightness temperature channel 5 (190.3 GHz)
%                  start_sensing_data_time
%                    (matlab datenum)
%                  end_sensing_data_time
%                    (matlab datenum)
%                  subsat_track_start_lon
%                    subsatellite longitude position at first
%                    measurement
%                  subsat_track_start_lat
%                    subsatellite latitude position at first
%                    measurement
%                  subsat_track_end_lon
%                    subsatellite longitude position at last
%                    measurement
%                  subsat_track_end_lat
%                     subsatellite latitude position at last
%                    measurement
%                  orbit_inclination
%                    (degrees)
%                  orbit_period
%                    (seconds)
%                  equator_crossing_date_time
%                    (matlab datenum)
%
% 2018-05-17 Bengt Rydberg

function data = read_mhs_data(infile)

data.latitude = ncread(infile, '/lat', [1, 1], [Inf, Inf]);
data.longitude = ncread(infile, '/lon', [1, 1], [Inf, Inf]);

data.satellite_zenith = ncread(infile, '/satellite_zenith', [1, 1], [Inf, Inf]);
data.satellite_azimuth = ncread(infile, '/satellite_azimuth', [1, 1], [Inf, Inf]);

data.solar_zenith = ncread(infile, '/solar_zenith', [1, 1], [Inf, Inf]);
data.solar_azimuth = ncread(infile, '/solar_azimuth', [1, 1], [Inf, Inf]);

data.degraded_proc_MDR = ncread(infile, '/degraded_proc_MDR', 1, Inf);
data.degraded_ins_MDR = ncread(infile, '/degraded_ins_MDR', 1, Inf);

data.surface_properties = ncread(infile, '/surface_properties', [1, 1], [Inf, Inf]);
data.terrain_elevation = ncread(infile, '/terrain_elevation', [1, 1], [Inf, Inf]);

data.tb_channel_1 = radiance_to_tb(infile, 1);
data.tb_channel_2 = radiance_to_tb(infile, 2);
data.tb_channel_3 = radiance_to_tb(infile, 3);
data.tb_channel_4 = radiance_to_tb(infile, 4);
data.tb_channel_5 = radiance_to_tb(infile, 5);


data.start_sensing_data_time = datenum( ...
  ncreadatt(infile, '/', 'start_sensing_data_time'), ...
  'yyyymmddHHMMSSZ');
data.end_sensing_data_time = datenum( ...
  ncreadatt(infile, '/', 'end_sensing_data_time'), ...
  'yyyymmddHHMMSSZ');

data.subsat_track_start_lon = double(ncreadatt(infile, '/', 'subsat_track_start_lon')) * 1e-3;
data.subsat_track_start_lat = double(ncreadatt(infile, '/', 'subsat_track_start_lat')) * 1e-3;

data.subsat_track_end_lon = double(ncreadatt(infile, '/', 'subsat_track_end_lon')) * 1e-3;
data.subsat_track_end_lat = double(ncreadatt(infile, '/', 'subsat_track_end_lat')) * 1e-3;

data.orbit_inclination = double(ncreadatt(infile, '/', 'orbit_inclination')) * 1e-3;
data.orbit_period = double(ncreadatt(infile, '/', 'rev_orbit_period'));
data.equator_crossing_date_time = datenum( ...
  ncreadatt(infile, '/', 'equator_crossing_date_time'), ...
  'yyyymmddHHMMSSFFFZ');



function tb = radiance_to_tb(infile, channel)
    c1 = ncreadatt(infile, '/', 'c1');
    c2 = ncreadatt(infile, '/', 'c2');
    wnc = ncreadatt(infile, '/', sprintf('channel_%d_wnc', channel));
    beta = ncreadatt(infile, '/', sprintf('channel_%d_beta', channel));
    alpha = ncreadatt(infile, '/', sprintf('channel_%d_alpha', channel));
    rad = ncread(infile, sprintf('/channel_%d', channel), [1, 1], [Inf, Inf]);
    tb = ((c2 * wnc) ./ log(1 + (c1 * wnc ^ 3) ./ rad) - beta) / alpha;


