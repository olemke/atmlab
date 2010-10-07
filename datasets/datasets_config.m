function value = datasets_config(varargin)

% datasets_config Defines locations of datasets
%
% Similar to 'atmlab'.
%
% $Id$

persistent A

try
    [A,value] = prstnt_struct( A, @datasets_defs, varargin );
catch ME
    switch (ME.identifier)
        % see if any aliases can be identified
        case 'atmlab:prstnt_struct:undefined'
            varargin{1} = replace_aliases(varargin{1});
            [A,value] = prstnt_struct( A, @datasets_defs, varargin);
        otherwise
            ME.rethrow();
    end
end

end



function A = datasets_defs

%% define locations of tools

A.sat2netcdf = nan;

%% set where to find data
%
% For example values and explanation, see atmlab/site-specific/kiruna/datasets_init.m

A.cpr_basedir = nan;
A.cpr_subdir = nan;
A.cpr_regexp = nan;
A.cpr_filename = nan;

A.amsua_basedir = nan;
A.amsua_subdir = nan;
A.amsua_regexp = nan;
A.amsua_filename = nan;

A.amsub_basedir = nan;
A.amsub_subdir = nan;
A.amsub_regexp = nan;
A.amsub_filename = nan;

A.mhs_basedir = nan;
A.mhs_subdir = nan;
A.mhs_regexp = nan;
A.mhs_filename = nan;

A.hirs_basedir = nan;
A.hirs_subdir = nan;
A.hirs_regexp = nan;
A.hirs_filename = nan;

A.mspps_basedir = nan;
A.mspps_subdir = nan;
A.mspps_regexp = nan;
A.mspps_filename = nan;

A.avhrr_basedir = nan;
A.avhrr_subdir = nan;
A.avhrr_regexp = nan;
A.avhrr_filename = nan;

A.hirscs_basedir = nan;
A.hirscs_subdir = nan;
A.hirscs_regexp = nan;
A.hirscs_filename = nan;

A.firstline_data = '';

A.collocation_cpr_mhs_basedir = nan;
A.collocation_cpr_mhs_subdir = nan;
A.collocation_cpr_mhs_regexp = nan;
A.collocation_cpr_mhs_filename = nan;

A.collocation_mhs_mhs_basedir = nan;
A.collocation_mhs_mhs_subdir = nan;
A.collocation_mhs_mhs_regexp = nan;
A.collocation_mhs_mhs_filename = nan;

A.collocation_cpr_avhrr_basedir = nan;
A.collocation_cpr_avhrr_subdir = nan;
A.collocation_cpr_avhrr_regexp = nan;
A.collocation_cpr_avhrr_filename = nan;

A.collocation_hirscs_mhs_basedir = nan;
A.collocation_hirscs_mhs_subdir = nan;
A.collocation_hirscs_mhs_regexp = nan;
A.collocation_hirscs_mhs_filename = nan;

A.collocation_collocation_cpr_mhs_avhrr_basedir = nan;
A.collocation_collocation_cpr_mhs_avhrr_subdir = nan;
A.collocation_collocation_cpr_mhs_avhrr_regexp = nan;
A.collocation_collocation_cpr_mhs_avhrr_filename = nan;

end