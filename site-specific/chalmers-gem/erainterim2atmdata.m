% ERAINTERIM2ATMDATA   Loads ERA Interim data into atmdata structure
%
%   The function can read and merge multiple files. This option requires
%   that all pressure, latitude and longitude grids are equal. No advanced
%   checking is made, so use the option carefully.
%
% FORMAT   G = erainterim2atmdata(infile,parameter,lat_limits,lon_limits,mjd_limits)
% 
% OUT      G          atmdata structure array
% IN       infile     Name of the file(s) to read. For single file reading
%                     this can be string. Otherwise an array of strings.
%          parameter  parameter to read in, options are
%                     'Temperature', 'H2O', 'O3', 'Geopotential',
%                     'IWC','LWC', and 'Altitude'
%          lat_limits latitude limits filter (vector of length 2, values in [-90,90]) 
%          lon_limits longitude limits filter (vector of length 2, both
%                     +-180 and 0-360 can be used) 
%          mjd_limits mjd limits filter (vector of length 2)  
%
% Example usage:
%
%  file = '/misc/pearl/extdata/DATA4ISMAR/ERAInterim/netcdf-atls03-20141003152955-5939-0631.nc';
%  parameter = 'Temperature'; 
%  lat_limits = [-5 5]; 
%  lon_limits = [30 40]; 
%  mjd_limits = 
%  [G] = erainterim2atmdata(file,parameter,lat_limits,lon_limits,mjd_limits);
%  
%  G =
%
%          TYPE: 'atmdata'
%          NAME: 'Temperature'
%        SOURCE: [1x83 char]
%           DIM: 4
%          DATA: [4-D double]
%     DATA_NAME: 'Temperature'
%     DATA_UNIT: 'K'
%         GRID1: [37x1 double]
%    GRID1_NAME: 'Pressure'
%    GRID1_UNIT: 'Pa'
%         GRID2: [13x1 double]
%    GRID2_NAME: 'Latitude'
%    GRID2_UNIT: 'deg'
%         GRID3: [14x1 double]
%    GRID3_NAME: 'Longitude'
%    GRID3_UNIT: 'deg'
%         GRID4: [3x1 double]
%    GRID4_NAME: 'MJD'
%    GRID4_UNIT: 'mjd'

% 2014-10-03  Created by Bengt Rydberg
% 2015-08-20  Adopted to handle lon_limits following [-180,180]

function [G] = erainterim2atmdata(infile,parameter,lat_limits,lon_limits,mjd_limits)  

%--------------------------------------------------------------------------------
% Special solution for reading/merging of multiple files

if iscellstr(infile)
  %
  if length(infile) == 1
    G = erainterim2atmdata( infile{1}, parameter, lat_limits, lon_limits, ...
                            mjd_limits);
    return;  
  end
  %
  for i = 1 : length(infile)
    H{i} = erainterim2atmdata( infile{i}, parameter, lat_limits, lon_limits, ...
                               mjd_limits);
    mjd1(i) = H{i}.GRID4(1); 
    nmjd(i) = length( H{i}.GRID4 ); 
    %
    if i == 1
      s0 = size( H{i}.DATA );
    else
      s  = size( H{i}.DATA );      
      if any( s ~= s0 )
        error( ['Number of pressures, latitudes or longitudes differs between ' ...
                'files.' ] );
      end
    end
  end
  %
  G = H{1};
  G.DATA  = zeros( [ s0(1:3) sum(nmjd) ] );
  G.GRID4 = zeros( sum(nmjd), 1 );
  %
  [~,o] = sort( mjd1 );
  n = 0;
  %
  for i = 1 : length(infile)
    j   = o(i);
    ind = n+1 : n+nmjd(j);
    n   = n+nmjd(j);
    %
    G.DATA(:,:,:,ind) = H{j}.DATA;
    G.GRID4(ind)      = H{j}.GRID4; 
  end
  %
  return  
end
%--------------------------------------------------------------------------------



