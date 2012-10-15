function S = common_read_dardarsub(file, varargin)
    % read dardarsub data
    %
    % format as other common_read_-functions.
    %
    % You can read special fields here:
    %               "dardar_IWP" is just the column integral of IWC, 
    %               "dardar_ln_IWP_uncertainty" is the column intral
    %               uncertainty. It has twice as many elements since it
    %               reports a minimum IWP and a maximum IWP 
    %
    %
    % NOTE: This function only reads the sub selected data saved as netcdf
    % on our servers. For regular DARDAR data use common_read_dardar
    %
    % $Id$

    core_fields   = {'time','lat','lon'};
    extra_fields  = optargs(varargin, {{}});
    all_fields    = [core_fields(:); extra_fields(:)];
    
    % valid pseudo fields that are not in the original data but are built
    % on fields from the existing data fields
    pseudo_fields = {'dardar_IWP','dardar_ln_IWP_error'};
    
    S = loadncvar(file, all_fields(~ismember(all_fields,pseudo_fields)) );
    
    % get additional stuff
    D = datasets;
    info = D.dardarsub.find_info_from_granule(file);
    
    date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
    S.epoch = round(date2unixsecs(date.year, date.month, date.day));
    
    if any(ismember(pseudo_fields,extra_fields))
        for P = pseudo_fields(:)'
            S = dealWithPseudoFields(S,P{1},file);
        end
    end

    S.path = file;
    S.version = info.version;

    if isfield(S,'height')
        fprintf('Saving memory: extracting height vector from repetitive height matrix...\n')
        S.height = S.height(:,1);
    end

    
    S = MaskInvalidGeoTimedataWithNaN(S);
end

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. The fields the pseudo fields required are further
% assumed to be frivolous and therefore removed afterwards, unless these
% fields were already read before this function.
% READ dependent fields
switch field
    case 'dardar_IWP'
        dependent_fields = {'iwc','height'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file, F{1});
        end
    case 'dardar_ln_IWP_error'
        dependent_fields = {'ln_iwc_error','iwc','height'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file, F{1});
        end
end

% column integrate
% use dependent fields to BUILD the pseudo field. maybe transpose to get
% the right orientation
switch field
    case 'dardar_IWP'
        
        S.dardar_IWP = column_integrate(S,{'iwc','height'})';

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
        
        IWP_plus = column_integrate(catstruct(S,struct('maxError',S.iwc.*exp(S.ln_iwc_error))),{'maxError','height'})';
        IWP_minus = column_integrate(catstruct(S,struct('minError',S.iwc.*exp(-S.ln_iwc_error))),{'minError','height'})';
        
        S.dardar_ln_IWP_error = log(IWP_plus./IWP_minus)/2;
        
end

S=rmfield(S,dependent_fields(rmflag));

end