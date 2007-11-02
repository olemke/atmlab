%P2Z_CIRA86      Converts pressure to altitude
%
%                Converts pressure to altitude assuming
%                cira86 climataology. Linear interpolation
%                between log(pressure), latitude, and
%                day of year is performed.
%
% FORMAT   [P] = p2z_cira86( P , LAT , DOY )
%        
% IN    P   pressure in pascal.
%           P can be a scalar,vector or matrix
%       LAT latitude
%           LAT can be a scalar or vector
%           defined from [-90 to 90]
%       DOY day of year 
%           DOY must be a scalar
% OUT
%       P   Pressure in Pascal
%
% 2007-11-01   Created by Bengt Rydberg

function [z]=p2z_cira86(p,lat,doy)
 
if doy>365 | doy<1
   error('doy is out of range')
end
if length(doy)>1
   error('doy must be a scalar')
end
if ~isempty(find(lat<-90)) | ~isempty(find(lat>90))
   error('latitude range is -90 to 90')
end
if length(lat)~=size(p,2) & size(p,2)~=1 
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


[LM,PM,MM]=meshgrid(Data.lat_grid,Data.p_grid,Data.month);

if size(p,2)>1 & size(lat,2)>1

   for i=1:size(p,2)
       [LMi,PMi,MMi]=meshgrid(lat(i),p(:,i),month2);
       z(:,i)=interp3(LM,PM,MM,Data.data,LMi,log(PMi),MMi);
   end 

else

   [LMi,PMi,MMi]=meshgrid(lat,z,month2);
   z=interp3(LM,log(PM),MM,Data.data,LMi,log(PMi),MMi);

end


