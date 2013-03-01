function S = cloud_cci_postprocessor(self,S,fields)
%% clouds_cci_postprocessor
%
% PURPOSE: To create "pseudo" fields that are not in the original cloud_cci
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


for F =fields
    field = F{1};
    mv = self.pseudo_fields.(field).atts.missing_value;
    switch field
        case {'iwp','ref_ice','cot_ice'}
            % Keeping record of the pixels that are deemed to be cloud free
            clearPixel = S.cc_total==0;
            
            % grab values flagged as ice phase
            icePhase = S.phase==2;

        otherwise
    end
    switch field
        case 'iwp'
            % depends on {cwp'  'phase'  'cc_total'}

            S.cwp(~(clearPixel | icePhase)) = mv;
            S.iwp = S.cwp;
        case 'ref_ice'
            % depends on {'phase','ref','cc_total'}
            
            S.ref(~(clearPixel | icePhase)) = mv;
            S.ref_ice = S.ref;
        case 'cot_ice'
            % depends on {'phase','cot','cc_total'}
            
            S.cot(~(clearPixel | icePhase)) = mv;
            S.cot_ice = S.cot;
        otherwise
    end
    
end

end
