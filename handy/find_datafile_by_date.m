function datafile = find_datafile_by_date(datevec, satname, sensor, ...
    tol)

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
%   datafile = find_datafile_by_date(datevec, sat, sensor[, tol])
%
% IN
%
%   datevec     vector  Date/time to find datafile for
%   satname     string* Name of satellite
%   sensor      string  Name of sensor
%   tol         number  Optional: tolerance in seconds. Sometimes, MSPPS
%                       doesn't start the same minute as AMSU :(.
%
%   * may be cell array of strings if sensor is collocation_...
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
if ischar(satname) % satname may be cell array
    yeardir = strrep(yeardir, '$SAT', satname);
end
datadir = fullfile(basedir, yeardir, num2str(datevec(2), '%02d'), num2str(datevec(3), '%02d'));

% try with dedicated filename calculator
if isempty(yeardir) % not per year, calculate it instead
    calculator = colloc_config([sensor '_getpath']);
    fn = calculator(datevec(1), datevec(2), datevec(3), satname);
    datafile = fullfile(basedir, fn);
    if ~exist(datafile, 'file')
        error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
    end
    return
end

% try to get filename from sensor_filename
hasfn = false;
try
    fn = colloc_config([sensor '_filename']);
    hasfn = true;
catch ME
    switch ME.identifier
        case 'atmlab:prstnt_struct:undefined'
            % no filename
        otherwise
            ME.rethrow();
    end
end
if hasfn
    if iscellstr(satname)
        for i = 1:length(satname)
            fn = strrep(fn, ['$SAT' num2str(i)], satname{i});
        end
    else
        fn = strrep(fn, '$SAT', satname);
    end
    datafile = fullfile(datadir, fn);
    return
end

% if all else fails: search through all granules until satisfied

granules = find_granules_by_date(datevec(1), datevec(2), datevec(3), satname, sensor, false);
if exist('tol', 'var') % use tolerance
    g = mat2cell(granules, size(granules, 1), [1 1 1 1 1]);
    grans_unisecs = date2unixsecs(g{:});
    dv_unisecs = date2unixsecs(datevec(1), datevec(2), datevec(3), datevec(4), datevec(5));
    found = abs(grans_unisecs - dv_unisecs) < 120;
else
    found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);
end

% find_granules_by_date returns granules in the order that their files are
% returned by dir, so this is consistent

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