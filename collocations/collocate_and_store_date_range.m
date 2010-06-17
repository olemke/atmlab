function collocate_and_store_date_range(date_start, date_end, ...
        sat1, sensor1, sat2, sensor2)

% collocate_and_store_date_range Collocate and store for all those dates
%
% Needs 'stdout' to be set in colloc_config.
%
% FORMAT
%
%   collocate_and_store_date(date_start, date_end, ...
%       sat1, sensor1, sat2, sensor2)
%
% IN
%
%   date_start  1x3 array   Starting date
%   date_end    1x3 array   Ending date
%   sat1        string      Primary satellite
%   sensor1     string      Primary sensor
%   sat2        string      Secondary satellite
%   sensor2     string      Secondary sensor
%
% $Id$

logtext(colloc_config('stdout'), 'Starting collocations\n');
logtext(colloc_config('stdout'), '%s %s vs. %s %s\n', sat1, sensor1, sat2, sensor2);
logtext(colloc_config('stdout'), 'From %s to %s\n', mat2str(date_start), mat2str(date_end));
alldates = daterange(date_start, date_end);
for i = 1:size(alldates, 1);
    year = alldates(i, 1);
    month = alldates(i, 2);
    day = alldates(i, 3);
    logtext(colloc_config('stdout'), 'collocating %04d-%02d-%02d\n', ...
        year, month, day);
    collocate_and_store_date(year, month, day, sat1, sensor1, sat2, sensor2);
end
logtext(colloc_config('stdout'), 'Finished!\n');
