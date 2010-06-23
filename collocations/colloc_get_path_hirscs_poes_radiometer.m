function [fn, fnd] = colloc_get_path_hirscs_poes_radiometer(year, month, day, sat1, sat2)

% colloc_get_path_hirscs_poes_radiometer Return filenames that collocations would be written to
%
% Determine the full path of the files to which HIRSCS-MHS collocations for
% the given date and satellite should be written.
% Needs the following to be set in colloc_config:
%   'collocation_hirscs_poes_basedir'
%   'collocation_hirscs_poes_filename'
%   'collocation_hirscs_poes_data_filename'
%
% FORMAT
%
%   [fn, fnd] = colloc_get_path_hirscs_poes_radiometer(year, month, day, sat1, sat2)
%
% IN
%
%   year    (numeric)   Year for collocation file
%   month   (numeric)   Month for collocation file
%   day     (numeric)   Day for collocation file
%   sat1    string      Sat for HIRSCS
%   sat2    string      Sat for MHS
%
% OUT
%
%   fn      string      Full path to collocation file
%   fnd     string      Full path to data file
%
% $Id$

basedir = colloc_config('collocation_hirscs_poes_basedir');
basefile = colloc_config('collocation_hirscs_poes_filename');
basefile = strrep(basefile, '$SAT1', sat1);
basefile = strrep(basefile, '$SAT2', sat2);
basedata = colloc_config('collocation_hirscs_poes_data_filename');
basedata = strrep(basedata, '$SAT1', sat1);
basedata = strrep(basedata, '$SAT2', sat2);

d = fullfile(basedir, num2str(year, '%04d'), num2str(month, '%02d'), ...
    num2str(day, '%02d'));

fn = fullfile(d, basefile);
fnd = fullfile(d, basedata);