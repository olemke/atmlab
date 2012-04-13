function data = common_read_avhrr(file, channels)

% common_read_avhrr Read AVHRR l1b data and arrange in a common format
%
% This file reads data from a AVHRR l1b radiometer file and rearranges the
% fields to the common format, used by collocation codes.
%
% FORMAT
%
%   data = common_read_avhrr(file[, channels])
%
% IN
%
%   file        string      Path to l1b file
%   channels    vector      vector of channels to read (defaults to 1:5)
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%                   sza     solar zenith angle (WARNING: naive
%                           interpolation, not angular)
%                   lza     local zenith angle (the same)
%                   raa     relative azimuth angle (the same)
%                   ... and the requested channels ...
%
% $Id$

cwd = pwd;

%% set parameters

if ~exist('channels', 'var')
    channels = 1:5;
end

chanstr = sprintf('-ch%d ', channels);
names = {'albedoCh1', 'albedoCh2', {'albedoCh3A', 'brightnessTempCh3B'}, 'brightnessTempCh4', 'brightnessTempCh5'};
chans = cat(2, names{channels});

% convert from l1b to netcdf

[fp{1:3}] = fileparts(file);
basename = fp{2};
outfile = fullfile(atmlab('WORK_AREA'), [basename '.nc']);
infile = fullfile(atmlab('WORK_AREA'), basename);
logtext(atmlab('OUT'), 'Converting from l1b to netcdf\n');
command = ['java -jar ' datasets_config('sat2netcdf') ' ' ...
    datasets_constants('sat2netcdf_flags') ' ' chanstr ' -avhrr ' infile ...
    ' -outputdir ' atmlab('WORK_AREA')];
chdir(fileparts(datasets_config('sat2netcdf')));
exec_system_cmd(['gunzip -c ' file '>' infile]); % 3x faster than gunzip
%gunzip(file, atmlab('WORK_AREA'));
exec_system_cmd(command);
chdir(cwd);

logtext(atmlab('OUT'), 'Reading data\n');
data = loadncvar(outfile, [{'lat', 'lon', 'scanLineUTC', 'formatVersion', ...
    'formatVersionYear', 'formatVersionDayOfYear', 'startYear', 'startDayOfYear', ...
    'cloudFlag', 'chan3A3B'}, ...
    chans]);
data.version = sprintf('year-doy:version = %d-%d:%d', data.formatVersionYear, data.formatVersionDayOfYear, data.formatVersion);
logtext(atmlab('OUT'), 'Reading metadata not in NetCDF file\n')
metadata = avhrr_gac_read_data(infile);
delete(infile);
delete(outfile);

% calculate epoch
datestruct = dayofyear_inverse(data.startYear, data.startDayOfYear);
data.epoch = round(date2unixsecs(double(datestruct.year), double(datestruct.month), double(datestruct.day)));

% convert time from milliseconds to seconds

logtext(atmlab('OUT'), 'Putting data in order\n');
data.time = double(data.scanLineUTC)/1000;

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% add file/version

data.file = file;

% add angles
x = 1:405;
x_sel = 5:8:405;
data.sza = spline(x_sel, metadata.sza, x);
data.lza = spline(x_sel, metadata.lza, x);
data.raa = spline(x_sel, metadata.raa, x);
cd(cwd);

% remove redundant fields
data = rmfield(data, {'formatVersion', 'formatVersionYear', 'formatVersionDayOfYear'});
