function collocate_and_store_date(year, month, day, ...
    sat1, sensor1, sat2, sensor2)

% collocate_and_store_date Collect collocations and store appropiately
%
% For a given date, check whether a collocation datafile exists.
% If it doesn't (or cscol('overwrite') is set), collocate the indicated
% satellites and sensors with each other and store the result in the
% appropiate datafile.
% Depends on the following configurations in colloc_config:
%   'filename_SENSOR1_SENSOR2', where SENSOR1 and SENSOR2 are as passed on
%   'overwrite' (true or false)
%   'stdout' (defaults to 1)
%
% FORMAT
%
%   collocate_and_store_date(year, month, day, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which to write collocations
%   month   (numeric)   Month for which to write collocations
%   day     (numeric)   Day for which to write collocations
%   sat1    string      Primary satellite to consider
%   sensor1 string      Sensor at sat1 to consider
%   sat2    string      Secondary satellite to consider (POES means many)
%   sensor2 string      Sensor at secondary satellite to consider
%
% OUT
%
%   none (but writes file with write_collocations)
%
% $Id$

% get filename

getfn = colloc_config(['filename_' sensor1 '_' sensor2]);
fn = getfn(year, month, day, sat1, sat2);

if ~exist(fn, 'file') || colloc_config('overwrite')
    [C{1:3}] = ...
         collocate_date(year, month, day, sat1, sensor1, sat2, sensor2);

    write_collocations(year, month, day, C{1:3}, sat1, sensor1, sat2, sensor2);
else
    logtext(colloc_config('stdout'), 'Already exists: %s\n', fn);
end
