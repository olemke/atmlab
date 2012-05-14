function S = common_read_dardarsub(file, varargin)
    % read dardarsub data
    %
    % format as other common_read_-functions.
    %
    % $Id$

    core_fields   = {'time','lat','lon'};
    extra_fields  = optargs(varargin, {{}});
    all_fields    = [core_fields(:); extra_fields(:)];

    S = loadncvar(file, all_fields);
    
    % get additional stuff
    D = datasets;
    info = D.dardarsub.find_info_from_granule(file);
    
    date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
    S.epoch = round(date2unixsecs(date.year, date.month, date.day));
    
    S.path = file;
    S.version = info.version;

    S = MaskInvalidGeoTimedataWithNaN(S);
end
