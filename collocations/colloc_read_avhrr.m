function data = colloc_read_avhrr(file, channels)

% colloc_read_avhrr Read AVHRR l1b data for collocating
%
% This file reads data from a AVHRR l1b radiometer file and rearranges the
% fields to the format that collocate_granule and colloc_process_* use to
% respectively collocate or acquire information. The result is a structure
% that has at least 'time', 'lat' and 'lon'.
%
% FORMAT
%
%   data = colloc_read_avhrr(file[, channels])
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

[fp{1:4}] = fileparts(file);
basename = fp{2};
outfile = fullfile('/tmp', [basename '.nc']);
infile = fullfile('/tmp', basename);
logtext(1, 'Converting from l1b to netcdf\n');
command = ['java -jar ' colloc_config('sat2netcdf') ' -nogui ' chanstr ' -latlon -temperature -avhrr ' infile ' -outputdir /tmp'];
chdir(fileparts(colloc_config('sat2netcdf')));
gunzip(file, '/tmp/');
[status, result] = system(command);
chdir(cwd);

logtext(1, 'Reading data\n');
data = loadncvar(outfile, [{'lat', 'lon', 'scanLineUTC'}, ...
    chans]);

delete(infile);
delete(outfile);

% convert time from milliseconds to seconds

logtext(1, 'Putting data in order\n');
data.time = double(data.scanLineUTC)/1000;

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% add file

data.file = file;

cd(cwd);