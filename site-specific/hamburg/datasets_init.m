function datasets_init
% DATASETS_INIT define paths and regexp for datasets in Hamburg
%
% 
%
% Created by Salomon Eliasson based on Gerrit Holl's kiruna version
% $Id$

%datasets_config('sat2netcdf', '/storage4/home/gerrit/downloads/2010/05/sat2netcdf-0.4.jar');

% to find a datafile: search in basedir/subdir, first try filename with string
% substitution, otherwise list all and try to match regexp.

% to list all granules: listdir basedir/subdir, match regexp, limit to
% matching period

% variables: YEAR, YEAR02, MONTH, DAY, DOY, SAT, SAT1, SAT2
% regexp-output: year, doy, day, hour, minute , end. (end if the file ending)

if ~define_datasets('check')
    define_datasets;
end

D = datasets;

base_dir = '/scratch/uni/u237/';
data_base_dir = [base_dir 'data/'];
userdata_base_dir = [base_dir 'user_data/'];

%% datasets generated elsewhere

% -------
% active
% -------
D.calipso.basedir = [data_base_dir 'calipso/CAL_LID_L2_05kmCLay-Prov-V3-01'];
D.calipso.subdir = '$YEAR4/$MONTH/$DAY';
D.calipso.re = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})T(?<hour>\d{2})-(?<minute>\d{2})-(?<second>\d{2})Z';

D.cpr.basedir = [data_base_dir 'cloudsat/2B-CWC-RO.R04'];
D.cpr.subdir = '$YEAR4/$DOY';
D.cpr.re = '(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})\d{2}_(?<granule_number>\d{5})_CS_(?<product_name>[\dA-Z\-]*)_(?<subset>[A-Z]*)_(?<id>[A-Z])_(?<release>R[0-9]{2})_(?<epoch>E\d{2})(?<end>\.hdf.zip)';

D.CPR_RVOD.basedir = [data_base_dir 'cloudsat/2B-CWC-RVOD.R04'];
D.CPR_RVOD.subdir = D.cpr.subdir;
D.CPR_RVOD.re = D.cpr.re;

D.cprCloud.basedir = [data_base_dir 'cloudsat/2B-CLDCLASS.R04'];
D.cprCloud.subdir = D.cpr.subdir;
D.cprCloud.re = D.cpr.re;

D.cprCloudLidar.basedir = [data_base_dir 'cloudsat/2B-CLDCLASS-LIDAR.R04'];
D.cprCloudLidar.subdir = D.cpr.subdir;
D.cprCloudLidar.re = D.cpr.re;

D.CPR_2C_ICE.basedir = [data_base_dir 'cloudsat/2C-ICE.R04'];
D.CPR_2C_ICE.subdir = D.cpr.subdir;
D.CPR_2C_ICE.re = D.cpr.re;

D.CPR_ECMWF.basedir = [data_base_dir 'cloudsat/ECMWF-AUX.R04'];
D.CPR_ECMWF.subdir = D.cpr.subdir;
D.CPR_ECMWF.re = D.cpr.re;

D.dardar.basedir = [data_base_dir 'dardar'];
D.dardar.subdir = '$YEAR4/$YEAR4_$MONTH_$DAY';
D.dardar.re = 'DARDAR-CLOUD_v(?<version>.+)_(?<year>\d{4})(?<doy>\d{3})(?<hour>\d{2})(?<minute>\d{2})';

% Matlab doesn't seem to support nested groups, so have to stick with
% |-approach instead. Same regexp works for all POES.
poes_re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

% ---------
% Passive
% --------

D.avhrr.basedir = [data_base_dir 'avhrr'];
D.avhrr.subdir = '$SAT_gac_$YEAR4/$MONTH/$DAY';
D.avhrr.re = poes_re;

D.avhrr_cmsaf_gac.basedir = [data_base_dir 'cmsaf_avhrr_gac_cwp/'];
D.avhrr_cmsaf_gac.subdir = '$YEAR4/$MONTH/$DAY';
D.avhrr_cmsaf_gac.re = 'RR_AVHRR_L2_cp_(?<satname>[A-Z0-9]{6})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})_(?<hour>\d{2})(?<minute>\d{2})_v(?<version>\d{1})';

