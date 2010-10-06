function datafile = find_datafile_by_date(datevec, satname, sensor, ...
    tol)

% find_datafile_by_date Return full path of datafile by date/time
%
% Returns the full path of the datafile corresponding to the input
% arguments. It does not check whether this file actually exists. In
% fact, it may also be used to calculate the datafile that data should be
% written to (e.g. in the case of collocations).
%
% Needs paths set in datasets_config.
%
% FORMAT
%
%   datafile = find_datafile_by_date(datevec, sat, dataset[, tol])
%
% IN
%
%   datevec     vector  Date/time to find datafile for
%   satname     string* Name of satellite
%   dataset     string  Name of dataset
%   tol         number  Optional: tolerance in seconds. Sometimes, MSPPS
%                       doesn't start the same minute as AMSU :(.
%
%   * may be cell array of 2 strings if dataset is collocation_..., e.g.
%     naturally shared by 2 sats
%
% OUT
%
%   datafile    string     Path to the looked-for datafile.
%
%
% $Id$

errid = 'atmlab:find_datafile_by_date';

% implementation:
% 1. find the directory containing the files from basedir/subdir
% 2. if possible, calculate the filename directly
% 3. otherwise, list all files and match with regexp+tolerance

fulldir = find_datadir_by_date(datevec, satname, sensor);

if ~isnan(datasets_config([sensor '_filename'])) % calculate directly
    fn = datasets_config([sensor '_filename']);
    fn = strrep_variables(fn, satname, datevec);
    datafile = fullfile(fulldir, fn);
else % will search through all granules with find_granules_by_date
    [granules, paths] = find_granules_by_date(datevec(1), datevec(2), datevec(3), satname, sensor, false);
    if exist('tol', 'var') % use tolerance
        g = mat2cell(granules, size(granules, 1), [1 1 1 1 1]);
        grans_unisecs = date2unixsecs(g{:});
        dv_unisecs = date2unixsecs(datevec(1), datevec(2), datevec(3), datevec(4), datevec(5));
        found = abs(grans_unisecs - dv_unisecs) < tol;
    else
        found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);
    end
    
    nfound = sum(found);
    if nfound==0
        error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
    elseif nfound > 1
        error(errid, 'Multiple datefiles found for %s %s', satname, sensor);
    else
        datafile = paths{found};
    end
    
end

end