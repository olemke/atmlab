% calculate_HMP     A function to calculate hydrometeorpaths within the 
%                   database for the ISMAR retrieval.
%
%   The function will calculate the hydrometeor paths of the hydrometeors
%   within a ISMAR retrievaldatabase. This is done using a mid point
%   integration.
%
%   If upper_limit is positive infinity and lower_limit is empty then the 
%   hydrometeor path is calculated by integrating over the complete column.
%
%   If upper_limit is negative and lower_limit is empty then the 
%   hydrometeor path is calculated by integrating over the complete column,
%   but as cummulative hydrometeor path beginning from the ground.
%
%   If upper_limit is positive and lower_limit is empty then the 
%   hydrometeor path is calculated by integrating from the ground to the
%   upper_limit
%
%   If upper_limit is positive and lower_limit is positve then the 
%   hydrometeor path is calculated by integrating from the lower_limt to 
%   the upper_limit.
%
%   If upper_limit is empty and lower_limit is negative then the 
%   hydrometeor path is calculated by integrating over the complete column,
%   but as cummulative hydrometeor path beginning from the top of the 
%   atmosphere (TOA).
%
%   If upper_limit is empty and lower_limit is positive then the 
%   hydrometeor path is calculated by integrating from the TOA to the
%   lower_limit
% 
% FORMAT    results=calculate_iwv(data,HMPtypes,upper_limit,lower_limit)
%
% OUT   results,     a struct consisting of the fields
%                    "HMP" - hydrometeor path(s)
%                    "altitude" - altitude if cummulative path is selected,
%                                 otherwise NaN
%                    "pressure" - pressure if cummulative path is selected,
%                                 otherwise NaN
%                    "HMPtypes" - a cell array with the name of the
%                                 hydrometors
%
% IN    data,        database as struct with fieldnames according to the ISMAR
%                    database documentation.
%       HMPtypes,    a cell-array with the hydrometeors for which the paths
%                    should be calculated. If set empty, then all hydrometeor
%                    paths are calculated.
%       upper_limit, upper limit of integration
%       lower_limit, lower limit of integration
%

%   2015-12-14  Manfred Brath
%   2015-12-17  Manfred Brath


function results=calculate_hmp(data,HMPtypes,upper_limit,lower_limit)

if nargin<4
    lower_limit=[];
end

if nargin<3
    upper_limit=inf;
end

if ~iscell(HMPtypes)
    HMPtypes={HMPtypes};
end


%Altitude
z=data.altitude;

%Differential of altitude
dz=diff(z,1,2);

%midpoint altitude between two layer
zm=z(:,1:end-1)+dz/2;

%midpoint pressure between two layer
pm=(data.pressure(1:end-1)+data.pressure(2:end))/2;


%get size of pnd_field
q=size(data.pnd_field);

%Mass
mass=reshape(data.mass,[1,1,length(data.mass)]);
mass=repmat(mass,[q(1),q(2),1]);

%PND-MassContent
PNDMC=data.pnd_field.*mass;

%just a flag
flag=0;

if isempty(HMPtypes{1})
    
   HMPtypes=unique(data.scattering_element_type);      
    
end

%to sure that dimension 
HMPtypes=HMPtypes(:)';

%loop over the different hydrometeor types
for i=1:length(HMPtypes)

    %take the wated hydrometeor
    logic_hmptype=strncmpi(HMPtypes{1,i},data.scattering_element_type,length(HMPtypes{1,i}));

    
    %hydrometeor mass content
    hmc_temp=sum(PNDMC(:,:,logic_hmptype),3); 

    
    if flag==0
        %allocate
        CHMPup=nan([length(HMPtypes),size(zm)]);
        CHMPdn=nan([length(HMPtypes),size(zm)]);
        HMC=nan([length(HMPtypes),size(hmc_temp)]);
        flag=1;
    end
    
    HMC(i,:,:)=hmc_temp;
    
    j_dn=size(CHMPup,3):-1:1;
    for j=1:size(CHMPup,3)
        %from bottom to top      
        CHMPup(i,:,j)=nansum((hmc_temp(:,1:j)+hmc_temp(:,2:j+1)).*dz(:,1:j)/2,2);

        %from top to bottom
        CHMPdn(i,:,j_dn(j))=nansum((hmc_temp(:,j_dn(j)+1:j_dn(1)+1)+hmc_temp(:,j_dn(j):j_dn(1))).*dz(:,j_dn(j):j_dn(1))/2,2);
        
    end
    

end


%% do the output

%the complete column
if ~isempty(upper_limit)
    if ( (isinf(upper_limit) && upper_limit>0 && isempty(lower_limit)) )
    
    

        z_temp=nan(size(CHMPup,2),1);
        p_temp=nan(size(CHMPup,2),1);

        for i=1:size(CHMPup,2)

            index=find(~isnan(zm(i,:)),1,'last');
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
    
        results.HMP=CHMPup(:,:,end);
        results.altitude=nan;
        results.pressure_layer=nan;
    
    
    %the complete column, but as cummulative sum starting from the ground    
    elseif upper_limit<0 && isempty(lower_limit)
        results.HMP=CHMPup;
        results.altitude=zm;
        results.pressure_layer=pm;

    %the hydrometeor paths from the ground up to the upper limit    
    elseif isempty(lower_limit) 
    
        z_temp=nan(size(CHMPup,2),1);
        p_temp=nan(size(CHMPup,2),1);
        results.HMP=nan(size(CHMPup,1),size(CHMPup,2));

        for i=1:size(CHMPup,2)
            index=find(abs(zm(i,:)-upper_limit)==min(abs(zm(i,:)-upper_limit)),1,'first');

            results.HMP(:,i)=CHMPup(:,i,index);
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
        results.altitude=z_temp;
        results.pressure_layer=p_temp;
    
    %the hydrometeor paths between lower and upper limit     
    elseif ~isempty(lower_limit)    

        results.HMP=nan(length(HMPtypes),size(HMC,2));

        for i=1:size(HMC,2)
            index_low=find(abs(z(i,:)-lower_limit)==min(abs(z(i,:)-lower_limit)),1,'first');
            index_up=find(abs(z(i,:)-upper_limit)==min(abs(z(i,:)-upper_limit)),1,'first');

            results.HMP(:,i)=sum(squeeze(HMC(:,i,index_low:index_up-1)+...
                HMC(:,i,index_low+1:index_up))/2.*...
                repmat(dz(i,index_low:index_up-1),length(HMPtypes),1),2);        
        end

        results.altitude=nan;
        results.pressure_layer=nan;           
    end
    
elseif isempty(upper_limit)
    
    %the complete column, but as cummulative sum starting from the top  
    if lower_limit<0 
        results.HMP=CHMPdn;
        results.altitude=zm;
        results.pressure_layer=pm; 

    %the hydrometeor paths from the top down to the upper limit    
    elseif lower_limit>0 

        z_temp=nan(size(CHMPdn,2),1);
        p_temp=nan(size(CHMPdn,2),1);
        results.HMP=nan(size(CHMPdn,1),size(CHMPdn,2));

        for i=1:size(CHMPdn,2)
            index=find(abs(zm(i,:)-lower_limit)==min(abs(zm(i,:)-lower_limit)),1,'first');

            results.HMP(:,i)=CHMPdn(:,i,index);
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
        results.altitude=z_temp;
        results.pressure_layer=p_temp;    

    end
    
end
    
    
    


results.HMPtypes=HMPtypes;


end