D.amsua.basedir = [data_base_dir 'amsu'];
D.amsua.subdir = '$SAT_amsua_$YEAR4/$MONTH/$DAY';
D.amsua.re = poes_re;

D.amsub.basedir = [data_base_dir 'amsub'];
D.amsub.subdir = '$SAT_amsub_$YEAR4/$MONTH/$DAY';
D.amsub.re = poes_re;

D.amsub_FCDR.basedir = ['/scratch/uni/u237/data/fiduceo-fcdr/easy/v4_1fv2_0_1']; 
D.amsub_FCDR.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.amsub_FCDR.re = '(?<satname>[a-z0-9]{6})/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/FIDUCEO_FCDR_L1C_MHS_(?<satname>[A-Z0-9]{6})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})|_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})\d{6}_\d{14}_EASY_v4.1_fv2.0.1';

D.cloud_cci.basedir = [data_base_dir 'cloud_cci/ESACCI-L2_CLOUD-CLD_PRODUCTS-AVHRRGAC'];
D.cloud_cci.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.cloud_cci.re = '(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})';

D.gras_per_day.basedir = '/storage5/data/gras';
D.gras_per_day.subdir = ''; % subdirs are the actual 'granules'
D.gras_per_day.filename = '$YEAR4-$MONTH-$DAY';
D.gras_per_day.re = '(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})';

D.hirs.basedir = [data_base_dir 'hirs'];
D.hirs.subdir = '$SAT_hirs_$YEAR4/$MONTH/$DAY';
D.hirs.re = poes_re;

D.isccp_dx.basedir = [data_base_dir 'isccp/dx/'];
D.isccp_dx.subdir = '$YEAR4/$MONTH/$DAY';
D.isccp_dx.re = 'ISCCP\.DX\.[0-2]\.(?<satname>.+)\.(?<year>\d{4})\.(?<month>\d{2})\.(?<day>\d{2})\.zip';

D.mirs.basedir = [data_base_dir 'mirs/'];
D.mirs.subdir = '$SAT_$YEAR4/$MONTH/$DAY';
D.mirs.re = '\.D(?<year02>\d{2})(?<doy>\d{3})\.S(?<hour>\d{2})(?<minute>\d{2})\.E';

D.mhs.basedir = [data_base_dir 'mhs'];
D.mhs.subdir = '$SAT_mhs_$YEAR4/$MONTH/$DAY';
D.mhs.re = poes_re;

D.mhs_FCDR.basedir = ['/scratch/uni/u237/data/fiduceo-fcdr/easy/v4_1fv2_0_1']; 
D.mhs_FCDR.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.mhs_FCDR.re = '(?<satname>[a-z0-9]{6})/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/FIDUCEO_FCDR_L1C_MHS_(?<satname>[A-Z0-9]{6})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})|_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})\d{6}_\d{14}_EASY_v4.1_fv2.0.1'; 

% collection 5
D.modis_aqua_L2.basedir = [data_base_dir 'modis/51/MYD06_L2'];
D.modis_aqua_L2.subdir = '$YEAR4/$DOY';
D.modis_aqua_L2.re = 'MYD06_L2\.A(?<year>\d{4})(?<doy>\d{3})\.(?<hour>\d{2})(?<minute>\d{2})\.(?<version>\d{3})';

% collection 6
D.modis_aqua_L2_col6.basedir = [data_base_dir 'modis/6/MYD06_L2'];
D.modis_aqua_L2_col6.subdir = '$YEAR4/$DOY';
D.modis_aqua_L2_col6.re = 'MYD06_L2\.A(?<year>\d{4})(?<doy>\d{3})\.(?<hour>\d{2})(?<minute>\d{2})\.(?<version>\d{3})';

D.modis_L3.basedir = [data_base_dir 'modis/$SAT08_M3'];
D.modis_L3.subdir = '$YEAR4';
D.modis_L3.re = '(?<satname>[A-Z]{3})08_M3.A(?<year>\d{4})(?<doy>\d{3})\.(?<version>\d{3})';

D.mspps.basedir = [data_base_dir 'mspps/'];
D.mspps.subdir = '$SAT_orbital_$YEAR4/$MONTH/$DAY';
D.mspps.re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';

