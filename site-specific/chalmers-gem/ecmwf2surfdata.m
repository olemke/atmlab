%ECMWF2SURFDATA Loads ECMWF-data into surfdata structure
%
%  This function reads the ECMWF data used in the Odin-SMR operational
%  level2 processing into surfdata structure. 
%
% FORMAT   G = ecmwf2surfdata( infiles, parameter, lat_limits, lon_limits )
% 
% OUT      G          atmdata structure  
%
% IN       infiles    Name of the files to read (cell with filenames)
%          parameter  parameter to read in, options are
%                     'p_surface'
%          lat_limits latitude limits filter (vector of length 2) 
%          lon_limits longitude limits filter (vector of length 2)  
%          N.B. longitude (0 -- 359), latitude (-90 -- 90)
%
% Example usage:
%
%  file1 = '/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_12.NC';
%  file2 = '/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_18.NC';
%  infiles = {file1, file2}
%  parameter = 'p_surface'; 
%  lat_limits = [-30 30]; 
%  lon_limits = [20 40]; 
%  [G] = ecmwf2surfdata(infiles,parameter,lat_limits,lon_limits);
%  G =
%   TYPE: 'surfdata'
%   NAME: 'ECMWF'
%   SOURCE: {'/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_12.NC'  '/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_18.NC'}
%   DIM: 3
%   DATA: [61x21x2 double]
%   DATA_NAME: 'Surface Pressure'
%   DATA_UNIT: 'Pa'
%   GRID1: [61x1 double]
%   GRID1_NAME: 'Latitude'
%   GRID1_UNIT: 'deg'
%   GRID2: [21x1 double]
%   GRID2_NAME: 'Longitude'
%   GRID2_UNIT: 'deg'
%   GRID3: [2x1 double]
%   GRID3_NAME: 'MJD'
%   GRID3_UNIT: 'mjd'

% 2014-08-14  Created by Bengt Rydberg
function [G] = ecmwf2surfdata(infiles,parameter,lat_limits,lon_limits)  

strictAssert=atmlab('STRICT_ASSERT');

if strictAssert
  %Check input paramters
  if ~iscell(infiles)
    error('infiles must be list of input files in a cell.')
  end

  for i=1:length(infiles)
    if ~exist(infiles{i}, 'file') == 2 
      error(['The input file: ',infiles{i},' does not exist.'])
    end
  end 

  if ~ischar(parameter)
    error('Valid parameter options are: Surface pressure.')
  end 
  if ~isequal(lower(parameter), 'surface pressure') 
    error('Valid parameter options are: Surface pressure.')
  end
  if ~isvector(lat_limits)
     error('lat_limits must be a vector of length 2.')
  end
  if length(lat_limits)~=2
    error('lat_limits must be a vector of length 2.')
  end
  if lat_limits(1)>lat_limits(2)
    error('lat_limits(1) must be smaller than lat_limits(2).')   
  end
  if ~isvector(lon_limits)
    error('lon_limits must be a vector of length 2.')
  end
  if length(lon_limits)~=2
    error('lon_limits must be a vector of length 2.')
  end
  if lon_limits(1)>lon_limits(2)
    error('lon_limits(1) must be smaller than lon_limits(2).')   
  end
  %end of input checks
end

%read in the data for each file
for i=1:length(infiles)
  Gi(i)=read_ecmwf_file(infiles{i},parameter,lat_limits,lon_limits);
end

%create a single G atmdata structure
G=add_ecmwf_atmdata(Gi);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [G]=add_ecmwf_atmdata(Gi)

%write the Gi(i) into a single G surfdata structure 

data=zeros(size(Gi(1).DATA,1),size(Gi(1).DATA,2),length(Gi));
mjd=zeros(length(Gi),1);
for i=1:length(Gi)
  data(:,:,i)=Gi(i).DATA;
  source{i}=Gi(i).SOURCE;
  mjd(i)=Gi(i).GRID3;
end

G = Gi(1);
G.DATA = data;
G.GRID3 = mjd;
G.SOURCE=source;
%flip dimensions
G.DATA = flipdim(G.DATA,1);
G.GRID1 = flipdim(G.GRID1,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function G=read_ecmwf_file(infile,parameter,lat_limits,lon_limits)
%this subfunction reads in data from a single file

%extract time from the filename
[path,name,ext] = fileparts(infile);
dateinfo = regexp(name, '_', 'split');
year = str2num(dateinfo{3});
month = str2num(dateinfo{4});
day = str2num(dateinfo{5});
hour= str2num(dateinfo{6});
mjd = [date2mjd(year,month,day,hour)];


%longitude (0 -- 359), latitude (90 -- -90)
%read in lat and lon data from file
lat = ncread(infile, '/Geolocation/lat');
lon = ncread(infile, '/Geolocation/lon');

%find indices of the desired data
latind = find(lat>=lat_limits(1) & lat<=lat_limits(2));
lonind = find(lon>=lon_limits(1) & lon<=lon_limits(2));
lat = lat(latind);
lon = lon(lonind);

%Prepare to only read in the desired data from the file
start = [lonind(1) latind(1)];
count = [length(lonind) length(latind)];

if isequal(lower(parameter), 'surface pressure')
  data = ncread(infile, '/Data_2D/SP', start, count);
  unit= ncreadatt(infile, '/Data_2D/SP', 'units');
  data_name='Surface Pressure';
end

G = surfdata_empty(3); 
G.NAME=data_name;
G.DATA = data';
G.DATA_NAME = data_name;
G.DATA_UNIT = unit;
G.GRID1 = vec2col(lat);
G.GRID2 = vec2col(lon);
G.GRID3 = vec2col(mjd);
G.GRID3_NAME='MJD';
G.GRID3_UNIT='mjd';
G.SOURCE=infile;


