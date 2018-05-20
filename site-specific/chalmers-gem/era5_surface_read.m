% ERA5_SURFACE_READ   Loads ERA5 surface data into surfdata structure
%
% FORMAT   G = era5_pressure_read(infile,parameter,lat_limits,lon_limits,mjd_limits)
% 
% OUT      G          surfdata structure  
% IN       infile     Name of the file(s) to read. 
%          parameter  parameter to read in, options are
%                     'surface pressure', 'sea surface temperature',
%                     'skin temperature', '2 m temperature', 
%                     'u10' and 'v10'
%          lat_limits latitude limits filter (vector of length 2, values in [-90,90]) 
%          lon_limits longitude limits filter (vector of length 2, both
%                     +-180 and 0-360 can be used) 
%          mjd_limits mjd limits filter (vector of length 2)  

% 2018-05-18  Version for ERA5, based on ERA-Interim version
% 2015-08-20  Adopted to handle lon_limits following [-180,180]
% 2014-10-03  Created by Bengt Rydberg

function [G] = era5_surface_read(infile,parameter,lat_limits,lon_limits,mjd_limits)


if atmlab('STRICT_ASSERT')
  %Check input paramters
  if ~ischar(infile)
    error('infile must be a string with filename.')
  end

  if ~exist(infile, 'file') == 2 
    error(['The input file: ',infile,' does not exist.'])
  end

  if ~ischar(parameter)
    error( 'Input argument *parameter* must be a string.' )
  end 
  
  if ~ ( isequal(lower(parameter), 'surface pressure') | ...
         isequal(lower(parameter), 'sea surface temperature') | ...
         isequal(lower(parameter), 'skin temperature') | ...
         isequal(lower(parameter), '2 m temperature') | ...
         isequal(lower(parameter), 'u10') | ...
         isequal(lower(parameter), 'v10') | ...
         isequal(lower(parameter), 'lwp') | ...
         isequal(lower(parameter), 'iwp') | ...
         isequal(lower(parameter), 'lcc') | ...
         isequal(lower(parameter), 'mcc') | ...
         isequal(lower(parameter), 'hcc')  )       
    error([ 'Valid parameter options are: Surface pressure, sea surface ' ...
            'temperature, skin temperature, and 2 m temperature, u10 and v10' ])
  end

  chk_lat_limits( lat_limits );
  chk_lon_limits( lon_limits );

  if ~isvector(mjd_limits)
    error('mjd_limits must be a vector of length 2.')
  end
  if length(mjd_limits)~=2
    error('mjd_limits must be a vector of length 2.')
  end
  if mjd_limits(1)>mjd_limits(2)
    error('mjd_limits(1) must be smaller than lon_limits(2).')   
  end
  %end of input checks
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
lat = double( lat);
lon = double( lon);
assert( lon(1) >= 0 );


% time: hours since 1900-01-01
time  = ncread( infile, '/time' );
time  = double( time );
mjd0  = date2mjd( 1900, 1, 1 );
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


% Prepare to only read in the desired data from the file
start = [ lonind(1) latind(1) mjdind(1) ];
count = [ length(lonind) length(latind) length(mjdind) ];


% Read in the desired data
if isequal( lower(parameter), 'surface pressure' )
  data      = ncread( infile, '/sp', start, count );
  unit      = ncreadatt( infile, '/sp', 'units' );
  data_name = 'Surface pressure';

elseif isequal( lower(parameter), 'sea surface temperature' )
  data      = ncread( infile, '/sst', start, count );
  unit      = ncreadatt( infile, '/sst', 'units' );
  data_name = 'Sea surface temperature';

elseif isequal( lower(parameter), 'skin temperature' )
  data      = ncread( infile, '/skt', start, count );
  unit      = ncreadatt( infile, '/skt', 'units' );
  data_name = 'Skin temperature';

elseif isequal( lower(parameter), '2 m temperature' )
  data      = ncread( infile, '/t2m', start, count );
  unit      = ncreadatt( infile, '/t2m', 'units' );
  data_name = '2 m temperature';

elseif isequal( lower(parameter), 'u10' )
  data      = ncread( infile, '/u10', start, count );
  unit      = ncreadatt( infile, '/u10', 'units' );
  data_name = 'u10';

elseif isequal( lower(parameter), 'v10' )
  data      = ncread( infile, '/v10', start, count );
  unit      = ncreadatt( infile, '/v10', 'units' );
  data_name = 'v10';

end


% flip data
% latitude
data = flipdim( data, 2 );
lat  = flipud( vec2col(lat) );


% Init G
G            = surfdata_empty(3); 
G.NAME       = data_name;
G.DATA       = zeros( length(lat), length(lon), length(mjd) );
G.DATA_NAME  = data_name;
G.DATA_UNIT  = unit;
G.GRID1      = vec2col(lat);
G.GRID2      = vec2col(lon);
G.GRID3      = vec2col(mjd);
G.GRID3_NAME = 'MJD';
G.GRID3_UNIT = 'mjd';
G.SOURCE     = infile;


%change dimension order
for j = 1:length(lat)
  for k = 1:length(lon)
    for l = 1:length(mjd)
      G.DATA(j,k,l) = data(k,j,l);
    end
  end
end


% crop in lon remaining?
if do_loncrop
  % We add 360 to really cover all longitudes
  lon_tmp           = [ G.GRID2; 360 ];
  data              = zeros( size(G.DATA,1), size(G.DATA,2)+1, size(G.DATA,3) );
  data(:,1:end-1,:) = G.DATA;
  data(:,end,:)     = G.DATA(:,end,:);
  %  
  [lon,i]     = adjust_to_lonlimits( lon_tmp, lon_limits0 );
  i           = find(i);
  [G.GRID2,j] = unique( lon(i) );
  G.DATA      = data(:,i(j),:);
end