D.patmosx.basedir = [data_base_dir 'patmosx/level2b/'];
D.patmosx.subdir = '$SAT_$YEAR4';
D.patmosx.re = 'patmosx_(?<satname>[a-z0-9]{3})_asc_(?<year>\d{4})_(?<doy>\d{3})_v(?<version>\d{2}).+(?<end>.{7})$';

D.saphir_l1a.basedir = [data_base_dir 'meghatropiques/saphir_l1a'];
D.saphir_l1a.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l1a.re = 'MT1SAPSL1A__(?<version>\d\.\d{2})_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_00\.h5\.gz$';

D.saphir_l1a2.basedir = [data_base_dir 'meghatropiques/saphir_l1a2'];
D.saphir_l1a2.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l1a2.re = 'MT1SAPSL1A2_(?<version>\d\.\d{2})_\d\d\d_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<hour>\d\d)_(?<minute>\d\d)_(?<second>\d\d)_(?<year2>\d{4})_(?<month2>\d\d)_(?<day2>\d\d)_(?<hour2>\d\d)_(?<minute2>\d\d)_(?<second2>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_\d\d\d_\d\d_\d\d_.{3}_\d\d\.h5\.gz$';

D.saphir_l2a.basedir = [data_base_dir 'meghatropiques/saphir_l2a'];
D.saphir_l2a.subdir = '$YEAR4/$MONTH/$DAY';
D.saphir_l2a.re = 'MT1SAPS_(?<version>\d\.\d{2})_\d_\d\d_I_(?<year>\d{4})_(?<month>\d\d)_(?<day>\d\d)_(?<orbitno>\d{5})_(?<orbitno2>\d{5})_00_GP_\d\.\d\d_L2A\.h5';

D.ssmt2.basedir = [data_base_dir 'ssmt_ngdc'];
D.ssmt2.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
D.ssmt2.filename = '$SAT$YEAR4$MONTH$DAY$HOUR$MINUTE.T2.gz';
D.ssmt2.re = '(?<satname>F[0-9]{2})(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})\.T2\.gz';

D.ssmt2_ngdc.basedir = [data_base_dir 'ssmt/ssmt2_ngdc_nc'];
D.ssmt2_ngdc.subdir = '$SAT/$YEAR4';
%D.ssmt2_ngdc.filename = '$SAT$YEAR4$MONTH$DAY$HOUR$MINUTE.T2.gz';
D.ssmt2_ngdc.re = '(?<satname>F[0-9]{2})(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})(?<hour>\d{2})(?<minute>\d{2})\.nc';


D.ssmt2_noaaclass.basedir = [data_base_dir 'ssmt'];
D.ssmt2_noaaclass.subdir = '$SAT_ssmt2_$YEAR4/$MONTH/$DAY';
%D.ssmt2_noaaclass.filename = '$SAT$YEAR4$MONTH$DAY$HOUR$MINUTE.T2.gz';
D.ssmt2_noaaclass.re = '(?<satname>f[0-9]{2})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S[A-Z0-9.]+\.S.[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})';


D.ssmt2_FCDR.basedir = ['/scratch/uni/u237/data/fiduceo-fcdr/easy/v4_1fv2_0_1'];
D.ssmt2_FCDR.subdir = '$SAT/$YEAR4/$MONTH/$DAY';
%D.ssmt2_FCDR.filename = '$SAT$YEAR4$MONTH$DAY$HOUR$MINUTE.T2.gz';
D.ssmt2_FCDR.re = '(?<satname>[a-z0-9]{3})/(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/FIDUCEO_FCDR_L1C_SSMT2_(?<satname>[A-Z0-9]{3})_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})|_(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})\d{6}_\d{14}_EASY';


D.CFSR.basedir = [userdata_base_dir 'gholl/reanalysis_per_day'];
D.CFSR.subdir = '$YEAR4/$MONTH/$DAY';
D.CFSR.filename = 'T_surf.nc';
D.CFSR.re = D.CFSR.filename;

%% Non-collocated home-made

D.dardarsub.basedir = [data_base_dir 'dardar_subsel'];
D.dardarsub.subdir = '$YEAR4/$MONTH/$DAY';
D.dardarsub.re = D.dardar.re;

