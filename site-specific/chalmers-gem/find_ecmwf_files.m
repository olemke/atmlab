% FIND_ECMWF_FILES finds available ECMWF/ERA files between two given dates
%
% FORMAT filelist = find_ecmwf_files( mjdstart, mjdend, [source, level])
%
% OUT    filelist a cell with filenames
%
% IN     mjdstart mjd (scalar)
%        mjdend   mjd (scalar)
%        source   data source: ecmwf or era (ecmwf is default)
%        level    pressure level (pl) or surface level (sfc) 
%                 (pl is default)
% Example usage:
%  mjdstart = date2mjd(2014, 8, 8, 5);
%  mjdend = date2mjd(2014, 8, 10, 6);
%  filelist = find_ecmwf_files( mjdstart, mjdend)
%  filelist{1}=
%        
%   /odin/external/ecmwfNCD/2014/08/ODIN_NWP_2014_08_08_06.NC
%
%  or
%  
%  filelist = find_ecmwf_files( mjdstart, mjdend, 'era', 'pl')

% 2014-08-14  Created by Bengt Rydberg
  
function [filelist] = find_ecmwf_files( mjdstart, mjdend, source, level)


ecmwf = true;
if nargin<3
  ecmwfdir='/odin/external/ecmwfNCD';
elseif strcmp(source,'era');
  if strcmp( hostname, 'virga' )  |  strcmp( whoami, 'patrick2' )
    ecmwfdir='~/Extdata/ERA-Interim/';
  else
    ecmwfdir='/misc/pearl/extdata/ERA-Interim/';
  end
  ecmwf = false;
elseif strcmp(source,'ecmwf');
  ecmwfdir='/odin/external/ecmwfNCD';
else
  error('Unrecognized source. Must be "era" or "ecmwf"')
end

if nargin<4
  level = 'pl';
elseif ~strcmp(level,'pl') & ~strcmp(level,'sfc');
  error('Unrecognized level. Must be "pl" or "sfc".')
end

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
 
  if ecmwf 
    filename = sprintf('ODIN_NWP_%d_%02d_%02d_%02d.NC', ...
                     year, month, day, hour);
  else
    filename = sprintf('ei_%s_%d-%02d-%02d-%02d.nc', ...
                     level, year, month, day, hour);
  end
  year     = sprintf('%d', year);
  month    = sprintf('%02d', month);
  file     = fullfile(ecmwfdir, year, month, filename);
  
  if exist(file, 'file') == 2
    filelist{i} =file;   
  end
end

