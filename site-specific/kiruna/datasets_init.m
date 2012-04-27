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


x = datasets_config('avhrr_cmsaf');
x.basedir = '/storage3/data/cmsaf_avhrr_gac_cwp/';
x.subdir = '$YEAR4/$MONTH/$DAY';
x.re = 'RR_AVHRR_L2_cp_(?<satname>[A-Z0-9]{6})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hour>\d{2})(?<minute>\d{2})_v(?<version>\d{1})';

x = datasets_config('calipso');
x.basedir = '/storage3/data/calipso/CAL_LID_L2_05kmCLay-Prov-V3-01';
x.subdir = '$YEAR4/$MONTH/$DAY';
x.re = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2})-(?<minute>\d{2})-(?<second>\d{2})Z';


%% CLOUDSAT

% NEW STYLE
x = datasets_config('cpr');
x.basedir = '/storage3/data/cloudsat/2B-CWC-RO.R04';
x.subdir = '$YEAR4/$DOY';
x.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)';

x = datasets_config('cpr_rvod');
x.basedir = '/storage3/data/cloudsat/2B-CWC-RVOD.R04';
x.subdir = '$YEAR4/$DOY';
x.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)';

x = datasets_config('cpr_cldclass');
x.basedir = '/storage3/data/cloudsat/2B-CLDCLASS.R04';
x.subdir = '$YEAR4/$DOY';
x.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)';


x = datasets_config('dardar');
x.basedir = '/storage3/data/dardar';
x.subdir = '$YEAR4/$MONTH/$DAY';
x.re = 'DARDAR-CLOUD_v(?<version>.+)_(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})';

% Matlab doesn't seem to support nested groups, so have to stick with
% |-approach instead. Same regexp works for all POES.
poes_re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

x = datasets_config('mhs');
x.basedir = '/storage3/data/mhs';
x.subdir = '$SAT_mhs_$YEAR4/$MONTH/$DAY';
x.re = poes_re;

x = datasets_config('amsua');
x.basedir = '/storage3/data/amsu';
x.subdir = '$SAT_amsua_$YEAR4/$MONTH/$DAY';
x.re = poes_re;

x = datasets_config('amsub');
x.basedir = '/storage3/data/amsu';
x.subdir = '$SAT_amsub_$YEAR4/$MONTH/$DAY';
x.re = poes_re;

x = datasets_config('hirs');
x.basedir = '/storage3/data/hirs';
x.subdir = '$SAT_hirs_$YEAR4/$MONTH/$DAY';
x.re = poes_re;

x = datasets_config('modis_aqua_l2');
x.basedir = '/storage3/data/modis/MYD06_L2/';
x.subdir = '$YEAR4/$MONTH/$DAY';
x.re = 'MYD06_L2\.A(?<year>\d{4})(?<doy>\d{3})\.(?<hour>\d{2})(?<minute>\d{2})\.(?<version>\d{3})';

x = datasets_config('mspps');
x.basedir = '/storage3/data/mspps/';
x.subdir = '$SAT_orbital_$YEAR4/$MONTH/$DAY';
x.re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

x = datasets_config('patmosx');
x.basedir = '/storage3/data/patmosx/level2b/';
x.subdir = '$SAT_$YEAR4';
x.re = 'patmosx_(?<satname>[a-z0-9]{3})_asc_(?<year>\d{4})_(?<doy>\d{3})_v(?<version>\d{2}).+(?<end>.{7})$';

%% COLLOCATION DATA SETS

x = datasets_config('collocation_avhrrCMSAF_cpr');
x.basedir   = '/storage4/user_data/seliasson/collocations_avhrrCMSAF_cpr/core';
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_avhrrCMSAF_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

x = datasets_config('collocation_calipso_cpr');
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_calipso_cpr_$YEAR4_$MONTH_$DAY.nc.gz';
x.basedir   = '/storage4/user_data/seliasson/collocations_calipso_cloudsat/core';

x = datasets_config('collocation_cpr_dardar');
x.basedir   = '/storage4/user_data/seliasson/collocations_cpr_dardar/core';
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_cpr_dardar_$YEAR4_$MONTH_$DAY.nc.gz';

x = datasets_config('collocation_cpr_modis');
x.basedir   = '/storage4/user_data/seliasson/collocations_cloudsat_modis/core';
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_cpr_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

x = datasets_config('collocation_mhs_cpr');
x.basedir   = '/storage4/user_data/gerrit/testing/collocations_mhs_cpr';
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_$SAT.nc.gz';

x = datasets_config('collocation_mspps_cpr');
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_mspps_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
x.basedir   = '/storage4/user_data/seliasson/collocations_mspps_cloudsat/core';

x = datasets_config('collocation_patmosx_cpr');
x.subdir    = '$YEAR4/$MONTH/$DAY';
x.filename  = 'collocations_patmosx_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
x.basedir   = '/storage4/user_data/seliasson/collocations_patmosx_cloudsat/core';


datasets_config('firstline_data', '/storage3/data/granules_firstline/firstline_$SAT_$SENSOR.mat');

datasets_config('blacklist', '/storage3/user_data/gerrit/blacklist_$SAT_$SENSOR.dat');

%% DEPRECATED STYLE

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


% OLD STYLE
datasets_config('cpr_basedir', '/storage3/data/cloudsat/2B-CWC-RO.R04');
datasets_config('cpr_subdir', '$YEAR4/$DOY');
datasets_config('cpr_regexp', '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_.+(?<end>.{8}$)');

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

datasets_config('mhs_basedir', '/storage3/data/mhs');
datasets_config('mhs_subdir', '$SAT_mhs_$YEAR4/$MONTH/$DAY');
datasets_config('mhs_regexp', datasets_config('amsua_regexp'));


% OLD STYLE
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
end
