function first = granule_first_line(sat, sensor, d, reload)

% granule_first_line Returns first scanline not present in previous granule
%
% For a certain granule, return the number of the first scanline that
% is not in the previous scanline. This m-file uses a previously created
% database (a hashtable). This hash-table is cached between subsequent
% calls of the function.
%
% FORMAT
%
%   first = granule_first_line(sat, sensor, datevec[, reload])
%
% IN
%
%   sat         string      Satellite
%   sensor      string      Sensor
%   datevec     vector      Staring date/time for granule
%   reload      logical     (optional) Reload scanline data (i.e. not
%                           cached). Defaults to false.
%
% OUT
%
%   first       number      First scanline not in previous granule.
%                           Special values: -1 (no data found), -2 (no
%                           previous granule found)
%
% $Id$

persistent S;

if isempty(S)
    S = struct;
end

if ~exist('reload', 'var')
    reload = false;
end

if isfield(S, sat) && isfield(S.(sat), sensor) && ~reload
    ht = S.(sat).(sensor);
else
    scanfile = colloc_config('firstline_data');
    scanfile = strrep(scanfile, '$SAT', sat);
    scanfile = strrep(scanfile, '$SENSOR', sensor);
    
    t = load(scanfile);
    ht = t.ht;
    S.(sat).(sensor) = ht;
end

if isscalar(d)
    unisecs = uint32(d);
else
    dv = num2cell(d);
    unisecs = uint32(date2unixsecs(dv{:}));
end

first = ht.get(unisecs);
if isempty(first)
    error('atmlab:granule_first_line', 'no data found for %s/%s @ %d', ...
        sat, sensor, unisecs);
end
