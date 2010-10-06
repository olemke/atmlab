function M = read_collocs_data_mean(fn, fn_data, fn_meandata, c, cols)

% read_collocs_data_mean read rows from threeset where third may be means
%
% Given the paths to three M-files containing matrices for collocations,
% collocation data and collocation meandata respectively, and a 'cols' cell
% array describing what columns to return from them, reads the requested
% data from those files. 'cols' either has the number of rows of
% fn/fn_data, or, if fn_meandata is given, the number of rows of
% fn_meandata. This functionality has moved between functions quite a lot,
% but is presently here because it's shared between
% read_collocs_date_cloudsat_poes and read_collocs_date_cscolmhs
%
% FORMAT
%
%   M = read_collocs_data_mean(fn, fn_data, fn_meandata, cols)
%
% IN
%
%   fn          string      filename with collocation matrix
%   fn_data     string      filename with collocation data matrix
%   fn_meandata string      filename with collocation meandata matrix
%   c           structure   describing the fields, like cscol('cols')
%   cols        cell array  cells with what fields to read
%
% OUT
%
%   M           NxM matrix  Matrix containing the collected info
%
% ***** FIXME: In transition to NetCDF! *****
%
% $Id$

%% read data
if strcmp(fn(end-1:end), 'gz') % NetCDF FIXME
    logtext(atmlab('OUT'), 'Reading %s\n', fn);
    filenames = gunzip(fn, atmlab('WORK_AREA'));
    ncid = netcdf.open(filenames{1}, 'NOWRITE');
    delete(filenames{1});
    
    varids = zeros(size(cols));
    varwidth = zeros(size(cols));
    hasmean = false;
    % check dimensions, if any mean will need those first
    % also to know pre-alloc size
    alloc_length = 0;
    for i = 1:length(cols)
        if isnumeric(cols{i}) % refers to no. in previous
            continue
        end
        col = cols{i};
        % If col is an alias (e.g. MHS = AMSU(16:20)), replace accordingly
        if any(strcmp(col, fieldnames(c.aliases)))
            % if columns to read specified, replace those as well
            if i~=length(cols) && isnumeric(cols{i+1})
                cols{i+1} = c.aliases.(col){2}(cols{i+1});
            end
            cols{i} = c.aliases.(col){1};
            col = cols{i};
        end
        % proceed with getting information
        varid = netcdf.inqVarID(ncid, col);
        [~, ~, dimids] = netcdf.inqVar(ncid, varid);
        % check that it has <3 dimensions
        assert(length(dimids)<3, 'atmlab:read_collocs_data_mean', ...
            'Error: variable %s has %d dimensions, but shall have max 2', ...
            col, length(dimids));
        
        if length(dimids)==1
            % only Collocations/Averaged_collocations, so no width, so it's
            % a vector, width=1
            varwidth(i) = 1;
        end
        for dimid = dimids
            [dimname, dimlen] = netcdf.inqDim(ncid, dimid);
            switch dimname
                case 'Collocations'
                    if ~hasmean
                        alloc_length = dimlen;
                    end
                case 'Averaged_collocations'
                    hasmean = true;
                    alloc_length = dimlen;
                otherwise
                    % not Collocations/Averaged_collocations, so additional
                    % dimension, so width=dimlen, unless user has specified
                    % the additional dimension
                    % check if additional dimension specified:
                    if i~=length(cols) && isnumeric(cols{i+1})
                        varwidth(i) = length(cols{i+1});
                    else
                        varwidth(i) = dimlen;
                    end
            end
        end % for each dim
        varids(i) = varid;
    end % for each col
    M = zeros(alloc_length, sum(varwidth));
    if alloc_length==0 % nothing
        return
    end
    if hasmean
        var_mean = netcdf.inqVarID(ncid, 'FIRST');
        rows = netcdf.getVar(ncid, var_mean);
    else
        rows = true(alloc_length, 1);
    end

    n = 1; % keep track of dims
    for i = 1:length(cols)
        if varids(i)==0 % not a var, see comment about skipping above
            continue;
        end
        var = netcdf.getvar(ncid, varids(i));
        % determine what rows to read
        if size(var, 1) > alloc_length
            rows_here = rows;
        elseif size(var, 1) == alloc_length
            rows_here = true(alloc_length, 1);
        else
            error('atmlab:read_collocs_data_mean', ...
                'Incorrect number of rows in data');
        end
        % determine what columns to read
        if i~=length(cols) && varids(i+1)==0 % next var is column
            cols_here = cols{i+1};
        else % read all columns
            cols_here = 1:varwidth(i);
        end
        M(:, n:(n+varwidth(i)-1)) = ...
            reshape(var(rows_here, cols_here), [alloc_length varwidth(i)]);
        n = n + varwidth(i);
    end
else
    warning('atmlab:read_collocs_data_mean', ...
        ['Collocations are being moved from MAT-files to NetCDF. ' ...
         'Reading MAT-files will be phased out soon.']);
    cols_overlap = cols{1};
    cols_data = cols{2};
    cols_mean = cols{3};
    
    if any(cols_overlap) || any(cols_mean)
        logtext(atmlab('OUT'), 'Reading %s\n', fn);
        overlap = load(fn);
        n = size(overlap.collocations, 1);
    end
    
    if any(cols_data)
        logtext(atmlab('OUT'), 'Reading %s\n', fn_data);
        data = load(fn_data);
        n = size(data.data, 1);
    end
    
    if any(cols_mean)
        logtext(atmlab('OUT'), 'Reading %s\n', fn_meandata);
        meandata = load(fn_meandata);
    end
    
    
    %% read wanted columns from data
    
    % check whether to read all pixels or only one per MHS
    if any(cols_mean)
        rows = meandata.data_averaged(:, c.meandata.FIRST);
        n = length(rows);
    else
        rows = true(1, n);
    end
    
    % make sure overlap, data and meandata all exist (possibly empty) so that I
    % can concatenate them later
    if ~exist('overlap', 'var')
        overlap.collocations = zeros(n, 0);
    end
    
    if ~exist('data', 'var')
        data.data = zeros(size(overlap.collocations, 1), 0);
    end
    
    if ~exist('meandata', 'var')
        meandata.data_averaged = zeros(n, 0);
    end
    
    if ~any(rows)
        M = [];
        return
    end
    
    % get the actual data
    M = [overlap.collocations(rows, cols_overlap) ...
        data.data(rows, cols_data) ...
        meandata.data_averaged(:, cols_mean)];
end
