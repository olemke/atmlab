function S = common_read_dardarsub(file, varargin)
    % read dardarsub data
    %
    % format as other common_read_-functions.
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

    S = MaskInvalidGeoTimedataWithNaN(S);
end

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. Will check in the loop if this field is present. The
% fields the pseudo fields required are further assumed to be frivolous and therefore
% removed afterwards. This part is hardcoded

% READ dependent fields
switch field
    case 'dardar_IWP'
        dependent_fields = {'iwc','height'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file, F{1});
        end
    case 'dardar_ln_IWP_error'
        dependent_fields = {'ln_iwc_error','height'};
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
        
        S.dardar_ln_IWP_error = column_integrate(S,{'ln_iwc_error','height'})';

end

S=rmfield(S,dependent_fields(rmflag));

end