D.cmoiwp.basedir = sprintf([userdata_base_dir 'gholl/cmoiwp/v%03.1f'], D.cmoiwp.version);
D.cmoiwp.subdir = '$YEAR4/$MONTH/$DAY';
D.cmoiwp.filename = '$SAT_$YEAR4_$MONTH_$DAY_$HOUR_$MINUTE.nc.gz';
D.cmoiwp.re = '(?<satname>[a-z0-9]{6})_(?<year>\d{4})_(?<month>\d{2})_(?<day>\d{2})_(?<hour>\d{2})_(?<minute>\d{2})';

for v = {'v0_0', 'v0_1', 'v0_2', 'v0_3', 'v0_4', 'v0_5', 'v0_6'}
    ds = D.(sprintf('cmoiwp_%s', v{1}));
    ds.basedir = sprintf([userdata_base_dir 'gholl/cmoiwp/%s'], strrep(v{1}, '_', '.'));
    ds.subdir = D.cmoiwp.subdir;
    ds.filename = D.cmoiwp.filename;
    ds.re = D.cmoiwp.re;
end

D.c2dp_mhs.basedir = [userdata_base_dir 'gholl/collocated_datasets/c2dp'];
D.c2dp_mhs.subdir = '$YEAR4/$MONTH/$DAY';
D.c2dp_mhs.filename = 'c2dp_fullday_$SAT.nc.gz';

D.c2dp_amsub.basedir = D.c2dp_mhs.basedir;
D.c2dp_amsub.subdir = D.c2dp_mhs.subdir;
D.c2dp_amsub.filename = D.c2dp_mhs.filename;

D.cdpc_2dcp.basedir = [userdata_base_dir 'gholl/collocated_datasets/cdpc_2dcp'];
D.cdpc_2dcp.subdir = '$YEAR4/$DOY';

%% Level 3 DATASETS (not for collocating)
D.patmosxL3.basedir   = [data_base_dir 'patmosx/level3'];
D.patmosxL3.subdir    = '$YEAR4/$MONTH/';
D.patmosxL3.re        = 'patmosx_aft_mor_.+(?<year>\d{4})';

%% COLLOCATION DATA SETS

% MW datasets

D.collocation_mhs_mhs.basedir   = [userdata_base_dir 'gholl/collocated_datasets/poes/mhs_mhs'];
D.collocation_mhs_mhs.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_mhs.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_amsub_mhs.basedir   = [userdata_base_dir 'gholl/collocated_datasets/poes/amsub_mhs'];
D.collocation_amsub_mhs.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_mhs.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_mhs_amsub.basedir   = [userdata_base_dir 'gholl/collocated_datasets/poes/mhs_amsub'];
D.collocation_mhs_amsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_amsub.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_amsub_amsub.basedir   = [userdata_base_dir 'gholl/collocated_datasets/poes/amsub_amsub'];
D.collocation_amsub_amsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_amsub.filename  = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_mhs_saphir.basedir = [userdata_base_dir 'gholl/collocated_datasets/mhs_saphir'];
D.collocation_mhs_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_mhs_saphir.filename = 'collocations_$SAT.nc.gz';

D.collocation_amsub_saphir.basedir = [userdata_base_dir 'gholl/collocated_datasets/amsub_saphir'];
D.collocation_amsub_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_amsub_saphir.filename = 'collocations_$SAT.nc.gz';

D.collocation_ssmt2_ssmt2.basedir = [userdata_base_dir 'gholl/collocated_datasets/ssmt2_ssmt2'];
D.collocation_ssmt2_ssmt2.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_ssmt2.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_ssmt2_mhs.basedir = [userdata_base_dir 'gholl/collocated_datasets/ssmt2_mhs'];
D.collocation_ssmt2_mhs.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_mhs.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_ssmt2_amsub.basedir = [userdata_base_dir 'gholl/collocated_datasets/ssmt2_amsub'];
D.collocation_ssmt2_amsub.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_ssmt2_amsub.filename = 'collocations_$SAT1_$SAT2.nc.gz';

D.collocation_gras_amsua.basedir = [userdata_base_dir 'gholl/collocated_datasets/gras_amsua'];
D.collocation_gras_amsua.subdir = '$YEAR4/$MONTH/$DAY';
D.collocation_gras_amsua.filename = 'collocations_$SAT.nc.gz';

