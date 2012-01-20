function datasets_init
% DATASETS_INIT list paths and regexp for datasets in Kiruna
%
% PURPOSE: See datasets_config
%
% Created by Gerrit Holl
% $Id$

datasets_config('sat2netcdf', '/storage4/home/gerrit/downloads/sat2netcdf-0.4.jar');

% to find a datafile: search in basedir/subdir, first try filename with string
% substitution, otherwise list all and try to match regexp.

% to list all granules: listdir basedir/subdir, match regexp, limit to
% matching period

% variables: YEAR, YEAR02, MONTH, DAY, DOY, SAT, SAT1, SAT2
% regexp-output: year, doy, day, hour, minute , end. (end if the file ending)

% TODO/FIXME: convert to new OO-style with SatDataset

datasets_config('amsua_basedir', '/storage3/data/amsu');
datasets_config('amsua_subdir', '$SAT_amsua_$YEAR4/$MONTH/$DAY');
% Matlab doesn't seem to support nested groups, so have to stick with
% |-approach instead. Same regexp works for all POES.
datasets_config('amsua_regexp', '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})');

datasets_config('amsub_basedir', '/storage3/data/amsu');
datasets_config('amsub_subdir', '$SAT_amsub_$YEAR4/$MONTH/$DAY');
datasets_config('amsub_regexp', datasets_config('amsua_regexp'));

datasets_config('avhrr_basedir', '/storage3/data/avhrr');
datasets_config('avhrr_subdir', '$SAT_gac_$YEAR4/$MONTH/$DAY');
datasets_config('avhrr_regexp', datasets_config('amsua_regexp'));


datasets_config('calipso_basedir', '/storage3/data/calipso/CAL_LID_L2_05kmCLay-Prov-V3-01/');
datasets_config('calipso_subdir', '$YEAR4/$MONTH/$DOY');
datasets_config('calipso_regexp', '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2})-(?<minute>\d{2})-(?<second>\d{2})Z');

datasets_config('cpr_basedir', '/storage3/data/cloudsat/2B-CWC-RO.R04');
datasets_config('cpr_subdir', '$YEAR4/$DOY');
datasets_config('cpr_regexp', '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)');
% new style 2012-01-18:
x = datasets_config('cpr');
x.basedir = '/storage3/data/cloudsat/2B-CWC-RO.R04';
x.subdir = '$YEAR4/$DOY';
x.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)';

% same regexp works for all CloudSat's

datasets_config('cloudsat_1B_CPR_basedir', '/storage3/data/cloudsat/1B-CPR.R04/');
datasets_config('cloudsat_1B_CPR_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_1B_CPR_regexp', datasets_config('cpr_regexp'));

datasets_config('cloudsat_2B_GEOPROF_basedir', '/storage3/data/cloudsat/2B-GEOPROF.R04/' );
datasets_config('cloudsat_2B_GEOPROF_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2B_GEOPROF_regexp', datasets_config('cpr_regexp'));

datasets_config('cloudsat_2B_CWC_RO_basedir', datasets_config('cpr_basedir'));
datasets_config('cloudsat_2B_CWC_RO_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2B_CWC_RO_regexp', datasets_config('cpr_regexp'));

datasets_config('cloudsat_2B_CWC_RVOD_basedir', '/storage3/data/cloudsat/2B-CWC-RVOD.R04/');
datasets_config('cloudsat_2B_CWC_RVOD_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2B_CWC_RVOD_regexp', datasets_config('cpr_regexp'));


datasets_config('cloudsat_2C_PRECIP_COLUMN_basedir', '/storage3/data/cloudsat/2C-PRECIP-COLUMN.R04/');
datasets_config('cloudsat_2C_PRECIP_COLUMN_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_2C_PRECIP_COLUMN_regexp', datasets_config('cpr_regexp'));

datasets_config('cloudsat_ECMWF_AUX_basedir', '/storage3/data/cloudsat/ECMWF-AUX.R04');
datasets_config('cloudsat_ECMWF_AUX_subdir', datasets_config('cpr_subdir'));
datasets_config('cloudsat_ECMWF_AUX_regexp', datasets_config('cpr_regexp'));

datasets_config('hirs_basedir', '/storage3/data/hirs');
datasets_config('hirs_subdir', '$SAT_hirs_$YEAR4/$MONTH/$DAY');
datasets_config('hirs_regexp', datasets_config('amsua_regexp'));

