function M_c = colloc_process_collocation_cpr_poes_avhrr(collocations, ...
    name1, date1, data1, ...
    name2, date2, data2)


% colloc_process_collocation_cpr_poes_avhrr Gather collocation info
%
% After collocating, we want to gather information about the collocations:
% not only indices and columns, but also time, lat, long, distance,
% interval. This function collects such data.
%
% FORMAT
%
%   M_c = colloc_process_collocation_cpr_poes_avhrr(collocations, ...
%       name1, date1, data1, ...
%       name2, date2, data2);
%
% IN
%
%   collocations    Nx4 matrix  As returned by collocate
%   name1           string      Name of primary satellite
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule.
%   data1           structure   Fields time, lat and lon should be present; as
%                               returned by
%                               colloc_read_collocation_cpr_poes
%   name2           string      Name of secondary satellite
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As data1, but for secondary granule; as
%                               returned by colloc_read_avhrr.
%
% OUT
%
%   M_c             Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$

% prepare
c = colloc_config('cols_collocation_cpr_poes_avhrr');
c = c.overlap;
n = size(collocations, 1);
M_c = nan*zeros(n, c.NCOLS);

% row and column numbers.
r1 = collocations(:, 1);
r2 = collocations(:, 3);
c2 = collocations(:, 4);

% index for direct addressing
i2 = sub2ind(size(data2.lat), r2, c2);

% convert to cell array for easy passing into date2unixsecs
date1_cell = num2cell(date1);
date2_cell = num2cell(date2);

%% store info

% time
M_c(:, c.CPR_POES_START) = round(date2unixsecs(date1_cell{1:3}));
M_c(:, c.AVHRR_START) = round(date2unixsecs(date2_cell{1:5}));

% unify_time_axis has made that data[12].time uses the earliest of the two
% as the epoch
time_epoch = min([date2unixsecs(date1_cell{1:3}, 0, 0, 0), ...
                  date2unixsecs(date2_cell{1:3}, 0, 0, 0)]);
time1 = time_epoch + data1.time(r1);              
M_c(:, c.AVHRR_TIME) = time_epoch + data2.time(r2);

% row/column
M_c(:, c.CPR_POES_LINENO) = r1;
M_c(:, c.AVHRR_ROW) = r2;
M_c(:, c.AVHRR_COL) = c2;

% lat/long
M_c(:, c.AVHRR_LAT) = data2.lat(i2);
%M_c(:, c.CPR_POES_LAT) = data1.lat(r1);
M_c(:, c.AVHRR_LONG) = data2.lon(i2);
%M_c(:, c.CPR_POES_LONG) = data1.lon(r1);

% dist/int
M_c(:, c.DIST_MHS_AVHRR) = sphdist(data1.lat(r1), data1.lon(r1), ...
    M_c(:, c.AVHRR_LAT), M_c(:, c.AVHRR_LONG), constants('EARTH_RADIUS')/1e3);
M_c(:, c.INT_MHS_AVHRR) = M_c(:, c.AVHRR_TIME) - time1;

M_c = sortrows(M_c, [c.CPR_POES_START c.CPR_POES_LINENO c.AVHRR_START c.AVHRR_TIME c.AVHRR_ROW c.AVHRR_COL]);