% CPR as reference

D.CollocatedDataset_avhrrCMSAF_cpr.basedir   = [userdata_base_dir 'seliasson/collocations_avhrrCMSAF_cpr/core'];
D.CollocatedDataset_avhrrCMSAF_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_avhrrCMSAF_cpr.filename  = 'collocations_avhrrCMSAF_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_calipso_cpr.basedir     = [userdata_base_dir 'seliasson/collocations_calipso_cpr/core'];
D.CollocatedDataset_calipso_cpr.subdir      = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_calipso_cpr.filename    = 'collocations_calipso_cpr_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_4_cpr.basedir      = [userdata_base_dir 'seliasson/collocations_cmoiwp_v0_4_cpr/core'];
D.CollocatedDataset_cmoiwp_v0_4_cpr.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_4_cpr.filename     = 'collocations_cmoiwp_v0_4_cpr_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.basedir  = [userdata_base_dir 'seliasson/collocations_cmoiwp_v0_3_cpr/core'];
D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.subdir   = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_3_cpr_cpr.filename  = 'collocations_cmoiwp_v0_3_cpr$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cpr_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_cpr_dardarsub/core'];
D.CollocatedDataset_cpr_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cpr_dardarsub.filename  = 'collocations_cpr_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cpr_modis.basedir   = [userdata_base_dir 'seliasson/collocations_cpr_modis/core'];
D.CollocatedDataset_cpr_modis.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cpr_modis.filename  = 'collocations_cpr_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mhs_cpr.basedir   = [userdata_base_dir 'gholl/collocated_datasets/mhs_cpr'];
D.CollocatedDataset_mhs_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mhs_cpr.filename  = 'collocations_$SAT.nc.gz';

D.CollocatedDataset_amsub_cpr.basedir = [userdata_base_dir 'gholl/collocated_datasets/amsub_cpr'];
D.CollocatedDataset_amsub_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_amsub_cpr.filename  = 'collocations_$SAT.nc.gz';

D.CollocatedDataset_mspps_cpr.basedir   = [userdata_base_dir 'seliasson/collocations_mspps_cpr/core'];
D.CollocatedDataset_mspps_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mspps_cpr.filename  = 'collocations_mspps_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mirs_cpr.basedir   = [userdata_base_dir 'seliasson/collocations_mirs_cpr/core'];
D.CollocatedDataset_mirs_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mirs_cpr.filename  = 'collocations_mirs_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_patmosx_cpr.basedir   = [userdata_base_dir 'seliasson/collocations_patmosx_cpr/core'];
D.CollocatedDataset_patmosx_cpr.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_patmosx_cpr.filename  = 'collocations_patmosx_cpr_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

% DARDAR as reference

D.CollocatedDataset_avhrrCMSAF_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_avhrrCMSAF_dardarsub/core'];
D.CollocatedDataset_avhrrCMSAF_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_avhrrCMSAF_dardarsub.filename  = 'collocations_avhrrCMSAF_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_calipso_dardarsub.basedir     = [userdata_base_dir 'seliasson/collocations_calipso_dardarsub/core'];
D.CollocatedDataset_calipso_dardarsub.subdir      = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_calipso_dardarsub.filename    = 'collocations_calipso_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_6_dardarsub.basedir      = [userdata_base_dir 'seliasson/collocations_cmoiwp_v0_6_dardarsub/core'];
D.CollocatedDataset_cmoiwp_v0_6_dardarsub.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_6_dardarsub.filename     = 'collocations_cmoiwp_v0_6_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cmoiwp_v0_4_dardarsub.basedir      = [userdata_base_dir 'seliasson/collocations_cmoiwp_v0_4_dardarsub/core'];
D.CollocatedDataset_cmoiwp_v0_4_dardarsub.subdir       = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cmoiwp_v0_4_dardarsub.filename     = 'collocations_cmoiwp_v0_4_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_cloud_cci_dardarsub.basedir    = [userdata_base_dir 'seliasson/cloud_cci_dardarsub/core'];
D.CollocatedDataset_cloud_cci_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_cloud_cci_dardarsub.filename   = 'core_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_dardarsub_modis.basedir   = [userdata_base_dir 'seliasson/dardarsub_modis/core'];
D.CollocatedDataset_dardarsub_modis.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_dardarsub_modis.filename  = 'core_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_hirs_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_hirs_dardarsub/core'];
D.CollocatedDataset_hirs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_hirs_dardarsub.filename  = 'collocations_hirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mhs_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_mhs_dardarsub/core'];
D.CollocatedDataset_mhs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mhs_dardarsub.filename  = 'collocations_mhs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mspps_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_mspps_dardarsub/core'];
D.CollocatedDataset_mspps_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mspps_dardarsub.filename  = 'collocations_mspps_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_mirs_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_mirs_dardarsub/core'];
D.CollocatedDataset_mirs_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_mirs_dardarsub.filename  = 'collocations_mirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_patmosx_dardarsub.basedir   = [userdata_base_dir 'seliasson/collocations_patmosx_dardarsub/core'];
D.CollocatedDataset_patmosx_dardarsub.subdir    = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_patmosx_dardarsub.filename  = 'collocations_patmosx_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

