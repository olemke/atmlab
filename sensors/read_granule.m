function M = read_granule(sat, sensor, datevec, remdouble)

% read_granule Read any sat/sensor granule (levels 1 and 2)
%
% High-level function to read a particular granule for a
% satellite/sensor-pair, if one doesn't know what function is suitable to
% use to read it. It also gets rid of ballast.
%
% Uses colloc_config('read_SENSOR') to find out what function to use to
% read this particular data. Uses granule_first_line to find out the first
% scanline to use (e.g. the rest are doubles).
%
% FORMAT
%
%   M = read_granule(sat, sensor, datevec)
%
% IN
%
%   sat         string      Satellite (noaa18, cloudsat, etc.)
%   sensor      string      Sensor or dataset (mhs, hirs, cpr, hirscs, etc.)
%   datevec     vector      Date-vector indicating the starting time.
%   remdouble   logical     (optional) Remove doubles or not? Default yes.
%
% OUT
%
%   M       struct      Contains at least lat, lon, time and one or more
%                       data fields. Exact results depend on the particular
%                       satellite/sensor-pair.
%
% $Id$

if ~exist('remdouble', 'var')
    remdouble = true;
end

% find datafile and function to read it
datafile = find_datafile_by_date(datevec, sat, sensor);
reader = colloc_config(['read_' sensor]);

% read datafile
logtext(colloc_config('stdout'), '%s(''%s'')\n', ...
    func2str(reader), datafile);
M = reader(datafile);
logtext(colloc_config('stdout'), 'read %s\n', datafile);
nlines = size(M.time, 1);

if remdouble
    % read ballast
    firstline = granule_first_line(sat, sensor, datevec);
    % get rid of ballast
    for f = fieldnames(M)'
        fn = f{1};
        if isnumeric(M.(fn)) && size(M.(fn), 1) == nlines
            % magic in next lines explained at
            % http://www.mathworks.de/matlabcentral/newsreader/view_thread/290890
            sz = size(M.(fn));
            M.(fn) = reshape(M.(fn)(firstline:nlines, :), [nlines-firstline+1, sz(2:end)]);
        end
    end
end
end