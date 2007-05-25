% CLOUDSAT_IWC_READ_STD   Reading of CLOUDSAT 2B-CWC-RO IWC and LWC
%
%    This function provides a relatively simple way to read CloudSat IWC and
%    LWC. It is not general, such as *cloudsat_l1b_read*.
%
% FORMAT   P = cloudsat_iwc_read_std( datafiles, fieldlist )
%
% OUT      P is a struct array with fields
%          ok       Flag telling if file and all selected fields could be read.
%          ok_iwc   Data quality flag (for each data value). Bad data have 
%                   ok_iwc=0
%          ok_lwc   As ok_iwc, but for LWC.               
%          z   [m]  this field comes always when iwc or lwc is desired 
%          lat
%          lon
%          iwc [g/m^3] all values below surface are set to nan
%          lwc [g/m^3]
%          mjd
%
%          Meaning of some specific values for iwc and lwc fields:
%            0.0: Clear column (2B-GEOPROF)
%          -3333: Solution negative (2B-LWC/IWC-RO)
%          -4444: Solution diverged (2B-LWC/IWC-RO)
%          -7777: Unphysical, bad, or missing reflectivity factor Z'
%                   (2B-GEOPROF)
%          -8888: Cloud scenario not determined, invalid class, 
%                   or class bad/missing (2B-CLDCLASS)
%          -9999: Bad or missing temperature (ECMWF-AUX)
%          
%
% IN       datafiles   Files to read. Either obtained by *dir*. 
%                      A single file can also be given as a string.
%                      Multiple files can also be given as a cell array of 
%                      strings.
% OPT      fieldlist   Fields to read. omit to select all fields.
%                      Example: To select fields lat and iwc
%                      fieldlist={'lat','iwc'};

% 2007-05-25   Patrick Eriksson   Added to atmlab and improved header.
% 2007-03-23   Bengt Rydberg      Created.


function [P] = cloudsat_iwc_read_std(datafiles,fieldlist)

if nargin < 2
   fieldlist = {'lat','lon','iwc','lwc','mjd'};
end



pos_fieldlist={'lat','lon','iwc','lwc','mjd'};
cs_fieldlist={'Latitude','Longitude','RO_ice_water_content',...
              'RO_liq_water_content','TAI_start','Profile_time'};

%set the fields to be read 
k=1;
for i=1:length(pos_fieldlist)
    if sum(strcmp(fieldlist,pos_fieldlist{i}))==1
       if i==length(pos_fieldlist)
	  Fieldlist{k}=cs_fieldlist{5};
          k=k+1;
          Fieldlist{k}=cs_fieldlist{6};
       else
          Fieldlist{k}=cs_fieldlist{i};
       end
       k=k+1;
    end
end

if sum(strcmp(fieldlist,'iwc'))==1 | sum(strcmp(fieldlist,'lwc'))==1
    Fieldlist{k}='DEM_elevation';
    Fieldlist{k+1}='Height';
end


if ischar( datafiles )
  a                 = datafiles;
  datafiles         = [];
  datafiles(1).name = a;
elseif iscellstr(datafiles)
  a         = datafiles;
  datafiles = [];
  for i = 1 : length(a)
    datafiles(i).name = a{i};
  end
end


%read in the files one by one and keep track of the
%files that can not be read

for i=1:length(datafiles)
    L1= cloudsat_l1b_read(datafiles(i),Fieldlist);
    if isstruct(L1)
       L1.ok=1;
       L(i)=L1;
    else
       L(i).ok=0;
    end
end

