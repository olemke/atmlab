function filename = colloc_get_filename_hirscs(year, month, day, sat)

% colloc_get_filename_hirscs Calculate hirscs filename
%
% From year, month, day and sat, get the hirscs filename.
% For now, sat here has to be given in the format that it's called in the
% storage on the sat-cluster: n16, n17, etc. There's no routine yet to
% convert from full names to abbreviations.
%
% FORMAT
%
%   filename = colloc_get_filename_hirscs(year, month, day, sat)
%
% IN
%
%   year    number
%   month   number
%   day     number
%   sat     string
%
% $Id$

year_twodigit = datestr(datenum([year month day]), 'yy');
doy = num2str(dayofyear(year, month, day), '%03d');

subdir = ['LC_' sat];
basename = ['HIRS.' sat '.Y' year_twodigit '.D' doy '.nc'];
filename = fullfile(subdir, basename);

if ~exist(fullfile(colloc_config('hirscs_basedir'), filename), 'file') % try gzipped instead
    filename = [filename '.gz'];
end
