%Z2P_CIRA86      Converts altitude to pressure
%
%                Converts altitude to pressure assuming
%                cira86 climataology. Linear interpolation
%                between log(pressure),altitude, latitude, and
%                day of year is performed.
%
% FORMAT   [P] = p2z_cira86( Z , LAT , DOY )
%        
% IN    Z   altitude in meters.
%           Z can be a scalar,vector or matrix
%       LAT latitude
%           LAT can be a scalar or vector
%           defined from [-90 to 90]
%       DOY day of year 
%           DOY must be a scalar
% OUT
%       P   Pressure in Pascal
%
% 2007-11-01   Created by Bengt Rydberg

function [p]=p2z_cira86(z,lat,doy)
 
if doy>365 | doy<1
   error('doy is out of range')
end
if length(doy)>1
   error('doy must be a scalar')
end
if ~isempty(find(lat<-90)) | ~isempty(find(lat>90))
   error('latitude range is -90 to 90')
end
if length(lat)~=size(z,2) & size(z,2)~=1 
   error('lat and z does not match in size')
end

days_in_prev_months = [0 31 59 90 120 151 181 212 243 273 304 334 365];
month1=max(find(days_in_prev_months<doy));
day=doy-days_in_prev_months(month1);

%month2 is the fraction of which month we are in
%month2=1 corresponds to 31st of january 
month2=month1-1+day/...
      (days_in_prev_months(month1+1)-days_in_prev_months(month1));


for i=1:12
    file_i     =['cira86_month',num2str(i),'.z.xml'];
    cira86     = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'atmosphere',...
                            'cira86',file_i);
    data=xmlLoad(cira86);
    if i==1
       Data.p_grid=data.p_grid;
       Data.lat_grid=data.lat_grid;
       Data.lon_grid=0;
       %add janaury data after december
       Data.month(14)=12.5;
       Data.data(:,:,14)=data.data;
    end
    if i==12 %add december data before january
       Data.month(1)=-0.5;
       Data.data(:,:,1)=data.data;
    end
    Data.month(i+1)=i-1+0.5;
    Data.data(:,:,i+1)=data.data;
end

%create a new structure where the data is in pressure
%
%change the grid from p to z
Znew=zeros(size( Data.data,1),1);
for i=1:size( Data.data,3)
    Znew=Znew+sum([Data.data(:,:,i)]')';
end

Data2.z_grid=Znew/(size( Data.data,3)*size( Data.data,2));
Data2.lat_grid=Data.lat_grid;
Data2.month=Data.month;

for i=1:length(Data.lat_grid)

 for j=1:length(Data.month)
     Data2.data(:,i,j)=exp(interp1(Data.data(:,i,j),log(Data.p_grid),...
                           Data2.z_grid,'linear','extrap'));
 end

end

%--
%do the interpolation 

[LM,ZM,MM]=meshgrid(Data2.lat_grid,Data2.z_grid,Data2.month);

if size(z,2)>1 & size(lat,2)>1

   for i=1:size(z,2)
       [LMi,ZMi,MMi]=meshgrid(lat(i),z(:,i),month2);
       p(:,i)=exp(interp3(LM,ZM,MM,log(Data2.data),LMi,ZMi,MMi));
   end 

else

   [LMi,ZMi,MMi]=meshgrid(lat,z,month2);
   p=exp(interp3(LM,ZM,MM,log(Data2.data),LMi,ZMi,MMi));

end

