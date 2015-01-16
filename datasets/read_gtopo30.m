% READ_GTOPO30  reads gtopo30 digital elevation model
%               data into G-format data
%
%
% GTOPO30 is a digital elevation model for the world, 
% developed by USGS. It has a 30-arc second resolution 
% (approximately 1 km), and is split into 33 tiles 
% stored in the USGS DEM file format.
%
% The horizontal coordinate system is decimal degrees of 
% latitude and longitude referenced to World Geodetic System 84 (WGS84). 
% The vertical units represent elevation in meters above mean sea level. 
% The elevation values range from -407 to 8,752 meters. In the DEM, ocean 
% areas have been masked as no data and have been assigned a value of -9999.
%
% The actual data files are found within the atmlab-data svn package.
%
% FORMAT
%   
%         [G] = read_gtopo30(lat_limits, lon_limits)
%
% OUT    
%         G             gtopo30 data on gformat structure
%                       ( all data at full resolution
%                         within the desired limits)
%       
% IN 
%        lat_limits     latitude limits (vector)
%        lon_limits     longitude limits (vector) (-180 to 180)
%

% HISTORY: Created by Bengt Rydberg 2015-01-15

function [G]=read_gtopo30(lat_limits,lon_limits)

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert;

  rqre_datatype( lat_limits, @isvector );
  rqre_datatype( lon_limits, @isvector );
  if length(lon_limits)~=2;
    error('lon_limits must be a vector of length 2')
  end
  if length(lat_limits)~=2;
    error('lat_limits must be a vector of length 2')
  end
  if any(lon_limits<-180) | any(lon_limits>180);
    error('lon_limits must be inside -180 to 180')
  end
  if any(lat_limits<-90) | any(lat_limits>90);
    error('lat_limits must be inside -90 to 90')
  end
  if lon_limits(1)>lon_limits(2);
    error('lon_limits(2) must be greater than lon_limits(2)')
  end
  if lat_limits(1)>lat_limits(2);
    error('lat_limits(2) must be greater than lat_limits(2)')
  end

end

%path to data files
datadir = fullfile(atmlab('ATMLAB_DATA_PATH'),'dem_data/gtopo30');

%get the correct filenames to read

latvec = linspace(lat_limits(1), lat_limits(2), 180);
lonvec = linspace(lon_limits(1), lon_limits(2), 360);
names = [];
k = 1;
for i = 1:length(latvec)
  for j = 1:length(lonvec)
    names{k} = get_gtopo30_filename(latvec(i),lonvec(j));
    k = k + 1;
  end
end
names = unique(names);

% read the desired files

for i = 1:length(names) 
  name = fullfile(datadir,names{i});
  % read the header file
  [ ULXMAP, ULYMAP, XDIM, YDIM, NROWS, NCOLS ] = ...
         read_gtopo30_hdr(name);

  y{i}.latitude = ULYMAP-(1:NROWS)*XDIM;
  y{i}.longitude = ULXMAP+(1:NCOLS)*YDIM;

  % read the data file

  fid = fopen([name,'.dem'],'rb');
  y{i}.z = fread(fid,[NCOLS NROWS],'int16','b');
  fclose(fid);

end


% merge data
% first create lat/lon grids
latgrid = [];
longrid = [];
for i=1:length(y)
  latgrid = [latgrid, y{i}.latitude];
  longrid = [longrid, y{i}.longitude];
end
latgrid = sort(unique(latgrid));
longrid = sort(unique(longrid));

