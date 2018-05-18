% ERA5_PRESSURE_READ   Loads ERA5 pressure level data into atmdata structure
%
% FORMAT   G = era5_pressure_read(infile,parameter,lat_limits,lon_limits,mjd_limits)
% 
% OUT      G          atmdata structure array
% IN       infile     Name of the file to read. 
%          parameter  parameter to read in, options are:
%                     'Temperature', 'Geopotential', 'Altitude', 'H2O', 'O3',
%                     'IWC', 'LWC'
%          lat_limits latitude limits filter (vector of length 2, values in [-90,90]) 
%          lon_limits longitude limits filter (vector of length 2, both
%                     +-180 and 0-360 can be used) 
%          mjd_limits mjd limits filter (vector of length 2)  

% 2018-05-18  Version for ERA5, based on ERA-Interim version
% 2015-08-20  Adopted to handle lon_limits following [-180,180]
% 2014-10-03  Created by Bengt Rydberg

function G = era5_pressure_read(infile,parameter,lat_limits,lon_limits,mjd_limits)  


if atmlab('STRICT_ASSERT')
  %Check input paramters
  if ~ischar(infile)
    error('infile must be a string with a filename.')
  end

  if ~exist(infile,'file') == 2 
      error(['The input file: ',infile,' does not exist.'])
  end

  if ~ischar(parameter)
    error( 'Input argument *parameter* must be a string.' )
  end 
  
  if ~(isequal(lower(parameter), 'temperature') | ...
       isequal(lower(parameter), 'geopotential') | ...
       isequal(lower(parameter), 'altitude') | ...
       isequal(lower(parameter), 'h2o') | ...
       isequal(lower(parameter), 'o3') | ...
       isequal(lower(parameter), 'lwc') | ...
       isequal(lower(parameter), 'iwc') )
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
end


% Check if lon_limits are inside [0,360]. Cropping can then be done already
% in reading
if lon_limits(1) < 0
  do_loncrop  = true;
  lon_limits0 = lon_limits;
  lon_limits  = [0 360];   % To read all lon
else
  do_loncrop  = false;
end


% longitude (0 -- 359), latitude (90 -- -90)
% read in lat and lon data from file
lat = ncread( infile, '/latitude' );
lon = ncread( infile, '/longitude' );
lat = double( lat );
lon = double( lon );
assert( lon(1) >= 0 );


% time: hours since 1900-01-01
time  = ncread( infile, '/time' );
time  = double( time );
mjd0  = date2mjd( 1900, 1, 1 );
mjd   = mjd0 + time/24;


% find indices of the desired data
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


% Prepare to only read in the desired data from the file
start = [ lonind(1) latind(1) 1 mjdind(1) ];
count = [ length(lonind) length(latind) inf length(mjd) ];


% Read in pressure [mbar]
P = ncread( infile, '/level' );
P = double( P );
% convert to Pa
P = P*100;


% Read in the desired data
if isequal( lower(parameter), 'temperature' )
  data      = ncread( infile, '/t', start, count );
  %dimensions are: data=f(longitude, latitude, pressure,time)
  unit      = ncreadatt( infile, '/t', 'units' );
  data_name = 'Temperature';
  if strcmp( unit, 'K' )
  else
    error( 'Unknow unit for %s.', parameter );
  end  
  
elseif isequal( lower(parameter), 'geopotential' )
  data      = ncread( infile, '/z', start, count );
  unit      = ncreadatt( infile, '/z', 'units' );
  data_name = 'Geopotential';
  if strcmp( unit, 'm**2 s**-2' )
  else
    error( 'Unknow unit for %s.', parameter );
  end  

elseif isequal( lower(parameter), 'altitude' )   
  data      = ncread( infile, '/z', start, count);
  unit      = 'm';
  data_name = 'Altitude';
  for i = 1:length(lat)
    s1      = sin( lat(i)/180*pi );
    s2      = sin( 2*lat(i)/180*pi );
    %http://en.wikipedia.org/wiki/Gravity_of_Earth
    gE      = 9.780327*(1+5.3024e-3*s1^2-5.8e-6*s2^2);
    rE      = 6378137./(1.006803-0.006706*s1^2);
    data(:,i,:,:) = rE*( gE*rE ./ ( gE*rE - data(:,i,:,:) ) - 1 );  
  end

