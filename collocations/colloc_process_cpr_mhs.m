function M = colloc_process_cpr_mhs(collocations, ...
    name_cpr, date_cpr, data_cpr, name_mhs, date_mhs, data_mhs)

% colloc_process_cpr_mhs Gather collocation info to store for CloudSat+MHS
%
% After the collocating process is done by 'collocate', one wants to
% collect some additional information: longitudes, latitudes, times,
% viewing angles, distances, intervals, etc. This function takes care of
% that in the case of CPR/MHS.
%
% All colloc_process_* functions are automatically called by
% collocate_granule and thus have the same interface. Not all arguments are
% used by all.
% 
% FORMAT
%
%   M = colloc_process_cpr_mhs(collocations, ...
%       name_cpr, date_cpr, data_cpr, ...
%       name_mhs, date_mhs, data_mhs)
%
% IN
%
%   collocations    Nx4 matrix  Collocations as returned by collocate
%   name_cpr        string      Name of satellite carrying CPR ('cloudsat')
%   date_cpr        vector      Date vector for CPR starting time
%   data_cpr        structure   Data for CPR, as returned by read_cpr
%   name_mhs        string      Name of MHS-carrying satellite
%   date_mhs        vector      Date vector for MHS starting time
%   data_mhs        structure   Data for MHS, as returned by read_mhs
%
% OUT
%
%   M               matrix      Matrix with one row for each collocation
%                               and columns as in
%                               colloc_config('cols_cpr_mhs').overlap
%
% $Id$

% prepare
c = colloc_config('cols_cpr_mhs');
c = c.overlap;
n = size(collocations, 1);
M = nan*zeros(n, c.NCOLS);
if n==0
    return % don't bother
end

% convert to cell array for easy passing into date2unixsecs
date_cpr_cell = num2cell(date_cpr);
date_mhs_cell = num2cell(date_mhs);

% row and column numbers
cr = collocations(:, 1);
ar = collocations(:, 3);
ac = collocations(:, 4);

% index for direct addressing
ai = sub2ind(size(data_mhs.lat), ar, ac);

%% cloudsat info

% lat/long
M(:, c.C_LONG) = data_cpr.lon(cr);
M(:, c.C_LAT) = data_cpr.lat(cr);

% time
% unixsecs2date(date2unixsecs(2007, 8, 13, 15, 15, 0)) results in
% 2007-08-13 15:14:59.999998... so if just the minute is taken (e.g.
% as input to find_datafile_by_date to recover the original swathfile
% on the SAT cluster) the date is wrong and the swathfile is not
% found. As a workaround, one second (which is irrelevant in any case)
% is added to the start time.
        
M(:, c.C_START, :) = date2unixsecs(date_cpr_cell{1:5}, 1);
M(:, c.C_TIME, :) = date2unixsecs(date_cpr_cell{1:3}, 0, 0, 0) + data_cpr.time(cr);
M(:, c.C_I, :) = cr;

%% amsub/mhs

M(:, c.B_LONG) = data_mhs.lon(ai);
M(:, c.B_LAT) = data_mhs.lat(ai);
M(:, c.B_START) = date2unixsecs(date_mhs_cell{1:5}, 1);
M(:, c.B_TIME) = date2unixsecs(date_mhs_cell{1:3}, 0, 0, 0) + data_mhs.time(ar);
M(:, c.B_I) = ar;
M(:, c.B_C) = ac;
M(:, c.B_DIST) = sphdist(data_cpr.lat(cr), data_cpr.lon(cr), ...
    data_mhs.lat(ai), data_mhs.lon(ai), constants('EARTH_RADIUS')/1e3);
M(:, c.B_INT) = M(:, c.B_TIME) - M(:, c.C_TIME);

%% amsua

amsua_path = find_datafile_by_date(date_mhs, name_mhs, 'amsua');

if amsua_path
    read_amsua = colloc_config('read_amsua');
    try
        amsua = read_amsua(amsua_path);
    catch ME
        if strcmp(ME.identifier, 'atmlab:atovs_get_l1c:zamsu2l1c')
            warning('atmlab:process_cpr_mhs', ...
                'SKIPPED: zamsu2l1c failed for %s', amsua_path);
            amsua = {};
        else
            ME.rethrow();
        end
    end
end

if ~isempty(amsua)
    [aah aaw] = size(amsua.lon); % amsu-a width, amsu-a height
    M(:, c.A_I) = min(max(round(ar/3), 1), aah); % amsu-a row
    M(:, c.A_C) = min(max(round(ac/3), 1), aaw); % amsu-a column
    aai = sub2ind(size(amsua.lat), M(:, c.A_I), M(:, c.A_C));
    M(:, c.A_LONG) = amsua.lon(aai);
    M(:, c.A_LAT) = amsua.lat(aai);
    M(:, c.A_START) = M(:, c.B_START);
    M(:, c.A_TIME) = date2unixsecs(date_mhs_cell{1:3}, 0, 0, 0) + ...
        amsua.time(M(:, c.A_I));
    M(:, c.A_DIST) = sphdist(data_cpr.lat(cr), data_cpr.lon(cr), ...
        amsua.lat(aai), amsua.lon(aai), constants('EARTH_RADIUS')/1e3);
    M(:, c.A_INT) = M(:, c.A_TIME) - M(:, c.C_TIME);
end

%% hirs

hirs_path = find_datafile_by_date(date_mhs, name_mhs, 'hirs');

if hirs_path
    read_hirs = colloc_config('read_hirs');
    try
        hirs = read_hirs(hirs_path);
    catch ME
        if strcmp(ME.identifier, 'atmlab:atovs_get_l1c:zamsu2l1c')
            warning('atmlab:process_cpr_mhs', ...
                'SKIPPED: zamsu2l1c failed for %s', amsua_path);
            hirs = {};
        else
            ME.rethrow();
        end
    end
end

if ~isempty(hirs)   
    % TODO: optimise this bit of code
    % find hirs scanline (row) closest in time for each mhs scanline
    hr = arrayfun(...
        @(v) mini(abs(hirs.time-v)), ...
        data_mhs.time(M(:, c.B_I))); 
    % find hirs pixel (col) in scanline closest in distance to CPR-point
    hc = arrayfun(...
        @(i) mini(...
            (hirs.lat(hr(i), :)-M(i, c.C_LAT)).^2 + ...
            (hirs.lon(hr(i), :)-M(i, c.C_LONG)).^2 ...
            ), 1:n);
    % find index from (row, column)
    hi = sub2ind(size(hirs.lat), hr, hc');
    % ready to add information to matrix
    M(:, c.H_LONG) = hirs.lon(hi);
    M(:, c.H_LAT) = hirs.lat(hi);
    M(:, c.H_START) = M(:, c.B_START);
    M(:, c.H_TIME) = date2unixsecs(date_mhs_cell{1:3}, 0, 0, 0) + hirs.time(hr);
    M(:, c.H_I) = hr;
    M(:, c.H_C) = hc;
    M(:, c.H_DIST) = sphdist(M(:, c.C_LAT), M(:, c.C_LONG), ...
        M(:, c.H_LAT), M(:, c.H_LONG), constants('EARTH_RADIUS')/1e3);
    M(:, c.H_INT) = M(:, c.H_TIME) - M(:, c.C_TIME);
end

% sort by: MHS row, then MHS column, then CloudSat pixel

M = sortrows(M, [c.B_I c.B_C c.C_I]);

end

function i = mini(v)
% mini return index for minimum of v (arrayfun wants 1 output)
[~, i] = min(v);
end
