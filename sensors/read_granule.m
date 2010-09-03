function M = read_granule(sat, sensor, datevec)

% read_granule Read any sat/sensor granule (levels 1 and 2)
%
% High-level function to read a particular granule for a
% satellite/sensor-pair, if one doesn't know what function is suitable to
% use to read it. It also gets rid of ballast.
%
% FORMAT
%
%   M = read_granule(sat, sensor, datevec)
%
% IN
%
%   sat     string      Satellite (noaa18, cloudsat, etc.)
%   sensor  string      Sensor or dataset (mhs, hirs, cpr, hirscs, etc.)
%   datevec vector      Date-vector indicating the starting time.
%
% OUT
%
%   M       struct      Contains at least lat, lon, time and one or more
%                       data fields. Exact results depend on the particular
%                       satellite/sensor-pair.
%
% $Id$

% find datafile and function to read it
datafile = find_datafile_by_date(datevec, sat, sensor);
reader = colloc_config(['read_' sensor]);

% read datafile
M = reader(datafile);
nlines = size(M.time, 1);

% get rid of ballast
firstline = granule_first_line(sat, sensor, datevec);
for f = fieldnames(M)'
    fn = f{1};
    if isnumeric(M.(fn)) && size(M.(fn), 1) == nlines
        M.(fn) = M.(fn)(firstline:end, :, :, :, :); % FIXME! UGLY!
    end
end