if atmlab('STRICT_ASSERT')
  %Check input paramters
  if ~ischar(infile)
    error('infile must be a string with a filename.')
  end

  if ~exist(infile, 'file') == 2 
      error(['The input file: ',infile,' does not exist.'])
  end

  if ~ischar(parameter)
    error('Valid parameter options are: Temperature, H2O ,O3, IWC, LWC, Geopotential, or Altitude.')
  end 
  if ~(isequal(parameter, 'Temperature') | ...
       isequal(parameter, 'H2O') | ...
       isequal(parameter, 'Geopotential') | ...
       isequal(parameter, 'O3') | ...
       isequal(parameter, 'Altitude') | ...
       isequal(parameter, 'LWC') | ...
       isequal(parameter, 'IWC') )
    error('Valid parameter options are: Temperature , H2O, O3, IWC, LWC, Geopotental, or Altitude.')
  end

  chk_lat_limits( lat_limits );
  chk_lon_limits( lon_limits );
  
  if length(mjd_limits)~=2
    error('mjd_limits must be a vector of length 2.')
  end
  if mjd_limits(1)>mjd_limits(2)
    error('mjd_limits(1) must be smaller than mjd_limits(2).')
  end

  %end of input checks
end


% Check if lon_limits are inside [0,360] and cropping can be done already
% in reading
if lon_limits(1) < 0
  do_loncrop  = true;
  lon_limits0 = lon_limits;
  lon_limits  = [0 360];   % To read all lon
else
  do_loncrop  = false;
end


%longitude (0 -- 359), latitude (90 -- -90)
%read in lat and lon data from file
lat = ncread(infile, '/latitude');
lon = ncread(infile, '/longitude');
lat = double(lat);
lon = double(lon);
assert(lon(1)>=0);


%time: hours since 1900-01-01
time  = ncread(infile, '/time');
time  = double(time);
mjd0  = date2mjd(1900,1,1);
mjd   = mjd0 + time/24;


%find indices of the desired data
latind = find(lat>=lat_limits(1) & lat<=lat_limits(2));
lonind = find(lon>=lon_limits(1) & lon<=lon_limits(2));
mjdind = find(mjd>=mjd_limits(1) & mjd<=mjd_limits(2));
%
if isempty(latind)
  error( 'No latitude found. Latitude limits correct?' );
end 
if isempty(lonind)
  error( 'No longitude found. Longitude limits correct?' );
end 
if isempty(mjdind)
  error( 'No MJD found. MJD limits correct?' );
end 
%
lat = lat(latind);
lon = lon(lonind);
mjd = mjd(mjdind);


%Prepare to only read in the desired data from the file
start = [lonind(1) latind(1) 1 mjdind(1)];
count = [length(lonind) length(latind) inf length(mjd)];

%Read in pressure [mbar]
P = ncread(infile, '/level');
P = double(P);
%convert to Pa
P = P*100;

%Read in the desired data
if isequal(parameter, 'Temperature')
  data = ncread(infile, '/t', start, count);
  unit = ncreadatt(infile, '/t', 'units');
  data_name = 'Temperature';
  %dimensions are: data=f(longitude, latitude, pressure,time)

elseif isequal(parameter, 'Geopotential')
  data = ncread(infile, '/z', start, count);
  unit = ncreadatt(infile, '/z', 'units');
  data_name = 'Geopotential';
  %dimensions are: data=f(longitude, latitude, pressure,time)

elseif isequal(parameter, 'Altitude')   
  data = ncread(infile, '/z', start, count);
  unit = ncreadatt(infile, '/z', 'units');
  data_name = 'Altitude';
  unit = 'm';
  for i = 1:length(lat)
    s1 = sin(lat(i)/180*pi);
    s2 = sin(2*lat(i)/180*pi);
    %http://en.wikipedia.org/wiki/Gravity_of_Earth
    gE  = 9.780327*(1+5.3024e-3*s1^2-5.8e-6*s2^2);
    rE  = 6378137./(1.006803-0.006706*s1^2);
    data(:,i,:,:) = rE*( gE*rE ./ ( gE*rE - data(:,i,:,:) ) -1 );  
  end
  %dimensions are: data=f(longitude, latitude, pressure,time)

