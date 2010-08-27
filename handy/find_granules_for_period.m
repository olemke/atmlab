function allgrans = find_granules_for_period(date1, date2, sat, sensor)

% find_granules_for_period List all granules for sat/sensor for period
%
% For the period between date1 and date2, list all granules (as vectors
% indicating the starting date/time) available.
%
% FORMAT
%
%   allgrans = find_granules_for_period(date1, date2, sat, sensor)
%
% IN
%
%   date1   datevec     starting date
%   date2   datevec     ending date
%   sat     string      satellite
%   sensor  string      sensor
%
% OUT
%
%   allgrans matrix     all granules in daterange
%
% $Id$

dates = daterange(date1, date2);
ndates = size(dates, 1);

allgrans = nan*zeros(ndates*15, 5);
n = 0;
for i = 1:ndates
    date = dates(i, :);
    grans = find_granules_by_date(date(1), date(2), date(3), sat, sensor, false);
    ngrans = size(grans, 1);
    allgrans(n+1:n+ngrans, :) = grans;
    n = n + ngrans;
end

allgrans(isnan(allgrans(:, 1)), :) = [];
allgrans = sortrows(allgrans);