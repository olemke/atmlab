% READ_GTOPO30  reads gtopo30 digital elevation model
%               data into a matlab structure
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
%         [y] = read_gtopo30(target_lat,target_lon)
%
% OUT    
%         y.z            elevation [m] 2-D array
%         y.longitude    longitude grid
%         y.latitude     latitude grid
%
%       
% IN 
%        target_lat     latitude  (scalar)
%        target_lon     longitude (scalar) (-180 to 180)
%                       the output data structure will 
%                       contain all data from the 
%                       corresponding tile
%                       of the given position   

% HISTORY: Created by Bengt Rydberg 2015-01-15

function [y]=read_gtopo30(target_lat,target_lon)

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert;
  rqre_datatype( target_lat, @isscalar );
  rqre_datatype( target_lon, @isscalar );
  if target_lon<-180 | target_lon>180;
    error('target_lon must be inside -180 to 180')
  end
  if target_lat<-90 | target_lat>90;
    error('target_lat must be inside -90 to 90')
  end
end

%path to data files
datadir = fullfile(atmlab('ATMLAB_DATA_PATH'),'dem_data/gtopo30');

%get the correct filename to read
name = get_gtopo30_filename(target_lat,target_lon);
name = fullfile(datadir,name);

% read the header file
[ ULXMAP, ULYMAP, XDIM, YDIM, NROWS, NCOLS ] = ...
         read_gtopo30_hdr(name);

y.latitude = ULYMAP-(1:NROWS)*XDIM;
y.longitude = ULXMAP+(1:NCOLS)*YDIM;

% read the data file

fid = fopen([name,'.dem'],'rb');
y.z = fread(fid,[NCOLS NROWS],'int16','b');
fclose(fid);
%y.z( find( y.z == -9999 ) ) = nan;


%plot data
if 0;
  pcolor( y.longitude(1:3:end), y.latitude(1:3:end),...
         y.z(1:3:end,1:3:end)')
  shading flat
  colorbar
  load coast
  hold on
  c1=plot(long,lat,'k');
  set(c1,'linewidth',2)
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