elseif isequal(parameter, 'O3')
  data = ncread(infile, '/o3', start, count);
  unit= ncreadatt(infile, '/o3', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    O3molm=48.00*1e-3; %Kg/mol
    data = mixr2vmr( data, O3molm );
    data_name = 'Volume mixing ratio';
    unit = '-';
  else
    error( 'Unknow unit for O3.' );
  end

elseif isequal(parameter, 'H2O')
  data = ncread(infile, '/q', start, count);
  unit= ncreadatt(infile, '/q', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    H2Omolm=18.00*1e-3; %Kg/mol
    data = mixr2vmr( data, H2Omolm );
    data_name = 'Volume mixing ratio';
    unit = '-';
  else
    error( 'Unknow unit for H2O.' );
  end

elseif isequal(parameter, 'IWC')
  data = ncread(infile, '/ciwc', start, count);
  temp = ncread(infile, '/t', start, count);
  unit = ncreadatt(infile, '/ciwc', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    datai = zeros(size(data));
    for i = 1:size(data,3)
      datai(:,:,i,:) = mixr2massconc( ...
          data(:,:,i,:), P(i), temp(:,:,i,:));
    end
    data_name = 'Ice water content';
    unit = 'kg/m^3';
  else
    error( 'Unknow unit for IWC.' );
  end

elseif isequal(parameter, 'LWC')
  data = ncread(infile, '/clwc', start, count);
  temp = ncread(infile, '/t', start, count);
  unit = ncreadatt(infile, '/clwc', 'units');
  if strncmp(unit,'kg kg**-1',length(unit))
    datai = zeros(size(data));
    for i = 1:size(data,3)
      datai(:,:,i,:) = mixr2massconc( ...
          data(:,:,i,:), P(i), temp(:,:,i,:));
    end
    data_name = 'Liquid water content';
    unit = 'kg/m^3';
  else
    error( 'Unknow unit for LWC.' );
  end

end


%set negative values to 0
if (isequal(parameter,'H2O') | isequal(parameter,'O3'))
  ind = find(data<0);
  data(ind)=0;
end

%flip data
%pressure dim
data = flipdim(data,3);
P    = flipud(vec2col(P));
%latitude
data = flipdim(data,2);
lat  = flipud(vec2col(lat));

%change dimension
data_out = zeros(length(P),length(lat),length(lon),length(mjd));
for i=1:length(P)
  for j=1:length(lat)
    for k=1:length(lon)
      for l=1:length(mjd)
        data_out(i,j,k,l) = data(k,j,i,l);
      end
    end
  end
end

% fill G
G            = atmdata_empty( 4 );
G.NAME       = parameter;
G.DATA       = data_out;
G.DATA_NAME  = data_name;
G.DATA_UNIT  = unit;
G.GRID1      = vec2col(P);
G.GRID2      = vec2col(lat);
G.GRID3      = vec2col(lon);
G.GRID4      = vec2col(mjd);
G.GRID4_NAME = 'MJD';
G.GRID4_UNIT = 'mjd';
G.SOURCE     = infile;


% crop in lon remaining?
if do_loncrop
  % We add 0 as 360 to really cover all longotudes
  lon_tmp           = [ G.GRID2; 360 ];
  data              = zeros( size(G.DATA,1), size(G.DATA,2), ...
                             size(G.DATA,3)+1, size(G.DATA,4) );
  data(:,:,1:end-1,:) = G.DATA;
  data(:,:,end,:)     = G.DATA(:,:,end,:);
  %  
  [lon,i]     = adjust_to_lonlimits( G.GRID3, lon_limits0 );
  i           = find(i);
  [G.GRID3,j] = sort( lon(i) );
  G.DATA      = G.DATA(:,:,i(j),:);
end
