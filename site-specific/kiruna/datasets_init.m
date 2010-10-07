function datasets_init

% datasets_init Set Kiruna-settings for datasets

datasets_config('sat2netcdf', '/storage4/home/gerrit/downloads/sat2netcdf-0.4.jar');

% to find a datafile: search in basedir/subdir, first try filename with string
% substitution, otherwise list all and try to match regexp.

% to list all granules: listdir basedir/subdir, match regexp, limit to
% matching period

% variables: YEAR, YEAR02, MONTH, DAY, DOY, SAT, SAT1, SAT2
% regexp-output: year, doy, hour, minute

datasets_config('cpr_basedir', '/storage3/data/cloudsat/2B-CWC-RO.R04');
datasets_config('cpr_subdir', '$YEAR4/$DOY');
datasets_config('cpr_regexp', '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_');

datasets_config('amsua_basedir', '/storage3/data/amsu');
datasets_config('amsua_subdir', '$SAT_amsua_$YEAR4/$MONTH/$DAY');
datasets_config('amsua_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('amsub_basedir', '/storage3/data/amsu');
datasets_config('amsub_subdir', '$SAT_amsub_$YEAR4/$MONTH/$DAY');
datasets_config('amsub_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('mhs_basedir', '/storage3/data/mhs');
datasets_config('mhs_subdir', '$SAT_mhs_$YEAR4/$MONTH/$DAY');
datasets_config('mhs_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('hirs_basedir', '/storage3/data/hirs');
datasets_config('hirs_subdir', '$SAT_hirs_$YEAR4/$MONTH/$DAY');
datasets_config('hirs_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('mspps_basedir', '/storage3/data/mspps');
datasets_config('mspps_subdir', '$SAT_orbital_$YEAR4/$MONTH/$DAY');
datasets_config('mspps_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('avhrr_basedir', '/storage3/data/avhrr');
datasets_config('avhrr_subdir', '$SAT_gac_$YEAR4/$MONTH/$DAY');
datasets_config('avhrr_regexp', '\.S(?<hour>\d{2})(?<minute>\d{2})\.');

datasets_config('hirscs_basedir', '/storage3/data/hirscs');
datasets_config('hirscs_subdir', 'LC_$SAT');
datasets_config('hirscs_filename', 'HIRS.$SAT.Y$YEAR2.D$DOY.nc.gz');
datasets_config('hirscs_regexp', '\.Y(?<year02>\d{2})\.D(?<doy>\d{3})\.');

datasets_config('firstline_data', '/storage3/data/granules_firstline/firstline_$SAT_$SENSOR.mat');



datasets_config('collocation_cpr_mhs_basedir', '/storage4/user_data/gerrit/collocations_cloudsat_mhs');
datasets_config('collocation_cpr_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_mhs_filename', 'collocations_$SAT.nc.gz');

datasets_config('collocation_mhs_mhs_basedir', '/storage4/user_data/gerrit/collocations_mhs_mhs');
datasets_config('collocation_mhs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_mhs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('collocation_cpr_avhrr_basedir', '/storage4/user_data/gerrit/collocations_cpr_avhrr');
datasets_config('collocation_cpr_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_cpr_avhrr_filename', 'collocations_$SAT.nc.gz');

datasets_config('collocation_hirscs_mhs_basedir', '/storage4/user_data/gerrit/collocations_hirscs_mhs');
datasets_config('collocation_hirscs_mhs_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_hirscs_mhs_filename', 'collocations_$SAT1_$SAT2.nc.gz');

datasets_config('collocation_collocation_cpr_mhs_avhrr_basedir', '/storage4/user_data/gerrit/collocations_collocation_cpr_mhs_avhrr');
datasets_config('collocation_collocation_cpr_mhs_avhrr_subdir', '$YEAR4/$MONTH/$DAY');
datasets_config('collocation_collocation_cpr_mhs_avhrr_filename', 'collocations_$SAT1_$SAT2.nc.gz');