datasets_config('hirscs_basedir', '/storage3/data/hirscs');
datasets_config('hirscs_subdir', 'LC_$SAT');
datasets_config('hirscs_filename', 'HIRS.$SAT.Y$YEAR2.D$DOY.nc.gz');
datasets_config('hirscs_regexp', '\.Y(?<year02>\d{2})\.D(?<doy>\d{3})\.');

datasets_config('isccp_dx_basedir','/storage3/data/isccp/dx');
datasets_config('isccp_dx_subdir' ,'');
datasets_config('isccp_dx_regexp' ,'');

datasets_config('isccp_d1_basedir','/storage3/data/isccp/d1');
datasets_config('isccp_d1_subdir' ,'');
datasets_config('isccp_d1_regexp' ,'D1\.[0-3]\.GLOBAL\.(?<year>\d{4})\.(?<month>\d{2})\.(?<day>\d{2})\.9999\.');

datasets_config('isccp_d2_basedir','/storage3/data/isccp/d2');
datasets_config('isccp_d2_subdir' ,'');
datasets_config('isccp_d2_regexp' ,'D2\.[0-3]\.GLOBAL\.(?<year>\d{4})\.(?<month>\d{2})\.99\.(?<hour>\d{2})(?<minute>\d{2})');

datasets_config('hoaps_iwp_basedir','/storage3/data/hoaps/iwp');
datasets_config('hoaps_iwp_subdir' ,'');
datasets_config('hoaps_iwp_regexp' ,'HOAPS-G.R30.M01.IWPA.(?<year>\d{4})(?<end>{3})$)');

datasets_config('hoaps_HTWdm_basedir','/storage3/data/hoaps/');
datasets_config('hoaps_HTWdm_subdir' ,'$YEAR4/$MONTH');
datasets_config('hoaps_HTWdm_regexp' ,'HTWdm(?<year>\d{4})(?<month>\d{2})(?<day>\d{2}).*(?<end>.{6})$');

datasets_config('hoaps_HTWmm_basedir','/storage3/data/hoaps/hoaps-g');
datasets_config('hoaps_HTWmm_subdir' ,'$YEAR4');
datasets_config('hoaps_HTWmm_regexp' ,'HTWmm(?<year>\d{4})(?<month>\d{2})(?<day>\d{2}).*(?<end>.{6})$');

datasets_config('mhs_basedir', '/storage3/data/mhs');
datasets_config('mhs_subdir', '$SAT_mhs_$YEAR4/$MONTH/$DAY');
datasets_config('mhs_regexp', datasets_config('amsua_regexp'));
% new style 2012-01-18:
x = datasets_config('mhs');
x.basedir = '/storage3/data/mhs';
x.subdir = '$SAT_mhs_$YEAR4/$MONTH/$DAY';
x.re = datasets_config('amsua_regexp');

datasets_config('modis_MOD08_M3_basedir','/storage3/data/modis/MOD08_M3/');
datasets_config('modis_MOD08_M3_subdir' ,'$YEAR4' );
datasets_config('modis_MOD08_M3_regexp' ,'MOD08_M3\.A(?<year>\d{4})(?<doy>\d{3})');

datasets_config('modis_MYD08_M3_basedir','/storage3/data/modis/MYD08_M3/');
datasets_config('modis_MYD08_M3_subdir' ,'$YEAR4' );
datasets_config('modis_MYD08_M3_regexp' ,'MYD08_M3\.A(?<year>\d{4})(?<doy>\d{3})');

datasets_config('modis_MYD06_L2_basedir','/storage3/data/modis/MYD06_L2/');
datasets_config('modis_MYD06_L2_subdir' ,'$YEAR4/$MONTH/$DAY' );
datasets_config('modis_MYD06_L2_regexp' ,'MYD06_L2\.A(?<year>\d{4})(?<doy>\d{3})\.(?<hour>\d{2})(?<minute>\d{2})');

datasets_config('mspps_basedir', '/storage3/data/mspps');
datasets_config('mspps_subdir', '');
datasets_config('mspps_regexp','(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2}).+(?<end>.{3})$');