% -------------------------------
% Collocated collocated datasets
% -------------------------------

D.CollocatedDataset_dardarsub_modis_cprCloud.basedir    = [userdata_base_dir 'seliasson/dardarsub_modis_cprCloud/core'];
D.CollocatedDataset_dardarsub_modis_cprCloud.subdir     = '$YEAR4/$MONTH/$DAY';
D.CollocatedDataset_dardarsub_modis_cprCloud.filename   = 'core_dardarsub_modis_cprCloud_$YEAR4_$MONTH_$DAY.nc.gz';

D.CollocatedDataset_dardarsub_modis_cprCloudLidar.basedir  = [userdata_base_dir 'seliasson/dardarsub_modis_cprCloudLidar/core'];
D.CollocatedDataset_dardarsub_modis_cprCloudLidar.subdir   = '$YEAR4/$MONTH/$DAY'; 
D.CollocatedDataset_dardarsub_modis_cprCloudLidar.filename = 'core_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.Collocated_cacmah_avhrr.basedir = [userdata_base_dir 'gholl/collocated_datasets/cacmah_avhrr'];
D.Collocated_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.Collocated_cacmah_avhrr.filename = 'cacmah_avhrr_$SAT1_$SAT2.nc.gz';

D.associated_cacmah_avhrr.basedir = [userdata_base_dir 'gholl/collocated_datasets/cacmah_avhrr'];
D.associated_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_cacmah_avhrr.filename = 'cacmah_avhrr_fulldata_$SAT1_$SAT2.nc.gz';

D.collapsed_cacmah_avhrr.basedir = [userdata_base_dir 'gholl/collocated_datasets/cacmah_avhrr'];
D.collapsed_cacmah_avhrr.subdir = '$YEAR4/$MONTH/$DAY';
D.collapsed_cacmah_avhrr.filename = 'cacmah_avhrr_collapsed_$SAT1_$SAT2.nc.gz';

%% Associated datasets
% ----------------------

D.associated_CPR_MHS_AMSU_HIRS.basedir = [userdata_base_dir 'gholl/collocated_datasets/mhs_cpr'];
D.associated_CPR_MHS_AMSU_HIRS.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_CPR_MHS_AMSU_HIRS.filename = 'fulldata_$SAT.nc.gz';

D.associated_CPR_AMSUB_AMSUA_HIRS.basedir = [userdata_base_dir 'gholl/collocated_datasets/amsub_cpr'];
D.associated_CPR_AMSUB_AMSUA_HIRS.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_CPR_AMSUB_AMSUA_HIRS.filename = 'fulldata_$SAT.nc.gz';

