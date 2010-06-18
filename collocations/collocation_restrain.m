function rows = collocation_restrain(data, ranges)

% collocation_restrain Find rows fulfilling restrictions
%
% Find row numbers were certain limitations in the data are met.
%
% IN
%
%   data    matrix      As produced by collocation_read
%   ranges  Nx3 matrix  Matrix containing rows [colno min max], where data
%                       rows from the data are selected if
%                       min <= data(row, col) <= max
%
% OUT
%
%   rows    logical     Rows where limitations are met
%
% TODO:
% implement more complicated restrictions such as:
% - localtime
% - SZA
% - land/sea
% - season
%
% $Id$

rightrange = all(data(:, ranges(:, 1)) >= repmat(ranges(:, 2)', [size(data, 1) 1]), 2) & ...
             all(data(:, ranges(:, 1)) <= repmat(ranges(:, 3)', [size(data, 1) 1]), 2);

%

rows = rightrange;