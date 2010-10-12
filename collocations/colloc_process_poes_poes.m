function M = colloc_process_poes_poes(collocations, ...
    name1, date1, data1, ...
    name2, date2, data2)

% colloc_process_poes_poes Gather collocation info to store for MHS+MHS
%
% After collocating, we want to gather information about the collocations: not
% only indices and columns, but also time, lat, long, distance, interval. This
% file collects such data.
%
% FORMAT
%
%   M = colloc_process_poes_poes(collocations, ...
%       name1, date1, data1, ...
%       name2, date2, data2);
%
% IN
%
%   collocations    Nx4 matrix  As returned by collocate or collocate2
%   name1           string      Name of primary satellite (not used here)
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule.
%   data1           structure   Fields time, lat and lon should be present; as
%                               returned by read_mhs
%   name2           string      Name of secondary satellite (not used here)
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$

% prepare
c = colloc_constants('cols_mhs_mhs');
c = c.overlap;
n = size(collocations, 1);
M = nan*zeros(n, c.NCOLS);

% convert to cell array for easy passing into date2unixsecs
date1_cell = num2cell(date1);
date2_cell = num2cell(date2);

% row and column numbers
r1 = collocations(:, 1);
c1 = collocations(:, 2);
r2 = collocations(:, 3);
c2 = collocations(:, 4);

% index for direct addressing
i1 = sub2ind(size(data1.lat), r1, c1);
i2 = sub2ind(size(data2.lat), r2, c2);

%% store info

% lat/long
M(:, c.LAT1) = data1.lat(i1);
M(:, c.LAT2) = data2.lat(i2);
M(:, c.LONG1) = data1.lon(i1);
M(:, c.LONG2) = data2.lon(i2);

% time
M(:, c.START1) = round(date2unixsecs(date1_cell{1:5}));
M(:, c.START2) = round(date2unixsecs(date2_cell{1:5}));

M(:, c.TIME1) = data1.epoch + data1.time(r1);
M(:, c.TIME2) = data2.epoch + data2.time(r2);

% index/column
M(:, c.I1) = r1;
M(:, c.I2) = r2;
M(:, c.C1) = c1;
M(:, c.C2) = c2;

% distance and interval
M(:, c.DIST) = sphdist(M(:, c.LAT1), M(:, c.LONG1), ...
    M(:, c.LAT2), M(:, c.LONG2), constants('EARTH_RADIUS')/1e3);
M(:, c.INT) = M(:, c.TIME2) - M(:, c.TIME1);

%% remove doubles

wrongrows = (M(:, c.I1) < granule_first_line(name1, amsub_or_mhs(name1), date1)) & ...
            (M(:, c.I2) < granule_first_line(name2, amsub_or_mhs(name2), date2));
M(wrongrows, :) = [];