D.associated_mhs_mhs.basedir = [userdata_base_dir 'gholl/collocated_datasets/poes/mhs_mhs'];
D.associated_mhs_mhs.subdir = D.collocation_mhs_mhs.subdir;
D.associated_mhs_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_mhs_amsub.basedir = [userdata_base_dir 'gholl/collocated_datasets/poes/mhs_amsub'];
D.associated_mhs_amsub.subdir = D.collocation_mhs_amsub.subdir;
D.associated_mhs_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_amsub_mhs.basedir = [userdata_base_dir 'gholl/collocated_datasets/poes/amsub_mhs'];
D.associated_amsub_mhs.subdir = D.collocation_amsub_mhs.subdir;
D.associated_amsub_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';
D.associated_amsub_amsub.basedir = [userdata_base_dir 'gholl/collocated_datasets/poes/amsub_amsub'];
D.associated_amsub_amsub.subdir = D.collocation_amsub_amsub.subdir;
D.associated_amsub_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_amsub.basedir = D.collocation_ssmt2_amsub.basedir;
D.associated_ssmt2_amsub.subdir = D.collocation_ssmt2_amsub.subdir;
D.associated_ssmt2_amsub.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_mhs.basedir = D.collocation_ssmt2_mhs.basedir;
D.associated_ssmt2_mhs.subdir = D.collocation_ssmt2_mhs.subdir;
D.associated_ssmt2_mhs.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_ssmt2_ssmt2.basedir = D.collocation_ssmt2_ssmt2.basedir;
D.associated_ssmt2_ssmt2.subdir = D.collocation_ssmt2_ssmt2.subdir;
D.associated_ssmt2_ssmt2.filename = 'fulldata_$SAT1_$SAT2.nc.gz';

D.associated_mhs_saphir.basedir = [userdata_base_dir 'gholl/collocated_datasets/mhs_saphir'];
D.associated_mhs_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_mhs_saphir.filename = 'fulldata_$SAT.nc.gz';

D.associated_gras_amsua.basedir = D.collocation_gras_amsua.basedir;
D.associated_gras_amsua.subdir = D.collocation_gras_amsua.subdir;
D.associated_gras_amsua.filename = 'fulldata_$SAT.nc.gz';

D.associated_amsub_saphir.basedir = [userdata_base_dir 'gholl/collocated_datasets/amsub_saphir'];
D.associated_amsub_saphir.subdir = '$YEAR4/$MONTH/$DAY';
D.associated_amsub_saphir.filename = 'fulldata_$SAT.nc.gz';

D.cloud_cci_dardarsub_ice_clouds.basedir   = [userdata_base_dir 'seliasson/cloud_cci_dardarsub/ice_clouds'];
D.cloud_cci_dardarsub_ice_clouds.subdir    = '$YEAR4/$MONTH/$DAY';
D.cloud_cci_dardarsub_ice_clouds.filename  = 'fields_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.cloud_cci_dardarsub_closest_ice_clouds.basedir  = [userdata_base_dir 'seliasson/cloud_cci_dardarsub/closest_ice_clouds'];
D.cloud_cci_dardarsub_closest_ice_clouds.subdir   = '$YEAR4/$MONTH/$DAY';
D.cloud_cci_dardarsub_closest_ice_clouds.filename = 'collapsed_cloud_cci_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.collapsed_associated_CPR_MHS_AMSU_HIRS.basedir = D.associated_CPR_MHS_AMSU_HIRS.basedir;
D.collapsed_associated_CPR_MHS_AMSU_HIRS.subdir = D.associated_CPR_MHS_AMSU_HIRS.subdir;
D.collapsed_associated_CPR_MHS_AMSU_HIRS.filename = 'collapsed_$SAT.nc.gz';

D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.basedir = D.associated_CPR_AMSUB_AMSUA_HIRS.basedir;
D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.subdir = D.associated_CPR_AMSUB_AMSUA_HIRS.subdir;
D.collapsed_associated_CPR_AMSUB_AMSUA_HIRS.filename = D.collapsed_associated_CPR_MHS_AMSU_HIRS.filename;

D.collapsed_gras_amsua.basedir = D.associated_gras_amsua.basedir;
D.collapsed_gras_amsua.subdir = D.associated_gras_amsua.subdir;
D.collapsed_gras_amsua.filename = 'collapsed_$SAT.nc.gz';

D.cpr_dardarsub_IWP.basedir     = [userdata_base_dir 'seliasson/collocations_cpr_dardarsub/cpr_dardarsub_IWP'];
D.cpr_dardarsub_IWP.filename    = 'collocations_cpr_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';
D.cpr_dardarsub_IWP.subdir      = '$YEAR4/$MONTH/$DAY';

