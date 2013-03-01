function S = dardarsub_postprocessor(self,S,fields)
%% dardarsub_postprocessor
%
%
% PURPOSE: To create "pseudo" fields that are not in the original dardarsub
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

% column integrate
% use dependent fields to BUILD the pseudo field. maybe transpose to get
% the right orientation

if isfield(S,'HEIGHT')
    S.HEIGHT = repmat(S.HEIGHT,size(S.iwc,1),1);
end
    
for F = fields
    field = F{1};
    
    switch field
        case 'dardar_IWP'
            
            S.dardar_IWP = column_integrate(S,{'iwc','HEIGHT'})';
            
        case 'dardar_ln_IWP_error'
            
            % iwc_max = exp(ln(iwc)+ln_iwc_error)
            %          = exp(ln(iwc)) * exp(ln_iwc_error)
            %         = iwc * exp(ln_iwc_error)
            
            %
            % As in eliasson13:_systematic_jgr Sect. 4.1
            % This is assumed OK:
            %
            % ln(IWP^+/IWP_0) \approx ln(IWP_0/IWP_-)
            % therefore
            % \sigma_{IWP}=\frac{ln(\frac{IWP^+}{IWP^-})}{2}
            
            IWP_plus = column_integrate(catstruct(S,struct('maxError',S.iwc.*exp(S.ln_iwc_error))),{'maxError','HEIGHT'})';
            IWP_minus = column_integrate(catstruct(S,struct('minError',S.iwc.*exp(-S.ln_iwc_error))),{'minError','HEIGHT'})';
            
            S.dardar_ln_IWP_error = log(IWP_plus./IWP_minus)/2;
            
    end
end

end