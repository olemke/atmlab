function value = datasets_config(varargin)

% datasets_config Defines datasets and associated info
%
% This m-file interacts with a <a href="matlab:help prstnt_struct">persistent structure</a>
% and defines a number of <a href="matlab:help SatDataset">SatDataset</a>s.
%
% Site-specific information for those datasets can be set by adding
% datasets_init to your path. This is executed when datasets_config is run
% for the first time.
%
% For example settings, see site-specific/kiruna/datasets_init.m. If adding
% a new dataset, it is recommended to also set defaults in the
% site-specific initialisation, so that others can use it directly and that
% it can serve as an example to people at other sites.

% Created by Gerrit
% $Id$

persistent A

persistent initialised

if isempty(initialised)
    addsite
    if exist('datasets_init', 'file')==2
        logtext(atmlab('OUT'), 'datasets_config first run, initialising...\n');
        initialised = true;
        datasets_init;
    else
        warning('atmlab:datasets:datasets_config', ...
                'Cannot find datasets_init, not initialising');
    end
        
end

try
    [A,value] = prstnt_struct( A, @datasets_defs, varargin );
catch ME
    switch (ME.identifier)
        % see if any aliases can be identified
        case 'atmlab:input:undefined'
            varargin{1} = replace_aliases(varargin{1});
            [A,value] = prstnt_struct( A, @datasets_defs, varargin);
        otherwise
            ME.rethrow();
    end
end

end


function A = datasets_defs

%% define locations of tools and meta-stuff

A.sat2netcdf = nan;
A.firstline_data = ''; % contains global default
A.blacklist = nan;

%% define datasets
%
% See also atmlab/site-specific/kiruna/datasets_init.m

A.avhrr_cmsaf = SatDataset('name','avhrr_cmsaf_gac',...
                   'reader', @common_read_avhrr_cmsaf_gac, ...
                   'granule_duration',7200);

A.calipso = SatDataset('name', 'calipso', ...
                   'satname', 'calipso', ...
                   'reader', @common_read_calipso, ...
                   'granule_duration', 5932);

A.cpr = SatDataset('name', 'cpr', ...
                   'satname', 'cloudsat', ...
                   'reader', @common_read_cpr, ...
                   'granule_duration', 5932);
               
A.cpr_rvod = SatDataset('name', 'CPR_RVOD', ...
                   'satname', 'cloudsat', ...
                   'reader', @common_read_cpr, ...
                   'granule_duration', 5932);
               
A.cpr_cldclass = SatDataset('name', 'CPR_CLDCLASS', ...
                   'satname', 'cloudsat', ...
                   'reader', @common_read_cpr, ...
                   'granule_duration', 5932);

               
A.cpr_1B = SatDataset('name', 'CPR_1B', ...
                   'satname', 'cloudsat', ...
                   'reader', @common_read_cpr, ...
                   'granule_duration', 5932);

A.dardar = SatDataset('name','dardar',...
                   'satname', 'atrain', ...
                   'reader', @common_read_dardar, ...
                   'granule_duration',5932);
             
A.mhs = SatDataset('name', 'mhs', ...
                   'reader', @common_read_poes_radiometer, ...
                   'granule_duration', 6130);
               

A.modis_aqua_l2 = SatDataset('name', 'modis_aqua_L2', ...
    'reader', @common_read_modis, ...
    'granule_duration', 300);%, ...
    %'dataset','MYD06_L2'); % Commented out by Gerrit, is this used?

A.mspps = SatDataset('name', 'mspps', ...
    'reader', @common_read_mspps, ...
    'granule_duration', 6130);

A.patmosx = SatDataset('name', 'patmosx', ...
                   'reader', @common_read_patmosx, ...
                   'granule_duration', 86400); % new style 2012-01-31


%% COLLOCATION DATASETS

A.collocation_avhrrCMSAF_cpr = CollocatedDataset(A.cpr,A.avhrr_cmsaf,...
    'name','CollocatedDataset_avhrrCMSAF_cpr','distance',5,'interval',600);

% calipso is a 5km product and must therefore be the primary dataset
A.collocation_calipso_cpr = CollocatedDataset(A.calipso,A.cpr,...
    'name','CollocatedDataset_calipso_cpr','distance',5,'interval',180);

A.collocation_cpr_modis = CollocatedDataset(A.cpr,A.modis_aqua_l2,...
    'name','CollocatedDataset_cpr_modis','distance',2,'interval',180);

A.collocation_cpr_dardar = CollocatedDataset(A.cpr,A.dardar,...
    'name','CollocatedDataset_cpr_dardar','distance',1,'interval',1); % these are always collocated

