function data = avhrr_gac_read_data(filename)

% avhrr_gac_read_data Read AVHRR GAC l1b data (incomplete)
%
% Read data directly from AVHRR GAC l1b. Note that l1b is uncalibrated and that
% this function does not read actual measurements. To read actual AVHRR GAC
% measurements, use sat2netcdf to convert to netcdf and use a netcdf
% reading routine. However, this does not include all information, and in
% the long run it would be good to read it directly.
%
% FORMAT
%
%   data = avhrr_gac_read_data(filename)
%
% IN
%
%   filename    string      path to l1b AVHRR GAC file
%
% OUT
%
%   data        structure   fields listed below
%       sza     single      solar zenith angle (pos. 5:8:405)
%       lza     single      local zenith angle (pos. 5:8:405)
%       raa     single      relative azimuth angle (sun/sat; pos. 5:8:405)
%
% $Id$

record_size = 4608;
stat = dir(filename);
file_size = stat.bytes;
n_records = file_size/record_size-1;
n_angles = 51; % only 51 from 405 are given
angles_start = 327;
sza_pos = 1:3:(3*51);
lza_pos = 2:3:(3*51);
raa_pos = 3:3:(3*51);

data.sza = zeros(n_records, n_angles, 'single');
data.lza = zeros(size(data.sza), 'single');
data.raa = zeros(size(data.lza), 'single');

fp = fopen(filename, 'r');
for i = 1:n_records
    fseek(fp, record_size*i + angles_start, 'bof');
    angles = fread(fp, n_angles*3, 'int16');
    data.sza(i, :) = angles(sza_pos)/100;
    data.lza(i, :) = angles(lza_pos)/100;
    data.raa(i, :) = angles(raa_pos)/100;
end
fclose(fp);
