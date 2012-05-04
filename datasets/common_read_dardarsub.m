function S = common_read_dardarsub(file, varargin)

    core_fields   = {'time','lat','lon'};
    extra_fields  = optargs(varargin, {{}});
    all_fields    = [core_fields(:); extra_fields(:)];

    S = loadncvar(file, all_fields);

end