D.cpr_dardarsub_cloudTypes.basedir  = strrep(D.cpr_dardarsub_IWP.basedir,'IWP','cloudTypes');
D.cpr_dardarsub_cloudTypes.filename = D.cpr_dardarsub_IWP.filename;
D.cpr_dardarsub_cloudTypes.subdir   = D.cpr_dardarsub_IWP.subdir;

% -  this will be deprecated when 'dardarsub_modis_ice_clouds' is fully run
D.dardarsub_modis_IWP.basedir   = [userdata_base_dir 'seliasson/dardarsub_modis/IWP'];
D.dardarsub_modis_IWP.filename  = 'fields_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_IWP.subdir    = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_collapsedIWP.basedir  = [userdata_base_dir 'seliasson/dardarsub_modis/collapsedIWP'];
D.dardarsub_modis_collapsedIWP.filename = 'collapsed_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_collapsedIWP.subdir   = '$YEAR4/$MONTH/$DAY';
% --

D.dardarsub_modis_ice_clouds.basedir   = [userdata_base_dir 'seliasson/dardarsub_modis/ice_clouds'];
D.dardarsub_modis_ice_clouds.filename  = 'fields_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_ice_clouds.subdir    = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_closest_ice_clouds.basedir  = [userdata_base_dir 'seliasson/dardarsub_modis/closest_ice_clouds'];
D.dardarsub_modis_closest_ice_clouds.filename = 'collapsed_dardarsub_modis_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';
D.dardarsub_modis_closest_ice_clouds.subdir   = '$YEAR4/$MONTH/$DAY';

D.dardarsub_modis_cprCloud.basedir  = [userdata_base_dir 'seliasson/dardarsub_modis_cprCloud/IWP_per_cloudType'];
D.dardarsub_modis_cprCloud.subdir   = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloud.filename = 'fields_dardarsub_modis_cprCloud_$YEAR4_$MONTH_$DAY.nc.gz';

D.dardarsub_modis_cprCloudLidar.basedir = [userdata_base_dir 'seliasson/dardarsub_modis_cprCloudLidar/IWP_per_cloudType-lidar'];
D.dardarsub_modis_cprCloudLidar.subdir  = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloudLidar.filename= 'fields_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.dardarsub_modis_cprCloudLidar_closest.basedir = [userdata_base_dir 'seliasson/dardarsub_modis_cprCloudLidar/closest'];
D.dardarsub_modis_cprCloudLidar_closest.subdir  = '$YEAR4/$MONTH/$DAY';
D.dardarsub_modis_cprCloudLidar_closest.filename= 'closest_dardarsub_modis_cprCloudLidar_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.fields_2C_ice_dardarsub.basedir  = [userdata_base_dir 'seliasson/collocations_cpr_dardarsub/2C-ICE_dardarsub'];
D.fields_2C_ice_dardarsub.filename = 'fields_2C-ICE_dardarsub_$YEAR4_$MONTH_$DAY.nc.gz';
D.fields_2C_ice_dardarsub.subdir   = D.cpr_dardarsub_IWP.subdir;

D.fields_CPR_LWP_added_to_dardar.basedir  = [userdata_base_dir 'seliasson/collocations_cpr_dardarsub/LWP'];
D.fields_CPR_LWP_added_to_dardar.subdir   = '$YEAR4/$MONTH/$DAY';
D.fields_CPR_LWP_added_to_dardar.filename = 'LWP_$YEAR4_$MONTH_$DAY.nc.gz';

D.hirs_dardarsub.basedir    = strrep(D.CollocatedDataset_hirs_dardarsub.basedir,'core',D.hirs_dardarsub.name);
D.hirs_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.hirs_dardarsub.filename   = 'collocations_hirs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

D.mhs_dardarsub.basedir    = strrep(D.CollocatedDataset_mhs_dardarsub.basedir,'core',D.mhs_dardarsub.name);
D.mhs_dardarsub.subdir     = '$YEAR4/$MONTH/$DAY';
D.mhs_dardarsub.filename   = 'collocations_mhs_dardarsub_$SAT_$YEAR4_$MONTH_$DAY.nc.gz';

datasets_config('firstline_data', [data_base_dir 'granules_firstline/firstline_$SAT_$SENSOR.mat']);

datasets_config('blacklist', [userdata_base_dir 'gholl/blacklist_$SAT_$SENSOR.dat']);

end