datasets_config('patmosx_L2b_basedir','/storage3/data/patmosx/level2b/');
datasets_config('patmosx_L2b_subdir' ,'$YEAR4' );
datasets_config('patmosx_L2b_regexp' ,'patmosx_(?<satname>.{3})_(?<node>.{3})_(?<year>\d{4})_(?<doy>\d{3}).+(?<end>.{7})$');

datasets_config('patmosx_L3_basedir','/storage3/data/patmosx/level3/');
datasets_config('patmosx_L3_subdir','$YEAR4/$MONTH');
datasets_config('patmosx_L3_regexp','(?<year>\d{4})/(?<month>\d{2})/patmosx_.+_(?<node>.{3})_.._._(?<year>\d{4}).+(?<end>.{4})$');

%% COLLOCATION DATA SETS
datasets_config('collocation_cpr_mhs_basedir', '/storage4/user_data/gerrit/collocations_cloudsat_mhs');
datasets_config('collocation_cpr_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_filename', 'collocations_$SAT.nc.gz');

datasets_config('collocation_cpr_mhs_hdf5_basedir', '/local/gerrit/data/collocations_hdf5/collocations_cloudsat_mhs');
datasets_config('collocation_cpr_mhs_hdf5_subdir', '');
datasets_config('collocation_cpr_mhs_hdf5_filename', '$SAT_$YEAR4.h5');

datasets_config('collocation_cpr_mhs_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
datasets_config('collocation_cpr_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_legacy_filename', 'collocations_$SAT.mat');

datasets_config('collocation_cpr_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
datasets_config('collocation_cpr_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_data_legacy_filename', 'collocations_data_$SAT.mat');

datasets_config('collocation_cpr_mhs_meandata_legacy_basedir', '/storage4/user_data/gerrit/archived/20100308_collocations_cloudsat_poes/');
datasets_config('collocation_cpr_mhs_meandata_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_meandata_legacy_filename', 'collocations_meandata_$SAT.mat');

datasets_config('collocation_mhs_mhs_basedir', '/storage4/user_data/gerrit/collocations_mhs_mhs');
datasets_config('collocation_mhs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_mhs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('collocation_mhs_mhs_legacy_basedir', '/storage4/user_data/gerrit/collocations_mhs_mhs');
datasets_config('collocation_mhs_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_mhs_mhs_legacy_filename', 'collocations_$SAT1_$SAT2.mat');

datasets_config('collocation_mhs_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/collocations_mhs_mhs');
datasets_config('collocation_mhs_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_mhs_mhs_data_legacy_filename', 'collocations_data_$SAT1_$SAT2.mat');

datasets_config('collocation_cpr_avhrr_basedir', '/storage4/user_data/gerrit/collocations_cpr_avhrr');
datasets_config('collocation_cpr_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_avhrr_filename', 'collocations_$SAT.nc.gz');

datasets_config('collocation_hirscs_mhs_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
datasets_config('collocation_hirscs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_hirscs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('collocation_hirscs_mhs_legacy_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
datasets_config('collocation_hirscs_mhs_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_hirscs_mhs_legacy_filename', 'collocations_$SAT1_$SAT2.mat');

datasets_config('collocation_hirscs_mhs_data_legacy_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
datasets_config('collocation_hirscs_mhs_data_legacy_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_hirscs_mhs_data_legacy_filename', 'collocations_data_$SAT1_$SAT2.mat');

datasets_config('collocation_amsua_amsua_basedir', '/storage4/user_data/gerrit/collocations_amsua_amsua');
datasets_config('collocation_amsua_amsua_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_amsua_amsua_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('collocation_hirs_hirs_basedir', '/storage4/user_data/gerrit/collocations_hirs_hirs');
datasets_config('collocation_hirs_hirs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_hirs_hirs_filename', 'collocations_$SAT1_$SAT2.nc.gz');


datasets_config('collocation_collocation_cpr_mhs_avhrr_basedir', '/storage4/user_data/gerrit/collocations_collocation_cpr_mhs_avhrr');
datasets_config('collocation_collocation_cpr_mhs_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_collocation_cpr_mhs_avhrr_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('firstline_data', '/storage3/data/granules_firstline/firstline_$SAT_$SENSOR.mat');

datasets_config('blacklist', '/storage3/user_data/gerrit/blacklist_$SAT_$SENSOR.dat');