A.collocation_mhs_cpr = CollocatedDataset(A.mhs, A.cpr,...
    'name','CollocatedDataset_mhs_cpr','distance',20,'interval',600);

A.collocation_mspps_cpr   = CollocatedDataset(A.mspps,A.cpr,...
    'name','CollocatedDataset_mspps_cpr','distance',20,'interval',600);

A.collocation_patmosx_cpr = CollocatedDataset(A.patmosx,A.cpr,...
    'name','CollocatedDataset_patmosx_cpr','distance',8,'interval',600);

A.collocation_mhs_mhs = CollocatedDataset(A.mhs, A.mhs, ...
    'name', 'collocation_mhs_mhs', 'distance', 15, 'interval', 900);

% FIXME GH: implement those as classes
%A.holl10_data = AssociatedDataset(A.collocation_cpr_mhs, 'name', 'holl10 data');
%A.holl10_meandata = AssociatedDataset(A.collocation_cpr_mhs, 'name', 'holl10 mean data');




%% deprecated style!

A.amsua_basedir = nan;
A.amsua_subdir = nan;
A.amsua_regexp = nan;
A.amsua_filename = nan;

A.amsub_basedir = nan;
A.amsub_subdir = nan;
A.amsub_regexp = nan;
A.amsub_filename = nan;

A.avhrr_basedir = nan;
A.avhrr_subdir = nan;
A.avhrr_regexp = nan;
A.avhrr_filename = nan;


A.cpr_basedir = nan;
A.cpr_subdir = nan;
A.cpr_regexp = nan;
A.cpr_filename = nan;

A.cloudsat_1B_CPR_basedir = nan;
A.cloudsat_1B_CPR_subdir = nan;
A.cloudsat_1B_CPR_regexp = nan;
A.cloudsat_1B_CPR_filename = nan;

A.cloudsat_2B_GEOPROF_basedir = nan;
A.cloudsat_2B_GEOPROF_subdir = nan;
A.cloudsat_2B_GEOPROF_regexp = nan;
A.cloudsat_2B_GEOPROF_filename = nan;

A.cloudsat_2B_CWC_RO_basedir = nan;
A.cloudsat_2B_CWC_RO_subdir = nan;
A.cloudsat_2B_CWC_RO_regexp = nan;
A.cloudsat_2B_CWC_RO_filename = nan;

A.cloudsat_2B_CWC_RVOD_basedir = nan;
A.cloudsat_2B_CWC_RVOD_subdir = nan;
A.cloudsat_2B_CWC_RVOD_regexp = nan;
A.cloudsat_2B_CWC_RVOD_filename = nan;

A.cloudsat_2C_PRECIP_COLUMN_basedir = nan;
A.cloudsat_2C_PRECIP_COLUMN_subdir = nan;
A.cloudsat_2C_PRECIP_COLUMN_regexp = nan;
A.cloudsat_2C_PRECIP_COLUMN_filename = nan;

A.cloudsat_ECMWF_AUX_basedir = nan;
A.cloudsat_ECMWF_AUX_subdir = nan;
A.cloudsat_ECMWF_AUX_regexp = nan;
A.cloudsat_ECMWF_AUX_filename = nan;


A.hirs_basedir = nan;
A.hirs_subdir = nan;
A.hirs_regexp = nan;
A.hirs_filename = nan;

A.hirscs_basedir = nan;
A.hirscs_subdir = nan;
A.hirscs_regexp = nan;
A.hirscs_filename = nan;

%old
A.mhs_basedir = nan;
A.mhs_subdir = nan;
A.mhs_regexp = nan;
A.mhs_filename = nan;


% old
A.mspps_basedir = nan;
A.mspps_subdir = nan;
A.mspps_regexp = nan;
A.mspps_filename = nan;


% OLD STYLE
A.collocation_cpr_mhs_basedir = nan;
A.collocation_cpr_mhs_subdir = nan;
A.collocation_cpr_mhs_regexp = nan;
A.collocation_cpr_mhs_filename = nan;

A.collocation_cpr_mhs_hdf5_basedir = nan;
A.collocation_cpr_mhs_hdf5_subdir = nan;
A.collocation_cpr_mhs_hdf5_regexp = nan;
A.collocation_cpr_mhs_hdf5_filename = nan;

A.collocation_cpr_mhs_legacy_basedir = nan;
A.collocation_cpr_mhs_legacy_subdir = nan;
A.collocation_cpr_mhs_legacy_regexp = nan;
A.collocation_cpr_mhs_legacy_filename = nan;

A.collocation_cpr_mhs_data_legacy_basedir = nan;
A.collocation_cpr_mhs_data_legacy_subdir = nan;
A.collocation_cpr_mhs_data_legacy_regexp = nan;
A.collocation_cpr_mhs_data_legacy_filename = nan;

