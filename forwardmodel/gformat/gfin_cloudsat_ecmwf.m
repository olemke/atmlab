% GFIN_CLOUDSAT_ECMWF reads in cloudsat data on gformat
%
%          G(1) will holds pressure data.
%          G(2) will holds temperature data.
%          G(3) will holds humidity data.
%          G(4) will holds ozone data.
%          If it is desired G(1+i) will holds
%          auxilirary data
%
% FORMAT   G=gfin_cloudsat_ecmwf( D, G, data, aux, leg,latitude)
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
%          aux      auxilirary data,options can for instance be
%                   {'DEM_elevation','Longitude','TAI_start','Profile_time'}
%                   default are none
%
%example usage on how to read in data from
%a cloudsat 2B-GEOPROF file
%
%datadir='/home/bengt/CIWSIR/Dataset_gen/CloudSAT_data/Data/';
%data=[datadir,'2006166131201_00702_CS_ECMWF-AUX_GRANULE_P_R03_E00.hdf'];
%leg=2;
%latitude=[0 5];
%[G,D]=gfin_cloudsat_ecmwf([],[],data,[],leg,latitude,[]);
%
%2007-12-04 created by Bengt Rydberg 

function [G,D]=gfin_cloudsat_ecmwf( D, G, data, aux, leg, latitude)


if ~isempty(G) & isempty(D)
   error('If G is defined D must be defined')
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

fields= {'EC_height','Latitude','Pressure',...
                    'Temperature','Specific_humidity','Ozone'};

leg_DEFAULT      = 2;
latitude_DEFAULT = [0 5];
name_DEFAULT     = 'ECMWF_temperature';
type_DEFAULT     = 'K';
dims_DEFAULT     = [1 2];
aux_DEFAULT      = [];
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
             'longitude was nof found among the grid names.' ] );
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
   error('error in reading the file')
end

for i=1:length(fields)
    if strcmp(fields{i},'EC_height')
       P.(fields{i})=flipud( vec2col( P.(fields{i}) ) );
    elseif strcmp(fields{i},'Latitude')
       P.(fields{i})=vec2col( P.(fields{i}) )';
    else
       P.(fields{i}) = flipud(P.(fields{i})');
    end
end


kvec=1:(length(fields)-2);

H=G;
for ik=kvec
    ind=2+ik;
    H(ik).NAME=fields{ind};
    H(ik).DATA_UNIT='?';
    H(ik).DATA_NAME=fields{ind};
    y=P.(fields{ind});
    
    %find out dimensionality of loaded data
    S=[size(y)==size(P.Latitude)];
    if S(1)==1 & S(2)==1 
       %data is a vector 
       for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
	      [H(ik).(gname)] = [];
           elseif id == 2
	      [H(ik).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(ik).(gname)] = [];
           end
       end
       H(ik).DIMS=dims(2);
       H(ik).DATA=y; 
    elseif  S(1)==1 & S(2)==0
       %data is a scalar
       H(ik).GRID1=[];
       H(ik).GRID2=[];
       H(ik).GRID3=[]; 
       H(ik).DIMS=[]; 
       H(ik).DATA=y;   
    elseif  S(1)==0 & S(2)==1
       %data is a matrix
        for id = 1 : length(dims)
           gname = sprintf( 'GRID%d', dims(id) );
           if id == 1
              [H(ik).(gname)] = P.EC_height;
           elseif id == 2
	      [H(ik).(gname)] = vec2col(P.Latitude)';
           elseif id == 3
              [H(ik).(gname)] = [];
           end
       end
       if dims(1)~=1 | dims(2)~=2 | dims(3)~=3
	  %data is y(z,lat) change order if necessary
	  grid_ind=[dims(1) dims(2)];
	  if grid_ind(1)>grid_ind(2)
             y=y';
          end
       end
       H(ik).DATA=y;
       H(ik).DIMS=sort([dims(1) dims(2)]);
   else
       error('unknown dimensionality of data')
   end

   H(ik).SOURCE=data;
end
 
G=H;

