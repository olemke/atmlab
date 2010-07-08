function datafile = find_datafile_by_date(datevec, satname, sensor)

% find_datafile_by_date Return full path of datafile by date/time
%
% Returns the full path of the datafile corresponding to the input
% arguments.
%
% Needs paths to datafiles set in colloc_config and assumes datafiles are
% stored in directories per day.
%
% TODO: maybe those paths should be set somewhere else? it 'atmlab'?
%
% FORMAT
%
%   datafile = find_datafile_by_date(datevec, sat, sensor)
%
% IN
%
%   datevec     vector  Date/time to find datafile for
%   satname     string  Name of satellite
%   sensor      string  Name of sensor
%
% OUT
%
%   datafile    string     Path to the looked-for datafile.
%
%
% $Id$

errid = 'atmlab:find_datafile_by_date';

basedir = colloc_config([sensor '_basedir']);
yeardir = colloc_config([sensor '_yeardir']);
yeardir = strrep(yeardir, '$YEAR', num2str(datevec(1)));
yeardir = strrep(yeardir, '$SAT', satname);
if isempty(yeardir) % not per year, calculate it instead
    calculator = colloc_config([sensor '_getpath']);
    fn = calculator(datevec(1), datevec(2), datevec(3), satname);
    datafile = fullfile(basedir, fn);
    if ~exist(datafile, 'file')
        error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
    end
    return
end

granules = find_granules_by_date(datevec(1), datevec(2), datevec(3), satname, sensor, false);
found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);

% find_granules_by_date returns granules in the order that their files are
% returned by dir, so this is consistent

datadir = fullfile(basedir, yeardir, num2str(datevec(2), '%02d'), num2str(datevec(3), '%02d'));
files = dir(datadir);
file_is_granule = arrayfun(@(x) any(regexp(x.name, colloc_config([sensor '_regexp']))), files);
granule_files = files(file_is_granule);
nfound = length(find(found));
if nfound==0
    error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
elseif nfound > 1
    error(errid, 'Multiple datefiles found for %s %s', satname, sensor);
else
    datafile = fullfile(datadir, granule_files(found).name);
end