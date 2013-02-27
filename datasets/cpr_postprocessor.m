function S = cpr_postprocessor(self,S,fields)
%% CPR_POSTPROCESSOR
%
% PURPOSE: To create "pseudo" fields that are not in the original cloudsat
%          data by post-processing fields that are in the original data
%
%
% IN
%     self = dataset
%     S = Data structure to add pseudo field to (from self.reader)
%     fields = {'names','of','pseudo','fields'}
%
% OUT
%     S = Data structure + pseudo field/s
%
% NOTE: See also help Satdataset/pseudo_fields
%
% $Id$
% Salomon Eliasson

% --------------
% Do operations
% --------------

for F =fields
    field = F{1};
    switch field
        case 'Cloud_Types'
            
            % preallocate
            x.cloudy = false(size(tmp.cloud_scenario));
            x.Ci = x.cloudy; x.As = x.cloudy; x.Ac = x.cloudy;
            x.St = x.cloudy; x.Sc = x.cloudy; x.Cu = x.cloudy;
            x.Ns = x.cloudy; x.DC = x.cloudy;
            
            % -----------------------
            % extract clouds
            % -----------------------
            CS = sum(2.^(1:4)); %scenario mask
            Nprof = size(tmp.cloud_scenario,1);
            for i = 1:Nprof
                determined = bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),2^0)==2^0;
                x.cloudy(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)>0;
                x.Ci(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2;
                x.As(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^2;
                x.Ac(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^2;
                x.St(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^3;
                x.Sc(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^3;
                x.Cu(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^2+2^3;
                x.Ns(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^1+2^2+2^3;
                x.DC(i,:) = determined & bitand(typecast(tmp.cloud_scenario(i,:),'uint16'),CS)==2^4;
                
            end
            
            
            % -------------------------
            % Make logical true if all
            % clouds in profile are the same type
            % ------------------------
            
            cloudfree = ~any(x.cloudy,2);
            cloudTypes = {'Ci','As','Ac','St','Sc','Cu','Ns','DC'};
            for i = 1:length(cloudTypes)
                F = cloudTypes{i};
                % in profile: sum(cloudtype) = sum(cloudy vertical bins)
                singleType.(F) = sum(x.(F),2)==sum(x.cloudy,2);
                singleType.(F)(cloudfree) = false;
            end
            
            % mixed clouds is where the profile is not cloudfree nor does it contain only one cloud type (=9)
            S.Cloud_Types = (length(cloudTypes)+1)*ones(size(singleType.Ci),'int8');
            for i = 1:length(cloudTypes)
                F = cloudTypes{i};
                S.Cloud_Types(singleType.(F)) = i;
            end
            S.Cloud_Types(cloudfree) = 0;
        case 'Cloud_Types_Lidar'
            % get the missing value
            mv = self.pseudo_fields.(field).atts.missing_value;
            
            % The main data
            clouds = S.CloudLayerType;
            
            % cloud types come from CloudLayerType, but the pseudo_field: Cloud_Types_Lidar is a
            % column integrated quantity. Initialize.
            S.Cloud_Types_Lidar=ones(size(clouds,1),1,'int8')*mv;
            
            % I need to loop over every point in order to use the index of the cloud
            % fraction and the clouds together
            logtext(atmlab('OUT'),'Assigning cloudtype to each profile\n')
            for i = 1:size(clouds,1)
                
                % Bad quality
                % Assign a missing value to a profile if any of the cloud boxes have CloudTypeQuality < 0.5
                bad = S.CloudTypeQuality(i,:)<.5;
                if any(bad)
                    S.Cloud_Types_Lidar(i) = mv;
                    continue
                end
                
                % Cloudy
                % Use the lidar cloud fraction to find the truly CLOUD FREE
                % measurements (-99), and mask partly cloudy cloudsat
                % footprints
                cloudy = S.CloudFraction(i,:);
                if any(cloudy>0&cloudy<1)
                    S.Cloud_Types_Lidar(i) = mv;
                    continue
                elseif all(cloudy==-99)
                    % cloud free
                    S.Cloud_Types_Lidar(i) = 0;
                    continue
                end
                
                cloudColumn = clouds(i,clouds(i,:)~=0);
                if isempty(cloudColumn)
                    % undetermined cloud type
                    S.Cloud_Types_Lidar(i) = 10;
                elseif length(unique(cloudColumn))>1
                    % mixed cloud column
                    S.Cloud_Types_Lidar(i) = 9;
                else
                    % column with a single cloud type
                    S.Cloud_Types_Lidar(i) = unique(cloudColumn);
                end
                
            end
            
        otherwise
            error('can''t be here')
            
    end
end

end