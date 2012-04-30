function convert_dardar(dt1, dt2)
    % convert full dardar to subselected dardar
    %
    % FIXME DOC
    %
    % FIXME TEST
    %
    % $Id$
    
    dd_full = datasets_config('dardar');
    dd_sub = datasets_config('darsub');
    
    tostore = fieldnames(dd_sub.getmembers());
    [grans, paths] = dd_full.find_granules_for_period(dt1, dt2, '');
   
    builtins = {'time', 'lat', 'lon'};
    
    for i = 1:size(grans, 1);
        dt = grans(i, :);
        
        data = dd_full.read_granule(dt, '', ...
            setdiff(tostore, builtins), ...
            false, false, false); % (no duplicate removing, no force-on-error, no reloading)
        
        ncols = sum(cellfun(@(f) size(data.(f), 2), tostore));
        nrows = size(data.time, 1);
        data.height = repmat(data.height, [nrows 1]);

        M = zeros(nrows, ncols);
        nc = 1;
        
        for k = 1:length(tostore)
            fld = tostore{k};
            w = size(data.(fld), 2);
            rng = nc:(nc+w-1);
            M(:, rng) = data.(fld);
            cc.(fld) = rng;
            nc = nc + w;
        end
        
        dd_sub.cols = cc;
        
        [~, bs] = fileparts(paths{i});
        dd_sub.filename = [bs '_selection.nc.gz'];
        info = struct();
        info.title = 'Reduced DARDAR data';
        dd_sub.store(dt(1:3), '', M, info);
    end
    
end
