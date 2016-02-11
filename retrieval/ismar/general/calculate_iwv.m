% calculate_HMP     A function to calculate the integrated water vapor(IWV)
%                   within a database for the ISMAR retrieval.
%
%   The function will calculate the IWV of the hydrometeors
%   within a ISMAR retrievaldatabase. This is done using a mid point
%   integration.
%
%   If upper_limit is positive infinity and lower_limit is empty then the 
%   IWV is calculated by integrating over the complete column.
%
%   If upper_limit is negative and lower_limit is empty then the 
%   IWV is calculated by integrating over the complete column,
%   but as cummulative IWV beginning from the ground.
%
%   If upper_limit is positive and lower_limit is empty then the 
%   IWV is calculated by integrating from the ground to the
%   upper_limit
%
%   If upper_limit is positive and lower_limit is positve then the 
%   IWV is calculated by integrating from the lower_limt to 
%   the upper_limit.
%
%   If upper_limit is empty and lower_limit is negative then the 
%   IWV is calculated by integrating over the complete column,
%   but as cummulative IWV beginning from the top of the 
%   atmosphere (TOA).
%
%   If upper_limit is empty and lower_limit is positive then the 
%   IWV is calculated by integrating from the TOA to the
%   lower_limit
%
% FORMAT    results=calculate_iwv(data,upper_limit,lower_limit)
%
% OUT   results,     a struct consisting of the fields:
%                    "IWV" - integrated water vapor
%                    "altitude" - altitude if cummulative path is selected,
%                                 otherwise NaN
%                    "pressure" - pressure if cummulative path is selected,
%                                 otherwise NaN
%
%
% IN    data,        database as struct with fieldnames according to the ISMAR
%                    database documentation.
%       upper_limit, upper limit of integration
%       lower_limit, lower limit of integration
%
%

%   2015-12-14  Manfred Brath
%   2015-12-17  Manfred Brath

function results=calculate_iwv(data,upper_limit,lower_limit)



%% start the calculations
if nargin<2
    upper_limit=inf;
end

if nargin<3
    lower_limit=[];
end

% calculate water vapor density

R_h2o=constants('GAS_CONST_WATER_VAPOR');
p=data.pressure;
T=data.temperature;

WV=data.water_vapor./T.*repmat(p,size(data.water_vapor,1),1)/R_h2o;

% calculate the hydrometor paths etc. for the different possible altitudes 
%by integrating from the botton up.

%Altitude
z=data.altitude;

%Differential of altitude
dz=diff(z,1,2);

%midpoint altitude between two layer
zm=z(:,1:end-1)+dz/2;

%midpoint pressure between two layer
pm=(data.pressure(1:end-1)+data.pressure(2:end))/2;

%allocate matrix
CIWVup=nan(size(zm));
CIWVdn=nan(size(zm));

%calculate cumulative integrated water vapor
j_dn=size(CIWVup,2):-1:1;
for j=1:size(CIWVup,2)
    
    CIWVup(:,j)=nansum((WV(:,1:j)+WV(:,2:j+1)).*dz(:,1:j)/2,2);

    CIWVdn(:,j_dn(j))=nansum((WV(:,j_dn(j)+1:j_dn(1)+1)+WV(:,j_dn(j):j_dn(1))).*dz(:,j_dn(j):j_dn(1))/2,2);

end



%% do the output

%the complete column
if ~isempty(upper_limit)
    if ( (isinf(upper_limit) && upper_limit>0 && isempty(lower_limit)) )
    
    

        z_temp=nan(size(CIWVup,1),1);
        p_temp=nan(size(CIWVup,1),1);

        for i=1:size(CIWVup,1)

            index=find(~isnan(zm(i,:)),1,'last');
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
    
        results.IWV=CIWVup(:,end);
        results.altitude=nan;
        results.pressure_layer=nan;
    
    
    %the complete column, but as cummulative sum starting from the ground    
    elseif upper_limit<0 && isempty(lower_limit)
        results.IWV=CIWVup;
        results.altitude=zm;
        results.pressure_layer=pm;

    %the integrated water from the ground up to the upper limit    
    elseif isempty(lower_limit) 
    
        z_temp=nan(size(CIWVup,1),1);
        p_temp=nan(size(CIWVup,1),1);
        results.IWV=nan(size(CIWVup,2),1);

        for i=1:size(CIWVup,1)
            index=find(abs(zm(i,:)-upper_limit)==min(abs(zm(i,:)-upper_limit)),1,'first');

            results.IWV(i)=CIWVup(i,index);
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
        results.altitude=z_temp;
        results.pressure_layer=p_temp;
    
    %the amount of water vapor between upper and lower limit    
    elseif ~isempty(lower_limit)    

        results.IWV=nan(size(WV,1),1);

        for i=1:size(WV,2)
            index_low=find(abs(z(i,:)-lower_limit)==min(abs(z(i,:)-lower_limit)),1,'first');
            index_up=find(abs(z(i,:)-upper_limit)==min(abs(z(i,:)-upper_limit)),1,'first');

            results.IWV(i)=sum((WV(i,index_low:index_up-1)+WV(i,index_low+1:index_up))/2.*dz(i,index_low:index_up-1));        
        end

        results.altitude=nan;
        results.pressure_layer=nan;           
    end
    
elseif isempty(upper_limit)
    
    %the complete column, but as cummulative sum starting from the top  
    if lower_limit<0 
        results.IWV=CIWVdn;
        results.altitude=zm;
        results.pressure_layer=pm; 

    %the integrated water vapor from the top down to the upper limit    
    elseif isempty(upper_limit) 

        z_temp=nan(size(CIWVdn,2),1);
        p_temp=nan(size(CIWVdn,2),1);
        results.IWV=nan(size(CIWVdn,1),1);

        for i=1:size(CIWVdn,1)
            index=find(abs(zm(i,:)-lower_limit)==min(abs(zm(i,:)-lower_limit)),1,'first');

            results.IWV(i)=CIWVdn(i,index);
            z_temp(i,1)=zm(i,index);
            p_temp(i,1)=pm(index);
        end
        results.altitude=z_temp;
        results.pressure_layer=p_temp;    

    end
    
end
    
    



end