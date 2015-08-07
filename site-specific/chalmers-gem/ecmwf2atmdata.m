% ECMWF2ATMDATA  Loads ECMWF-data into atmdata structure
%
%  This function reads the ECMWF data used in the Odin-SMR operational
%  level2 processing into an atmdata structure. 
%
% FORMAT   G = ecmwf2atmdata(infiles,parameter,p_grid,lat_limits,lon_limits)
% 
% OUT      G          atmdata structure  
%
% IN       infiles    Name of the files to read (cell with filenames)
%          parameter  parameter to read in, options are
%                     'Temperature', 'H2O', 'O3', and 'Altitude'
%          p_grid     pressure grid that data will be interpolated onto
%          lat_limits latitude limits filter (vector of length 2) 
%          lon_limits longitude limits filter (vector of length 2)  
%          N.B. longitude (0 -- 359), latitude (-90 -- 90)
%
% Example usage:
%
%  file1 = '/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_12.NC';
%  file2 = '/home/bengt/work/ASG/Data/ODIN_NWP_2014_08_11_18.NC';
%  infiles = {file1, file2}
%  parameter = 'Temperature'; 
%  lat_limits = [-30 30]; 
%  lon_limits = [20 40]; 
%  p_grid = z2p_simple([0:1e3:25e3 30e3:5e3:70e3]);
%  [G] = ecmwf2atmdata(infiles,parameter,p_grid,lat_limits,lon_limits);
%
%  G =
%
%          TYPE: 'atmdata'
%          NAME: 'ECMWF'
%          SOURCE: {1x2 cell}
%          DIM: 4
%          DATA: [4-D double]
%          DATA_NAME: 'Temperature'
%          DATA_UNIT: 'K'
%          GRID1: [35x1 double]
%          GRID1_NAME: 'Pressure'
%          GRID1_UNIT: 'Pa'
%          GRID2: [61x1 double]
%          GRID2_NAME: 'Latitude'
%          GRID2_UNIT: 'deg'
%          GRID3: [21x1 double]
%          GRID3_NAME: 'Longitude'
%          GRID3_UNIT: 'deg'
%          GRID4: [2x2 double]
%          GRID4_NAME: 'MJD'
%          GRID4_UNIT: 'mjd'
%

% 2014-08-14  Created by Bengt Rydberg

function [G] = ecmwf2atmdata(infiles,parameter,p_grid,lat_limits,lon_limits)  

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
    error('Valid parameter options are: Temperature, Altitude, H2O ,or, O3.')
  end 
  if ~(isequal(parameter, 'Temperature') | ...
       isequal(parameter, 'H2O') | ...
       isequal(parameter, 'O3') | ...
       isequal(parameter, 'Altitude'))
    error('Valid parameter options are: Temperature , Altitude, H2O, or, O3.')
  end
  if ~isvector(p_grid)
    error('p_grid must be a vector.')
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
  Gi(i)=read_ecmwf_file(infiles{i},parameter,p_grid,lat_limits,lon_limits);
end

%create a single G atmdata structure
G=add_ecmwf_atmdata(Gi);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [G]=add_ecmwf_atmdata(Gi)

%write the Gi(i) into a single G atmdata structure 
data=zeros(size(Gi(1).DATA,1),size(Gi(1).DATA,2),size(Gi(1).DATA,3),length(Gi));
mjd=zeros(length(Gi),1);
for i=1:length(Gi)
  data(:,:,:,i)=Gi(i).DATA;
  source{i}=Gi(i).SOURCE;
  mjd(i)=Gi(i).GRID4;
end

G = Gi(1);
G.DATA = data;
G.GRID4 = mjd;
G.SOURCE=source;
%flip dimensions
G.DATA = flipdim(G.DATA,2);
G.GRID2 = flipdim(G.GRID2,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function G=read_ecmwf_file(infile,parameter,p_grid,lat_limits,lon_limits)
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
start = [lonind(1) latind(1) 1];
count = [length(lonind) length(latind) inf];

%Read in pressure data (3-D variation)
P = ncread(infile, '/Data_3D/P', start, count);

%Read in the desired data
if isequal(parameter, 'Temperature')
  data = ncread(infile, '/Data_3D/T', start, count);
  unit= ncreadatt(infile, '/Data_3D/T', 'units');
  data_name = 'Temperature';
  %dimensions are: data=f(longitude, latitude, pressure)
elseif isequal(parameter, 'O3')
  data = ncread(infile, '/Data_3D/O3', start, count);
  unit= ncreadatt(infile, '/Data_3D/O3', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    O3molm=48.00*1e-3; %Kg/mol
    data = mixr2vmr( data, O3molm );
    data_name = 'Volume mixing ratio';
    unit = '-';
   end
elseif isequal(parameter, 'H2O')
  data = ncread(infile, '/Data_3D/Q', start, count);
  unit= ncreadatt(infile, '/Data_3D/Q', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    H2Omolm=18.00*1e-3; %Kg/mol
    data = mixr2vmr( data, H2Omolm );
    data_name = 'Volume mixing ratio';
    unit = '-';
  end
elseif isequal(parameter, 'Altitude')
  data = ncread(infile, '/Data_3D/GMH', start, count);
  unit= ncreadatt(infile, '/Data_3D/GMH', 'units');
  data_name = 'Altitude';
end

%interpolate data on a the pressure grid (p_grid)
s1 = length(p_grid);
s2 = length(lat);
s3 = length(lon);
data_out = zeros(s1, s2, s3,1);
for i = 1:s2
  for j = 1:s3
    x=squeeze(log(P(j, i, :)));
    y=squeeze(data(j, i, :));
    ind=find(~isnan(x) & ~isnan(y));
    data_out(:, i, j,1) = interp1(x(ind), y(ind), log(p_grid),...
                          'linear','extrap');        
  end
end

%set negative values to 0
if (isequal(parameter,'H2O') | isequal(parameter,'O3'))
  ind = find(data_out<0);
  data(ind)=0;

end

G = atmdata_empty( 4 );
G.NAME=parameter;
G.DATA = data_out;
G.DATA_NAME = data_name;
G.DATA_UNIT = unit;
G.GRID1 = vec2col(p_grid);
G.GRID2 = vec2col(lat);
G.GRID3 = vec2col(lon);
G.GRID4 = vec2col(mjd);
G.GRID4_NAME='MJD';
G.GRID4_UNIT='mjd';
G.SOURCE=infile;




