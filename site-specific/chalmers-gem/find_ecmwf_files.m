% FIND_ECMWF_FILES finds available ECMWF files between two given dates
%
% FORMAT filelist = find_ecmwf_files( mjdstart, mjdend)
%
% OUT    filelist a cell with filenames
%
% IN     mjdstart mjd (scalar)
%        mjdend   mjd (scalar)
%
% Example usage:
%  mjdstart = date2mjd(2014, 8, 8, 5);
%  mjdend = date2mjd(2014, 8, 10, 6);
%  filelist = find_ecmwf_files( mjdstart, mjdend)
%  filelist{1}=
%        
%   /odin/external/ecmwfNCD/2014/08/ODIN_NWP_2014_08_08_06.NC
%

% 2014-08-14  Created by Bengt Rydberg
  
function [filelist] = find_ecmwf_files( mjdstart, mjdend)

ecmwfdir='/odin/external/ecmwfNCD';

%create a vecor of mjd values where we expect to have ECMWF-files.
%We expect to have ECMWF-files for hour 0,6,12,18 every day.
mjd_diff = mjdstart - floor(mjdstart);
mjd1     = floor(mjdstart) + ceil(mjd_diff/0.25) * 0.25;
mjd_diff = mjdend - floor(mjdend);
mjd2     = floor(mjdend) + floor(mjd_diff/0.25) * 0.25;
mjdvec   = mjd1:0.25:mjd2;



filelist={};

for i = 1:length(mjdvec)

  [year, month, day, hour] = mjd2date(mjdvec(i));
  
  filename = sprintf('ODIN_NWP_%d_%02d_%02d_%02d.NC', ...
                     year, month, day, hour);
  year     = sprintf('%d', year);
  month    = sprintf('%02d', month);
  file     = fullfile(ecmwfdir, year, month, filename);
  
  if exist(file, 'file') == 2
    filelist{i} =file;   
  end
end