A.collocation_cpr_mhs_meandata_legacy_basedir = nan;
A.collocation_cpr_mhs_meandata_legacy_subdir = nan;
A.collocation_cpr_mhs_meandata_legacy_regexp = nan;
A.collocation_cpr_mhs_meandata_legacy_filename = nan;

A.collocation_mhs_mhs_basedir = nan;
A.collocation_mhs_mhs_subdir = nan;
A.collocation_mhs_mhs_regexp = nan;
A.collocation_mhs_mhs_filename = nan;


A.collocation_mhs_mhs_hdf5_basedir = nan;
A.collocation_mhs_mhs_hdf5_subdir = nan;
A.collocation_mhs_mhs_hdf5_regexp = nan;
A.collocation_mhs_mhs_hdf5_filename = nan;

A.collocation_mhs_mhs_legacy_basedir = nan;
A.collocation_mhs_mhs_legacy_subdir = nan;
A.collocation_mhs_mhs_legacy_regexp = nan;
A.collocation_mhs_mhs_legacy_filename = nan;

A.collocation_mhs_mhs_data_legacy_basedir = nan;
A.collocation_mhs_mhs_data_legacy_subdir = nan;
A.collocation_mhs_mhs_data_legacy_regexp = nan;
A.collocation_mhs_mhs_data_legacy_filename = nan;

A.collocation_cpr_avhrr_basedir = nan;
A.collocation_cpr_avhrr_subdir = nan;
A.collocation_cpr_avhrr_regexp = nan;
A.collocation_cpr_avhrr_filename = nan;

A.collocation_cpr_avhrr_hdf5_basedir = nan;
A.collocation_cpr_avhrr_hdf5_subdir = nan;
A.collocation_cpr_avhrr_hdf5_regexp = nan;
A.collocation_cpr_avhrr_hdf5_filename = nan;


A.collocation_cpr_avhrr_legacy_basedir = nan;
A.collocation_cpr_avhrr_legacy_subdir = nan;
A.collocation_cpr_avhrr_legacy_regexp = nan;
A.collocation_cpr_avhrr_legacy_filename = nan;

A.collocation_hirscs_mhs_basedir = nan;
A.collocation_hirscs_mhs_subdir = nan;
A.collocation_hirscs_mhs_regexp = nan;
A.collocation_hirscs_mhs_filename = nan;

A.collocation_hirscs_mhs_hdf5_basedir = nan;
A.collocation_hirscs_mhs_hdf5_subdir = nan;
A.collocation_hirscs_mhs_hdf5_regexp = nan;
A.collocation_hirscs_mhs_hdf5_filename = nan;

A.collocation_hirscs_mhs_legacy_basedir = nan;
A.collocation_hirscs_mhs_legacy_subdir = nan;
A.collocation_hirscs_mhs_legacy_regexp = nan;
A.collocation_hirscs_mhs_legacy_filename = nan;

A.collocation_hirscs_mhs_data_legacy_basedir = nan;
A.collocation_hirscs_mhs_data_legacy_subdir = nan;
A.collocation_hirscs_mhs_data_legacy_regexp = nan;
A.collocation_hirscs_mhs_data_legacy_filename = nan;

A.collocation_amsua_amsua_basedir = nan;
A.collocation_amsua_amsua_subdir = nan;
A.collocation_amsua_amsua_regexp = nan;
A.collocation_amsua_amsua_filename = nan;

A.collocation_hirs_hirs_basedir = nan;
A.collocation_hirs_hirs_subdir = nan;
A.collocation_hirs_hirs_regexp = nan;
A.collocation_hirs_hirs_filename = nan;

A.collocation_collocation_cpr_mhs_avhrr_basedir = nan;
A.collocation_collocation_cpr_mhs_avhrr_subdir = nan;
A.collocation_collocation_cpr_mhs_avhrr_regexp = nan;
A.collocation_collocation_cpr_mhs_avhrr_filename = nan;

A.collocation_collocation_cpr_mhs_avhrr_hdf5_basedir = nan;
A.collocation_collocation_cpr_mhs_avhrr_hdf5_subdir = nan;
A.collocation_collocation_cpr_mhs_avhrr_hdf5_regexp = nan;
A.collocation_collocation_cpr_mhs_avhrr_hdf5_filename = nan;

A.collocation_collocation_cpr_mhs_avhrr_legacy_basedir = nan;
A.collocation_collocation_cpr_mhs_avhrr_legacy_subdir = nan;
A.collocation_collocation_cpr_mhs_avhrr_legacy_regexp = nan;
A.collocation_collocation_cpr_mhs_avhrr_legacy_filename = nan;
end
