function S = modis_postprocessor(self,S,fields)
%% modis_postprocessor
%
% PURPOSE: To create "pseudo" fields that are not in the original modis data by 
%          post-processing fields that are in the original data
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


% READ dependent fields
% So far this function assumesa you always need cloud phase and quality
% flag
% common_fields = {'Quality_Assurance_1km','Cloud_Phase_Optical_Properties'};
% associatedFields = {'Cloud_Water_Path','Cloud_Effective_Radius','Cloud_Optical_Thickness'};
% pseudo_fields = {'modis_IWP','Tau_ice','Re_ice'};
% dependent_fields = [common_fields,associatedFields(ismember(pseudo_fields,fields))];

if any(ismember(fields,{'modis_IWP','Tau_ice','Re_ice'}))
    
% Keeping record of the pixels that are deemed to be cloud free
clearPixel = S.Cloud_Phase_Optical_Properties==1;

% Removing all points that are not flagged as ice clouds
icePhase = S.Cloud_Phase_Optical_Properties==3;

% only KEEP retrievals that are USEFUL and CONFIDENT

% this corresponds to the 1st and 2nd bit in the 2nd byte in
% Quality_Assurance_1km (regarding cloud_water_path. I assume the
% same apply to Re and Tau that CWP is based on anyway). By doing this
% I'm also disregarding values with marginal confidence
usefull=uint8(sum(2.^[0,1]));

% bitand only works on vectors
S.Quality_Assurance_1km = permute(S.Quality_Assurance_1km,[3,1,2]);

flaggedAsGood = bitand(typecast(S.Quality_Assurance_1km(2,:),'uint8'),usefull)==usefull;
flaggedAsGood = reshape(flaggedAsGood,size(icePhase,1),size(icePhase,2));

end

for F = fields
    switch F{1}
        case 'modis_IWP'
            S.Cloud_Water_Path(~(clearPixel | (icePhase & flaggedAsGood))) = ...
                self.pseudo_fields.modis_IWP.dependencies_struct.Cloud_Water_Path.atts.missing_value;
            
            S.modis_IWP = S.Cloud_Water_Path;
            S.modis_IWP(clearPixel)=0;
        case 'Re_ice'
            logtext(atmlab('OUT'),'scaling Cloud_Effective_Radius by 0.01\n')
            S.Cloud_Effective_Radius=S.Cloud_Effective_Radius*0.01;

            S.Cloud_Effective_Radius(~(clearPixel | (icePhase & flaggedAsGood))) = ...
                self.pseudo_fields.Re_ice.dependencies_struct.Cloud_Effective_Radius.atts.missing_value;
            
            S.Re_ice = S.Cloud_Effective_Radius;
            S.Re_ice(clearPixel)=0;
        case 'Tau_ice'
            logtext(atmlab('OUT'),'scaling Cloud_Optical_Thickness by 0.01\n')
            S.Cloud_Optical_Thickness=S.Cloud_Optical_Thickness*0.01;
            
            S.Cloud_Optical_Thickness(~(clearPixel | (icePhase & flaggedAsGood))) = ...
                self.pseudo_fields.Tau_ice.dependencies_struct.Cloud_Optical_Thickness.atts.missing_value;
            
            S.Tau_ice = S.Cloud_Optical_Thickness;
            S.Tau_ice(clearPixel)=0;
    end
end

end