elseif isequal( lower(parameter), 'h2o' )
  data      = ncread( infile, '/q', start, count );
  unit      = ncreadatt( infile, '/q', 'units' );
  data_name = 'Volume mixing ratio';
  if strcmp( unit, 'kg kg**-1' )
    H2Omolm = 18.00*1e-3; %Kg/mol
    data    = mixr2vmr( data, H2Omolm );
    unit = '-';
  else
    error( 'Unknow unit for %s.', parameter );
  end

elseif isequal( lower(parameter), 'o3' )
  data      = ncread( infile, '/o3', start, count );
  unit      = ncreadatt( infile, '/o3', 'units' );
  data_name = 'Volume mixing ratio';
  if strcmp( unit, 'kg kg**-1' )
    O3molm  = 48.00*1e-3; %Kg/mol
    data    = mixr2vmr( data, O3molm );
    unit    = '-';
  else
    error( 'Unknow unit for %s.', parameter );
  end

elseif isequal( lower(parameter), 'iwc' )
  data      = ncread( infile, '/ciwc', start, count );
  temp      = ncread( infile, '/t', start, count );
  unit      = ncreadatt( infile, '/ciwc', 'units' );
  data_name = 'Ice water content';
  if strcmp( unit, 'kg kg**-1' )
    datai = zeros(size(data));
    for i = 1:size(data,3)
      datai(:,:,i,:) = mixr2massconc( ...
          data(:,:,i,:), P(i), temp(:,:,i,:));
    end
    unit = 'kg/m^3';
  else
    error( 'Unknow unit for IWC.' );
  end

elseif isequal( lower(parameter), 'lwc')
  data      = ncread(infile, '/clwc', start, count);
  temp      = ncread(infile, '/t', start, count);
  unit      = ncreadatt(infile, '/clwc', 'units');
  data_name = 'Liquid water content';
  if strncmp(unit,'kg kg**-1',length(unit))
    datai = zeros(size(data));
    for i = 1:size(data,3)
      datai(:,:,i,:) = mixr2massconc( data(:,:,i,:), P(i), temp(:,:,i,:) );
    end
    unit = 'kg/m^3';
  else
    error( 'Unknow unit for %s.', parameter );
  end
  
else
  assert(0);    
end


% set negative values to 0
if isequal(parameter,'H2O')  |  isequal(parameter,'O3')
  data(find(data<0)) = 0;
end


% flip data
% pressure dim
data = flipdim( data, 3 );
P    = flipud( vec2col(P) );
% latitude
data = flipdim( data, 2 );
lat  = flipud( vec2col(lat) );


% init G
G            = atmdata_empty( 4 );
G.NAME       = parameter;
G.DATA       = zeros( length(P), length(lat), length(lon), length(mjd) );
G.DATA_NAME  = data_name;
G.DATA_UNIT  = unit;
G.GRID1      = vec2col(P);
G.GRID2      = vec2col(lat);
G.GRID3      = vec2col(lon);
G.GRID4      = vec2col(mjd);
G.GRID4_NAME = 'MJD';
G.GRID4_UNIT = 'mjd';
G.SOURCE     = infile;


% change dimension order
for i = 1:length(P)
  for j = 1:length(lat)
    for k = 1:length(lon)
      for l = 1:length(mjd)
        G.DATA(i,j,k,l) = data(k,j,i,l);
      end
    end
  end
end


% crop in lon remaining?
if do_loncrop
  % We add 360 to really cover all longitudes
  lon_tmp  = [ G.GRID2; 360 ];
  data     = zeros( size(G.DATA,1), size(G.DATA,2), ...
                    size(G.DATA,3)+1, size(G.DATA,4) );
  data(:,:,1:end-1,:) = G.DATA;
  data(:,:,end,:)     = G.DATA(:,:,end,:);
  %  
  [lon,i]     = adjust_to_lonlimits( G.GRID3, lon_limits0 );
  i           = find(i);
  [G.GRID3,j] = unique( lon(i) );
  G.DATA      = G.DATA(:,:,i(j),:);
end
