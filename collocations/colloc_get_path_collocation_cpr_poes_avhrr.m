function [fn, fnd, fnm] = colloc_get_path_collocation_cpr_poes_avhrr(year, month, day, sat1, sat2)

% colloc_get_path_collocation_cpr_poes_avhrr Return filenames that collocations would be written to
%
% Determine the full path of the files to which collocations between
% CPR/POES-collocation and AVHRR should be written to, for the given date
% and satellite pair.
% Needs the following to be set in colloc_config:
%   'collocation_collocation_cpr_poes_avhrr_basedir'
%   'collocation_collocation_cpr_poes_avhrr_yeardir'
%   'collocation_collocation_cpr_poes_avhrr_filename'
%   'collocation_collocation_cpr_poes_avhrr_data_filename'
%   'collocation_collocation_cpr_poes_avhrr_meandata_filename'
%
% FORMAT
%
%   [fn, fnd, fnm] = collocation_collocation_cpr_poes_avhrr_basedir(year, month, day, sat1, sat2)
%
% IN
%
%   year    (numeric)   Year for collocation file
%   month   (numeric)   Month for collocation file
%   day     (numeric)   Day for collocation file
%   sat1    string      Primary satellite
%   sat2    string      Secondary satellite
%
% Note: usually you want sat1==sat2
%
% OUT
%
%   fn      string      Full path to collocation file
%   fnd     string      Full path to data file
%   fnm     string      Full path to mean data file
%
% $Id$

basedir = colloc_config('collocation_collocation_cpr_poes_avhrr_basedir');
basefile = colloc_config('collocation_collocation_cpr_poes_avhrr_filename');

basedata = colloc_config('collocation_collocation_cpr_poes_avhrr_data_filename');
basemean = colloc_config('collocation_collocation_cpr_poes_avhrr_meandata_filename');

basefile = strrep(basefile, '$SAT1', sat1);
basefile = strrep(basefile, '$SAT2', sat2);
basedata = strrep(basedata, '$SAT1', sat1);
basedata = strrep(basedata, '$SAT2', sat2);
basemean = strrep(basemean, '$SAT1', sat1);
basemean = strrep(basemean, '$SAT2', sat2);

d = fullfile(basedir, num2str(year, '%04d'), num2str(month, '%02d'), ...
    num2str(day, '%02d'));

fn = fullfile(d, basefile);
fnd = fullfile(d, basedata);
fnm = fullfile(d, basemean);