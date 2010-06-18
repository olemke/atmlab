function [overlap, data, meandata] = collocate_date(year, month, day, sat1, sensor1, sat2, sensor2)

% collocate_date Collect all collocations for given date
%
% This m-file collects all collocations for the given date between the
% indicated sensor pairs and returns the result in a structure.
% Needs the following to be set in colloc_config:
%   'stdout' (defaults to 1)
%   'stderr' (defaults to 2)
%   'POES_satellite_names'
%   
%
% FORMAT
%
%   collocate_date(year, month, day, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which to find collocations
%   month   (numeric)   Month for which to find collocations
%   day     (numeric)   Day for which to find collocations
%   sat1    string      Primary satellite
%   sensor1 string      Sensor on sat1 to consider
%   sat2    string      Secondary satellite: POES means many
%   sensor2 string      Sensor on secondary satellite to consider
%
% OUT
%
%   S       structure   S contains the collocations for all satellites for the
%                       date of interest. Its fields are the satellite names
%                       (only one if sat2 is not equal to poes). The values of
%                       those fields are the collections of collocate_granule
%                       for all granules of sat1/sensor1 for that date.
%   data    structure   Similar to S but with data.
%
% $Id$

fid = colloc_config('stdout');

grans = find_granules_by_date(year, month, day, sat1, sensor1);
if isempty(grans)
    logtext(colloc_config('stderr'), 'no granules found %s/%s %d-%d-%d\n', ...
        sat1, sensor1, year, month, day);
end
ngrans = size(grans, 1);
% initialise overlap structure
empty = struct();
switch lower(sat2)
    case 'poes'
        sats = colloc_config('POES_satellite_names');
        for i = 1:length(sats)
            empty.(sats{i}) = []; % FIXME: get good width
        end
    otherwise
        empty.(sat2) = [];
end
overlap = empty;
data = empty;
meandata = empty;
nout = max(nargout, 1);
S = {empty, empty, empty};

for i = 1:ngrans
    hour = grans(i, 4);
    minute = grans(i, 5);
    
    logtext(fid, 'Collocating %s %s with %s %s %04d-%02d-%02d %02d:%02d\n', ...
        sat1, sensor1, sat2, sensor2, year, month, day, hour, minute);
    try
        [S{1:nout}] = collocate_granule(sat1, sensor1, sat2, sensor2, ...
            [year, month, day, hour, minute]);
    catch ME
        switch ME.identifier
            case 'atmlab:find_datafile_by_date'
                logtext(cscol('stderr'), 'Error in searching for datafile %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                    year, month, day, hour, minute, sat1, sensor1, ME.message);
                continue
            case {'atmlab:collocate', 'atmlab:atovs_get_l1c:zamsu2l1c'}
                logtext(cscol('stderr'), 'Error in collocating with datafile at %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                    year, month, day, hour, minute, sat1, sensor1, ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    [overlap, data, meandata] = colloc_concatenate_colloc_data_mean(...
        overlap, S{1}, data, S{2}, meandata, S{3});
end

end
