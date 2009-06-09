% GFIN_CLOUDSAT_DBZE reads in cloudsat data on gformat
%
%          G(1) will holds radar reflectivity data.
%          If it is desired G(1+i) will holds
%          auxilirary data
%
% FORMAT   [G,D]=gfin_cloudsat_dBZe( D, G, data, aux, z_grid, leg, latitude, dBZemin)
% 
% IN       D        G format definition structure 
%                   can be empty
%          G        original gformat data
%                   can be empty             
%          data     name of a cloudsat file
% OPT      leg      options 1,2, or 3 see cloudsat_read
%                   for definitions
%                   default is 2
%          latitude latitude region to be read in [lat1 lat2]
%                   default is [0 5] 
%          z_grid   the data will be binned on this grid
%                   default is the mean of the cloudsat
%                   array of grids
%          aux      auxilirary data,options can for instance be
%                   {'DEM_elevation','Longitude','TAI_start','Profile_time'}
%                   default are none
%          dBZemin  Lowest value of dBZe to be considered
%                   default is -50  
%
%example usage on how to read in data from
%a cloudsat 2B-GEOPROF file
%
%datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%data=[datadir,'2006166131201_00702_CS_2B-GEOPROF_GRANULE_P_R04_E00.hdf'];
%z_grid=[0:1e3:20e3]'; 
%aux={'DEM_elevation','Longitude','TAI_start','Profile_time'};
%leg=2;
%latitude=[0 5];
%[G,D]=gfin_cloudsat_dBZe([],[],data,aux,[],leg,latitude,[]);
%
%2007-11-05 created by Bengt Rydberg 

function [G,D]=gfin_cloudsat_dBZe( D, G, data, aux, z_grid, leg, latitude, dBZemin)

  
if ~isempty(G) & isempty(D)
   error('If G is defined D must be defined');
end

%- Default values
%
if isempty(D)
  D.DIM        = 3;
  D.GRID1_NAME = 'Altitude';
  D.GRID1_UNIT = 'm';
  D.GRID2_NAME = 'Latitude';
  D.GRID2_UNIT = 'deg';
  D.GRID3_NAME = 'Longitude';
  D.GRID3_UNIT = 'deg';
  G            = asgG;
  G.DIMADD     = [];
end

fields= {'Latitude','Height','Radar_Reflectivity',...
                    'CPR_Cloud_mask'};



leg_DEFAULT      = 2;
latitude_DEFAULT = [0 5];
name_DEFAULT     = 'Radar_Reflectivity';
type_DEFAULT     = 'dBZe';
dims_DEFAULT     = [1 2];
aux_DEFAULT      = [];
dBZemin_DEFAULT  = -50;
set_defaults;

if D.DIM < 3
  error( 'D.DIM must be >= 3 to accommodate data of type cloudsat type.' );
end

for id = 1 : D.DIM
    gname = lower( D.(sprintf('GRID%d_NAME',id)) );
    if strncmp( gname, 'altitude', 8 )
      dims(1) = id;
    elseif strncmp( gname, 'latitude', 8 )
      dims(2) = id;
    elseif strncmp( gname, 'longitude', 8 )
      dims(3) = id;
    end
    
end

if any( dims == 0 )
    error( [ 'Setting of *dims* failed. Altitude, latitude or ',...
             'longitude was not found among the grid names.' ] );
end

if ~isempty(aux)
   for i=1:length(aux)
       if isempty(find(strcmp(aux(i),fields)))
          fields{end+1}=aux{i};
       end
   end
end

%read data 
P = cloudsat_read(data,fields,'leg',leg,'lat',latitude);

if ischar(P)
   error('the selected cloudsat file was not found')
end

%The data in P is a function of (lat,alt) and the altitude is decreasing,
%but we want is as function of (alt,lat) and increasing altitude,
%therefore we transpose the data and flip it upside down
%note that nothing happens with the latitude vector
%since the flipud will be performed on a row vector for latitude 

for i=1:length(fields)
    P.(fields{i}) = flipud(P.(fields{i})');
end


% The code was: else exist('z_grid','var') 
% Correct that it shall be a "pure" else?yes
if ~exist('z_grid','var') 
   P.z_grid=mean(P.Height')';
else 
   if ~isempty(z_grid)
      P.z_grid=z_grid;
   else
      P.z_grid=mean(P.Height')';
   end
end

%remove noisy data not to be identified as clouds
cind=zeros(size(P.CPR_Cloud_mask));
cind(find(P.CPR_Cloud_mask>=20))=1;%cloudy data
P.Radar_Reflectivity=P.Radar_Reflectivity.*cind-(cind-1)*dBZemin;
P.Radar_Reflectivity(find(P.Radar_Reflectivity<dBZemin))=dBZemin;



if length(fields)>4
   kvec=[1 5:length(fields)];
else
  kvec=1;
end


for ik=kvec
    if ik==1
       ind=3;
       H=G;
       H.DATA_UNIT='dBZe';
       i=1;
    else
      ind=ik;
      H(end+1)=H(end);
      i=length(H);
      H(i).DATA_UNIT='?';
    end
    H(i).NAME=fields{ind};
    H(i).DATA_NAME=fields{ind};
    y=P.(fields{ind});
    %find out dimensionality of loaded data
    S=[size(y)==size(P.Latitude)];
    if S(1)==1 & S(2)==1 
       %data is a vector 
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
	      [H(i).(gname)] = [];
           elseif id == 2
	      [H(i).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(i).(gname)] = [];
           end
       end
       H(i).DIMS=dims(2);
       H(i).DATA=y;
    elseif  S(1)==1 & S(2)==0
       %data is a scalar
       H(i).GRID1=[];
       H(i).GRID2=[];
       H(i).GRID3=[];
       H(i).DIMS=[];
       H(i).DATA=y;
    elseif  S(1)==0 & S(2)==1
       %data is a matrix
       y1=zeros(length(P.z_grid),size(y,2));
       warning off;
       %bin the data on altitude grid
       for iy=1:size(y,2)
           y1(:,iy)=binning(P.z_grid,P.Height(:,iy),y(:,iy));
       end
       y=y1;
       warning on;
       if ik~=1
	  warning(['the data in fields ',fields{ind},' has been binned',...
                  ' to fit on a z_grid']);
       end
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
              [H(i).(gname)] = P.z_grid;
           elseif id == 2
	      [H(i).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(i).(gname)] = [];
           end
       end
       if dims(1)~=1 | dims(2)~=2 | dims(3)~=3
	  %data is y(z,lat) change order if necessary
	  grid_ind=[dims(1) dims(2)];
	  if grid_ind(1)>grid_ind(2)
             y=y';
          end
       end
       H(i).DATA=y;
       H(i).DIMS=sort([dims(1) dims(2)]);
   else
       error('unknown dimensionality of data');
   end

   H(i).SOURCE=data;
end
 
G=H;

