function fulldir = find_datadir_by_date(datevec, satname, dataset)

% find_datadir_by_date Find directory containing granules
%
% For the given datevec, satellite name and dataset, return a string with
% the path to the directory that contains the granules for this particular
% datevec.
%
% FORMAT
%
%   fulldir = find_datadir_by_date(datevec, satname, dataset)
%
% IN
%
%   datevec     vector      [year month day] etc.
%   satname     string      name of sat or cellstr {sat1 sat2}
%   dataset     string      name of dataset on satellite
%
% OUT
%
%   fulldir     string      path to directory
%
% $Id$

% verify basedir is defined and exists

errid = 'atmlab:find_datadir_by_date';

try
    basedir = datasets_config([dataset '_basedir']);
catch ME
    switch ME.identifier
        case 'atmlab:prstnt_struct:undefined'
            error(errid, ...
                'No basedir defined for %s, please define %s_basedir.', ...
                dataset, dataset);
        otherwise
            ME.rethrow();
    end
end
assert(any(basedir), errid, 'No basedir configured for %s', dataset);
assert(exist(basedir, 'dir')~=0, 'atmlab:find_granules_by_date', ...
        ['Configured data directory for %s is %s, ' ...
         'but this does not exist or is not a directory. ' ...
         'Please define %s_basedir correctly.'], ...
         dataset, basedir, dataset);
     
basedir = datasets_config([dataset '_basedir']);
subdir = datasets_config([dataset '_subdir']);
fulldir = fullfile(basedir, subdir);

fulldir = strrep_variables(fulldir, satname, datevec);