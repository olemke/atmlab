% ERAINTERIM2SURFDATA    Loads ERA-Interim data into surfdata structure
%
%   The function can read and merge multiple files. This option requires
%   that all latitude and longitude grids are equal. No advanced
%   checking is made, so use the option carefully.
%
% FORMAT   G = erainterim2surfdata( infile, parameter, lat_limits, lon_limits, mjd_limits )
% 
% OUT      G          atmdata structure  
% IN       infile     Name of the file(s) to read. For single file reading
%                     this can be string. Otherwise an array of strings.
%          parameter  parameter to read in, options are
%                     'surface pressure', 'sea surface temperature',
%                     'skin temperature', '2 m temperature', 
%                     'u10', 'v10', LWP, IWP
%          lat_limits latitude limits filter (vector of length 2) 
%          lon_limits longitude limits filter (vector of length 2, both
%                     +-180 and 0-360 can be used) 
%          mjd_limits mjd limits filter (vector of length 2)  
%          N.B. longitude (0 -- 359), latitude (-90 -- 90)
%
% Example usage:
%
% file       = '/misc/pearl/extdata/DATA4ISMAR/ERAInterim/netcdf-atls03-20141003171553-5936-0700.nc';
% parameter  = 'surface pressure';
% lat_limits = [-5 5];
% lon_limits = [30 40];
% mjd        = date2mjd(2013, 11, 16, 12);
% mjd_limits = [mjd-6/24 mjd+6/24];
% [G] = erainterim2surfdata(file,parameter,lat_limits,lon_limits,mjd_limits);

% 2014-10-03  Created by Bengt Rydberg
% 2015-08-20  Adopted to handle lon_limits following [-180,180]

function [G] = erainterim2surfdata(infile,parameter,lat_limits,lon_limits,mjd_limits)


%--------------------------------------------------------------------------------
% Special solution for reading/merging of multiple files

if iscellstr(infile)
  %
  if length(infile) == 1
    G = erainterim2surfdata( infile{1}, parameter, lat_limits, lon_limits, ...
                            mjd_limits);
    return;  
  end
  %
  for i = 1 : length(infile)
    H{i} = erainterim2surfdata( infile{i}, parameter, lat_limits, lon_limits, ...
                               mjd_limits);
    mjd1(i) = H{i}.GRID3(1); 
    nmjd(i) = length( H{i}.GRID3 ); 
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
  G.DATA  = zeros( [ s0(1:2) sum(nmjd) ] );
  G.GRID3 = zeros( sum(nmjd), 1 );
  %
  [~,o] = sort( mjd1 );
  n = 0;
  %
  for i = 1 : length(infile)
    j   = o(i);
    ind = n+1 : n+nmjd(j);
    n   = n+nmjd(j);
    %
    G.DATA(:,:,ind) = H{j}.DATA;
    G.GRID3(ind)    = H{j}.GRID3; 
  end
  %
  return  
end
%--------------------------------------------------------------------------------


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
            'temperature, skin temperature, and 2 m temperature, u10, v10, ' ...
            'LWP, IWP, LCC, MCC and HCC.' ])
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


% Check if lon_limits are inside [0,359] and cropping can be done already
% in reading
if lon_limits(1) < 0  |  lon_limits(2) > 359
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
start = [lonind(1) latind(1) mjdind(1)];
count = [length(lonind) length(latind) length(mjdind)];

if isequal(lower(parameter), 'surface pressure')
  data = ncread(infile, '/sp', start, count);
  unit= ncreadatt(infile, '/sp', 'units');
  data_name='Surface pressure';

elseif isequal(lower(parameter), 'sea surface temperature')
  data = ncread(infile, '/sst', start, count);
  unit= ncreadatt(infile, '/sst', 'units');
  data_name='Sea surface temperature';

elseif isequal(lower(parameter), 'skin temperature')
  data = ncread(infile, '/skt', start, count);
  unit= ncreadatt(infile, '/skt', 'units');
  data_name='Skin temperature';

elseif isequal(lower(parameter), '2 m temperature')
  data = ncread(infile, '/t2m', start, count);
  unit= ncreadatt(infile, '/t2m', 'units');
  data_name='2 m temperature';

elseif isequal(lower(parameter), 'u10')
  data = ncread(infile, '/u10', start, count);
  unit= ncreadatt(infile, '/u10', 'units');
  data_name='u10';

elseif isequal(lower(parameter), 'v10')
  data = ncread(infile, '/v10', start, count);
  unit= ncreadatt(infile, '/v10', 'units');
  data_name='u10';

elseif isequal(lower(parameter), 'lwp')
  data = ncread(infile, '/p56.162', start, count);
  unit= ncreadatt(infile, '/p56.162', 'units');
  data_name='LWP';

elseif isequal(lower(parameter), 'iwp')
  data = ncread(infile, '/p57.162', start, count);
  unit= ncreadatt(infile, '/p57.162', 'units');
  data_name='IWP';

elseif isequal(lower(parameter), 'lcc')
  data = ncread(infile, '/lcc', start, count);
  unit= ncreadatt(infile, '/lcc', 'units');
  data_name='Low cloud cover';

elseif isequal(lower(parameter), 'mcc')
  data = ncread(infile, '/mcc', start, count);
  unit= ncreadatt(infile, '/mcc', 'units');
  data_name='Medium cloud cover';

elseif isequal(lower(parameter), 'hcc')
  data = ncread(infile, '/hcc', start, count);
  unit= ncreadatt(infile, '/hcc', 'units');
  data_name='High cloud cover';

end


%flip data
%latitude
data = flipdim(data,2);
lat  = flipud(vec2col(lat));

%change dimension
data_out = zeros(length(lat),length(lon),length(mjd));
for j=1:length(lat)
  for k=1:length(lon)
    for l=1:length(mjd)
      data_out(j,k,l) = data(k,j,l);
    end
  end
end


% fill G
G            = surfdata_empty(3); 
G.NAME       = data_name;
G.DATA       = data_out;
G.DATA_NAME  = data_name;
G.DATA_UNIT  = unit;
G.GRID1      = vec2col(lat);
G.GRID2      = vec2col(lon);
G.GRID3      = vec2col(mjd);
G.GRID3_NAME = 'MJD';
G.GRID3_UNIT = 'mjd';
G.SOURCE     = infile;


% crop in lon remaining?
if do_loncrop
  % We add 0 as 360 to really cover all longotudes
  lon_tmp           = [ G.GRID2; 360 ];
  data              = zeros( size(G.DATA,1), size(G.DATA,2)+1, size(G.DATA,3) );
  data(:,1:end-1,:) = G.DATA;
  data(:,end,:)     = G.DATA(:,end,:);
  %  
  [lon,i]     = adjust_to_lonlimits( lon_tmp, lon_limits0 );
  i           = find(i);
  [G.GRID2,j] = sort( lon(i) );
  G.DATA      = data(:,i(j),:);
end