%fill up the desired existing fields
for i=1:length(L)
    P(i).ok=L(i).ok;
    if sum(strcmp(fieldlist,'lat'))==1
       if isfield(L(i),'Latitude') & ~isempty(L(i).Latitude) 
          P(i).lat=L(i).Latitude;
       else
          P(i).lat=[];
          P(i).ok=0;
       end
    end
    if sum(strcmp(fieldlist,'lon'))==1
       if isfield(L(i),'Longitude') & ~isempty(L(i).Longitude)
          P(i).lon=L(i).Longitude;
       else
          P(i).lon=[];
          P(i).ok=0;
       end
    end
    if sum(strcmp(fieldlist,'iwc'))==1
       if isfield(L(i),'RO_ice_water_content') & ...
          isfield(L(i),'Height') & ...
          isfield(L(i),'DEM_elevation') & ...
          ~isempty(L(i).RO_ice_water_content) & ...
          ~isempty(L(i).Height) & ...
          ~isempty(L(i).DEM_elevation)
          iwc=L(i).RO_ice_water_content';
          %scale by 1e-4 since data are given in mg/m^3
          %and a scaling factor of 10
          iwc(find(iwc>0))=iwc(find(iwc>0))*1e-4;

          %z0 surface height above mean sea level
          z0=L(i).DEM_elevation;
          Height=zeros(size(L(i).Height'));
          H=L(i).Height';
          %set z0=-9999 t0 0  (-9999) indicate sea
	  z0(find(z0==-9999))=0;   
          P(i).ok_iwc=ones(size(z0));
          %set values below surface level to nan        
          Height=L(i).Height'-ones(size(L(i).Height,2),1)*z0;
	  iwc(find(Height<0))=nan;          
          H(find(Height<0))=nan;     

          %find bad profiles
          [yi,xi]=find(iwc<0);
          xj=unique(xi)';
          P(i).ok_iwc(xj)=0;

          xk=find(z0==9999);
          if ~isempty(xk)
             iwc(:,xk)=nan;
             H(:,xk)=nan;
             P(i).ok_iwc(xk)=0;
          end
          P(i).iwc=iwc;
          P(i).z=H;
       else
	  P(i).iwc=[];
          P(i).ok=0;
       end
    end
    if  sum(strcmp(fieldlist,'lwc'))==1
        if isfield(L(i),'RO_liq_water_content') & ...
        isfield(L(i),'Height') & ...
        isfield(L(i),'DEM_elevation') & ...
        ~isempty(L(i).RO_liq_water_content) & ...
        ~isempty(L(i).Height) & ...
        ~isempty(L(i).DEM_elevation)
 
           lwc=L(i).RO_liq_water_content';
           %scale by 1e-3 since data are given in mg/m^3
           lwc(find(lwc>0))=lwc(find(lwc>0))*1e-3;

           z0=L(i).DEM_elevation;
           Height=zeros(size(L(i).Height'));
           H=L(i).Height';
          
           %set z0=-9999 t0 0  (-9999) indicate sea
	   z0(find(z0==-9999))=0;
           P(i).ok_lwc=ones(size(z0));

           %set values below surface level to nan        
           Height=L(i).Height'-ones(size(L(i).Height,2),1)*z0;
	   lwc(find(Height<0))=nan;          
           H(find(Height<0))=nan;     

           %find bad profiles
           [yi,xi]=find(lwc<0);
           xj=unique(xi)';
            P(i).ok_lwc(xj)=0;
           xk=find(z0==9999);
           if ~isempty(xk)
              lwc(:,xk)=nan;
              H(:,xk)=nan;
              P(i).ok_lwc(xk)=0;
           end
       
           P(i).lwc=lwc;
           P(i).z=H;
        else
           P(i).lwc=[];
           P(i).ok=0;
        end
    end
    %time 
    %y.TAI_start;                 %seconds since 00:00:00 Jan 1 1993
    %y.Profile_time;              %seconds since first profile
    if  sum(strcmp(fieldlist,'mjd'))==1
        if isfield(L(i),'TAI_start') &  isfield(L(i),'Profile_time') & ...
          ~isempty(L(i).TAI_start) &  ~isempty(L(i).Profile_time)
           t1=L(i).TAI_start+L(i).Profile_time; 
           %n=datenum(1993,1,1,0,0,t1);
           %[yy,mm,dd,hh,mi,se] = datevec(n); %utc-time
           %[mjd] = utc2mjd(yy,mm,dd,hh,mi,floor(se),se-floor(se));
           mjd=date2mjd(1993,1,1,0,0,0)+t1/(24*3600);
           P(i).mjd=mjd;
        else
          P(i).mjd=[];
          P(i).ok=0;
        end 
    end    
end