z = zeros(length(latgrid),length(longrid));
for k = 1:length(y)
  ind1 = find(y{k}.longitude(1)==longrid);
  ind2 = find(y{k}.latitude(1)==latgrid);
  z(ind2-length(y{k}.latitude)+1:ind2, ind1:ind1+length(y{k}.longitude)-1) = flipud(y{k}.z');
end

%filter the data, only return data within the desired limits
clear y
ind1 = find( latgrid >= lat_limits(1) & latgrid<=lat_limits(2) );
ind2 = find( longrid >= lon_limits(1) & longrid<=lon_limits(2) );

G           = gf_empty(2);
grid_names  = {'Latitude', 'Longitude'};
grid_units  = { 'deg', 'deg'};
grids       = { vec2col(latgrid(ind1)), ...
                vec2col(longrid(ind2))};

G = gf_set_data(G,z(ind1,ind2),grids,grid_names);

for d = 1:2
  G = gf_set_grid( G, d, grids{d}, grid_names{d}, grid_units{d} );
end
 
G.TYPE      = 'surfdata';
G.NAME      = 'GTOPO30 dem data';
G.SOURCE    = datadir;
G.DATA_NAME = 'Surface elevation';
G.DATA_UNIT = 'm';


if 0;
  di=5;
  pcolor( G.GRID2(1:di:end), G.GRID1(1:di:end), G.DATA(1:di:end,1:di:end))
  shading flat
  colorbar
  load coast
  hold on
  xlabel('Longitude [deg]')
  ylabel('Latitude [deg]')
  c1=plot(long,lat,'k');
  set(c1,'linewidth',2)
  caxis([0 max(G.DATA(:))])
end




%SUB-FUNCTIONS

function [ ULXMAP, ULYMAP, XDIM, YDIM, NROWS, NCOLS ] = ...
         read_gtopo30_hdr(name)

  fid = fopen([name,'.hdr']);

  tline = fgets(fid);
  while ischar(tline)
    parts = strread(tline,'%s','delimiter',' ');
    if strcmp(parts{1},'ULXMAP');
      ULXMAP = str2num(parts{2});
    elseif strcmp(parts{1},'ULYMAP');
      ULYMAP = str2num(parts{2});
    elseif strcmp(parts{1},'XDIM');
      XDIM = str2num(parts{2});
    elseif strcmp(parts{1},'YDIM');
      YDIM = str2num(parts{2});
    elseif strcmp(parts{1},'NROWS');
      NROWS = str2num(parts{2});
    elseif strcmp(parts{1},'NCOLS');
      NCOLS = str2num(parts{2});
    end
    tline = fgets(fid);
  end

  fclose(fid);


function name = get_gtopo30_filename(target_lat,target_lon)

  if (target_lat >40 & target_lat <=90);

    if (target_lon >= -180 & target_lon < -140);
      name = 'gt30w180n90';
    elseif (target_lon >= -140 & target_lon < -100);
      name = 'gt30w140n90';
    elseif (target_lon >= -100 & target_lon < -60);
      name = 'gt30w100n90';
    elseif (target_lon >= -60 & target_lon < -20);
      name = 'gt30w060n90';
    elseif (target_lon >= -20 & target_lon < 20);
      name = 'gt30w020n90';
    elseif (target_lon >= 20 & target_lon < 60); 
      name = 'gt30e020n90';
    elseif (target_lon >= 60 & target_lon < 100); 
      name = 'gt30e060n90';
    elseif (target_lon >= 100 & target_lon < 140); 
      name = 'gt30e100n90';
    elseif (target_lon >= 140 & target_lon <= 180); 
      name = 'gt30e140n90';
    end

  elseif (target_lat > -10 & target_lat <=40);

    if (target_lon >= -180 & target_lon < -140);
      name = 'gt30w180n40';
    elseif (target_lon >= -140 & target_lon < -100);
      name = 'gt30w140n40';
    elseif (target_lon >= -100 & target_lon < -60);
      name = 'gt30w100n40';
    elseif (target_lon >= -60 & target_lon < -20);
      name = 'gt30w060n40';
    elseif (target_lon >= -20 & target_lon < 20); 
      name = 'gt30w020n40';
    elseif (target_lon >= 20 & target_lon < 60); 
      name = 'gt30e020n40';
    elseif (target_lon >= 60 & target_lon < 100); 
      name = 'gt30e060n40';
    elseif (target_lon >= 100 & target_lon < 140);
      name = 'gt30e100n40';
    elseif (target_lon >= 140 & target_lon <= 180);
      name = 'gt30e140n40';
    end

  elseif (target_lat > -60 & target_lat <=-10);

    if (target_lon >= -180 & target_lon < -140);
      name = 'gt30w180s10';
    elseif (target_lon >= -140 & target_lon < -100);
      name = 'gt30w140s10';
    elseif (target_lon >= -100 & target_lon < -60);
      name = 'gt30w100s10';
    elseif (target_lon >= -60 & target_lon < -20);
      name = 'gt30w060s10';
    elseif (target_lon >= -20 & target_lon < 20); 
      name = 'gt30w020s10';
    elseif (target_lon >= 20 & target_lon < 60); 
      name = 'gt30e020s10';
    elseif (target_lon >= 60 & target_lon < 100); 
      name = 'gt30e060s10';
    elseif (target_lon >= 100 & target_lon < 140); 
      name = 'gt30e100s10';
    elseif (target_lon >= 140 & target_lon <= 180); 
      name = 'gt30e140s10';
    end

  elseif (target_lat >= -90 & target_lat <=-60);

    if (target_lon >= -180 & target_lon < -120);
      name = 'gt30w180s60';
    elseif (target_lon >= -120 & target_lon < -60);
      name = 'gt30w120s60';
    elseif (target_lon >= -60 & target_lon < 0); 
      name = 'gt30w060s60';
    elseif (target_lon >= 0 & target_lon < 60); 
      name = 'gt30w000s60';
    elseif (target_lon >= 60 & target_lon < 120);  
      name = 'gt30e060s60';
    elseif (target_lon >= 120 & target_lon <= 180);  
      name = 'gt30e120s60';
    end

  end



