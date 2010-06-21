function [fn, fnd, fnm] = colloc_get_path_cpr_poes_radiometer(year, month, day, ~, sat2)

% colloc_get_path_cpr_poes_radiometer Return filenames that collocations would be written to
%
% Determine the full path of the files to which CloudSat-MHS collocations for
% the given date and satellite should be written.
% Needs the following to be set in colloc_config:
%   'collocation_cpr_mhs_basedir'
%   'collocation_cpr_mhs_filename'
%   'collocation_cpr_mhs_data_filename'
%   'collocation_cpr_mhs_meandata_filename'
%
% FORMAT
%
%   [fn, fnd, fnm] = colloc_get_path_cpr_poes_radiometer(year, month, day, sat1, sat2)
%
% IN
%
%   year    (numeric)   Year for collocation file
%   month   (numeric)   Month for collocation file
%   day     (numeric)   Day for collocation file
%   sat1    string      Ignored; only CloudSat has CPR
%   sat2    string      Which POES satellite?
%
% OUT
%
%   fn      string      Full path to collocation file
%   fnd     string      Full path to data file
%   fnm     string      Full path to mean data file
%
% $Id$

basedir = colloc_config('collocation_cpr_mhs_basedir');
basefile = colloc_config('collocation_cpr_mhs_filename');
basefile = strrep(basefile, '$SAT', sat2);
basedata = colloc_config('collocation_cpr_mhs_data_filename');
basedata = strrep(basedata, '$SAT', sat2);
basemean = colloc_config('collocation_cpr_mhs_meandata_filename');
basemean = strrep(basemean, '$SAT', sat2);

d = fullfile(basedir, num2str(year, '%04d'), num2str(month, '%02d'), ...
    num2str(day, '%02d'));

fn = fullfile(d, basefile);
fnd = fullfile(d, basedata);
fnm = fullfile(d, basemean);
