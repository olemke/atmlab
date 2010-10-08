function S = find_info_from_granule(dataset, fname)

% find_info_from_granule Extract info from a granule filename
%
% For a given dataset and filename, return a structure with information
% extracted from the filename, such as year, month, day. This is just a
% short wrapper around <a href="matlab:help regexp">regexp</a>. If no information
% can be extracted, the result is an empty structure. All structure members
% are string, e.g. no conversions from string to number is done. Valid
% datasets are those that have a datasets_config('DATASET_regexp') defined,
% which means most of the datasets returned by <a href="matlab:help list_datasets">list_datasets</a>.
% The returned fields are at most those names defined in
% datasets_config('DATASET_regexp').
% Common fields are: year, month, day, doy. But anything matched by the
% regular expression is a field. This function is tested in the case that
% only the basename is passed, e.g. not including the directory. It may
% work also when passing the full path, but the regular expressions were
% not designed for this purpose, and the default regexps will not return
% any information contained not in the basename. However, read on for an
% example how such a regular expression could be constructed.
%
% More information about regular expressions at <a href="http://en.wikipedia.org/wiki/Regular_expression">Wikipedia</a>
%
% FORMAT
%
%   S = find_info_from_granule(dataset, fname)
%
% IN
%
%   dataset     string      describing the dataset
%   fname       string      the filename
%
% OUT
%
%   S           structure   members such as 'year', 'month', etc. describe
%                           matched info.
%
% EXAMPLES
%
% >> find_info_from_granule('cpr', '2006333114032_03133_CS_2B-CWC-RO_GRANULE_P_R04_E02.hdf.zip')
% 
% ans = 
% 
%       year: '2006'
%        doy: '333'
%       hour: '11'
%     minute: '40'
% 
% >> find_info_from_granule('mhs', '56037363.NSS.MHSX.NP.D09284.S1310.E1456.B0348485.GC.gz')
% 
% ans = 
% 
%       hour: '13'
%     minute: '10'
%
% Redefine regexp so that it works on a full path, not just on the basename:
%
% >> datasets_config('mhs_regexp', '\/(?<sat>[a-z0-9]{6})_mhs_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/.*\.S(?<hour>\d{2})(?<minute>\d{2})\.');
% >> find_info_from_granule('mhs', '/storage3/data/mhs/noaa18_mhs_2009/08/09/56037363.NSS.MHSX.NP.D09284.S1310.E1456.B0348485.GC.gz')
% 
% ans = 
% 
%        sat: 'noaa18'
%       year: '2009'
%      month: '08'
%        day: '09'
%       hour: '13'
%     minute: '10'
%
% But this will not match the basename:
%
% >> find_info_from_granule('mhs', '56037363.NSS.MHSX.NP.D09284.S1310.E1456.B0348485.GC.gz')
% 
% ans = 
% 
% 0x0 struct array with fields:
%     sat
%     year
%     month
%     day
%     hour
%     minute
%     
% Feel free to change the regular expressions to return additional
% information, but be sure not to break any existing matches.
% Have fun.
%
% $Id$

matchy = datasets_config([dataset '_regexp']);
S = regexp(fname, matchy, 'names');