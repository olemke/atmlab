function varargout = define_datasets(varargin)
% define datasets
%
% This function defines datasets. It has tw modes:
%
% - no inputs and no outputs, just define datasets
% - one input 'check', return logical scalar to say if it has been defined

% $Id$

persistent defined;

if nargin > 0 && strcmp(varargin{1}, 'check')
    varargout{1} = ~isempty(defined);
    return
end

if ~isempty(defined)
    logtext(atmlab('OUT'), 'Datasets were already defined, doing nothing.\n');
    return
end

%% datasets generated elsewhere

SatDataset('name','avhrr_cmsaf_gac',...
    'reader', @common_read_avhrr_cmsaf_gac, ...
    'granule_duration',7200);

SatDataset('name', 'calipso', ...
    'satname', 'calipso', ...
    'reader', @common_read_calipso, ...
    'granule_duration', 5932);

SatDataset('name', 'cpr', ...
    'satname', 'cloudsat', ...
    'reader', @common_read_cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_RVOD', ...
    'satname', 'cloudsat', ...
    'reader', @common_read_cpr, ...
    'granule_duration', 5932);

SatDataset('name', 'CPR_CLDCLASS', ...
    'satname', 'cloudsat', ...
    'reader', @common_read_cpr, ...
    'granule_duration', 5932);


SatDataset('name', 'CPR_1B', ...
    'satname', 'cloudsat', ...
    'reader', @common_read_cpr, ...
    'granule_duration', 5932);

SatDataset('name','dardar',...
    'satname', 'atrain', ...
    'reader', @common_read_dardar, ...
    'granule_duration',5932);

SatDataset('name', 'amsua', ...
    'reader', @common_read_poes_radiometer, ...
    'granule_duration', 6130);

SatDataset('name', 'amsub', ...
    'reader', @common_read_poes_radiometer, ...
    'granule_duration', 6130);

SatDataset('name', 'mhs', ...
    'reader', @common_read_poes_radiometer, ...
    'granule_duration', 6130);

SatDataset('name', 'hirs', ...
    'reader', @common_read_poes_radiometer, ...
    'granule_duration', 6130);

SatDataset('name', 'modis_aqua_L2', ...
    'reader', @common_read_modis, ...
    'granule_duration', 300);

SatDataset('name', 'mspps', ...
    'reader', @common_read_mspps, ...
    'granule_duration', 6130);

SatDataset('name', 'patmosx', ...
    'reader', @common_read_patmosx, ...
    'granule_duration', 86400);

%% datasets generated here (non-collocated)

% dardarsub, work in progress
HomemadeDataset('name', 'dardarsub', ...
                'satname', 'atrain', ...
                'granule_duration', 5932, ...
                'members', struct(...
                    'iwc', struct(...
                        'type', 'float', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'IWC', ...
                            'units', '?')), ...
                    'height', struct(...,
                        'type', 'float', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'Height', ...
                            'units', '?')), ...
                    'ln_iwc_error', struct(...
                        'type', 'float', ...
                        'dims', {{'HEIGHT', 436}}, ...
                        'atts', struct(...
                            'long_name', 'ln of IWC error', ...
                            'units', '?')), ...
                    'time', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'long_name', 'time', ...
                            'units', '?')), ...
                    'lat', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'type', 'float', ...
                            'units', '?')), ...
                    'lon', struct(...
                        'type', 'float', ...
                        'atts', struct(...
                            'type', 'float', ...
                            'units', '?'))));

%% Collocated datasets (the core)

D = datasets;
CollocatedDataset(D.avhrr_cmsaf_gac, D.cpr,...
    'name','CollocatedDataset_avhrrCMSAF_cpr', ...
    'distance', 5, ...
    'interval', 300);

% calipso is a 5km product and must therefore be the primary dataset
CollocatedDataset(D.calipso, D.cpr,...
    'name', 'CollocatedDataset_calipso_cpr', ...
    'distance', 5, ...
    'interval',180);

CollocatedDataset(D.cpr, D.modis_aqua_L2,...
    'name', 'CollocatedDataset_cpr_modis', ...
    'distance', 2, ...
    'interval', 180);

CollocatedDataset(D.cpr, D.dardar,...
    'name', 'CollocatedDataset_cpr_dardar', ...
    'distance', 1, ...
    'interval', 1); % these are always collocated

CollocatedDataset(D.mhs, D.cpr,...
    'name','CollocatedDataset_mhs_cpr',...
    'distance', 15, ...
    'interval', 900);

CollocatedDataset(D.mspps, D.cpr,...
    'name', 'CollocatedDataset_mspps_cpr', ...
    'distance', 20, ...
    'interval', 600);

CollocatedDataset(D.patmosx, D.cpr,...
    'name', 'CollocatedDataset_patmosx_cpr', ...
    'distance', 8, ...
    'interval', 600);

CollocatedDataset(D.mhs, D.mhs, ...
    'name', 'collocation_mhs_mhs', ...
    'distance', 15, ...
    'interval', 900);

%% helpers for AssociatedDataset definitions

longrange = [-180 180];
longunit = 'degrees_east';
latrange = [-90 90];
latunit = 'degrees_north';
timeunit = 'seconds since 1970-01-01 00:00:00';

sza.type = 'float';
sza.realname = 'sza';
sza.atts.long_name = 'Solar zenith angle';
sza.atts.units = 'degrees';
sza.atts.valid_range = [-180 180];

saa.type = 'float';
saa.realname = 'saa';
saa.atts.long_name = 'Solar azimuth angle';
saa.atts.units = 'degrees';
saa.atts.valid_range = [-180 180];

lza.type = 'float';
lza.realname = 'lza';
lza.atts.long_name = 'Local zenith angle';
lza.atts.units = 'degrees';
lza.atts.valid_range = [-180 180];

laa.type = 'float';
laa.realname = 'laa';
laa.atts.long_name = 'Local azimuth angle';
laa.atts.units = 'degrees';
laa.atts.valid_range = [-180 180];

%% AssociatedDatasets (FieldCopier, Collapser, etc.)

%f_mhs.B_LONG.type = 'float';
%f_mhs.B_LONG.realname = 'lon';
%f_mhs.B_LONG.atts.long_name = 'AMSU-B/MHS Longitude';
%f_mhs.B_LONG.atts.units = longunit;
%f_mhs.B_LONG.atts.valid_range = longrange;
%f_mhs.B_LAT.type = 'float';
%f_mhs.B_LAT.realname = 'lat';
%f_mhs.B_LAT.atts.long_name = 'AMSU-B/MHS Latitude';
%f_mhs.B_LAT.atts.units = latunit;
%f_mhs.B_LAT.atts.valid_range = latrange;
%f_mhs.B_TIME.type = 'int';
%f_mhs.B_TIME.realname = 'time';
%f_mhs.B_TIME.atts.long_name = 'AMSU-B/MHS measurement time';
%f_mhs.B_TIME.atts.units = timeunit;
f_mhs.B_LZA = lza;
f_mhs.B_LAA = laa;
f_mhs.B_SZA = sza;
f_mhs.B_SAA = saa;
f_mhs.B_BT.type = 'float';
f_mhs.B_BT.realname = 'tb';
f_mhs.B_BT.dims = {'MHS_CHANS', 5};
f_mhs.B_BT.atts.long_name = 'MHS Brightness Temperature';
f_mhs.B_BT.atts.units = 'Kelvin';

f_amsua.A_LONG.type = 'float';
f_amsua.A_LONG.realname = 'lon';
f_amsua.A_LONG.atts.long_name = 'AMSU-A Longitude';
f_amsua.A_LONG.atts.units = longunit;
f_amsua.A_LONG.atts.valid_range = longrange;
f_amsua.A_LAT.type = 'float';
f_amsua.A_LAT.realname = 'lat';
f_amsua.A_LAT.atts.long_name = 'AMSU-A Latitude';
f_amsua.A_LAT.atts.units = latunit;
f_amsua.A_LAT.atts.valid_range = latrange;
f_amsua.A_TIME.type = 'int';
f_amsua.A_TIME.realname = 'time';
f_amsua.A_TIME.atts.long_name = 'AMSU-A measurement time';
f_amsua.A_TIME.atts.units = timeunit;
f_amsua.A_LZA = lza;
f_amsua.A_LAA = laa;
f_amsua.A_BT.type = 'float';
f_amsua.A_BT.realname = 'tb';
f_amsua.A_BT.dims = {'AMSUA_CHANS', 15};
f_amsua.A_BT.atts.long_name = 'AMSU-A Brightness Temperature';
f_amsua.A_BT.atts.units = 'Kelvin';
f_amsua.A_LINE.type = 'int';
f_amsua.A_LINE.realname = 'scanline_number';
f_amsua.A_LINE.atts.long_name = 'AMSU-A scanline number';
f_amsua.A_POS.type = 'byte';
f_amsua.A_POS.realname = 'scanline_position';
f_amsua.A_POS.atts.long_name = 'AMSU-A scanline position';
% FIXME: f_amsua.A_START
% FIXME: f_amsua.A_I
% FIXME: f_amsua.A_C

f_hirs.H_LONG.type = 'float';
f_hirs.H_LONG.realname = 'lon';
f_hirs.H_LONG.atts.long_name = 'HIRS Longitude';
f_hirs.H_LONG.atts.units = longunit;
f_hirs.H_LONG.atts.valid_range = longrange;
f_hirs.H_LAT.type = 'float';
f_hirs.H_LAT.realname = 'lat';
f_hirs.H_LAT.atts.long_name = 'HIRS Latitude';
f_hirs.H_LAT.atts.units = latunit;
f_hirs.H_LAT.atts.valid_range = latrange;
f_hirs.H_TIME.type = 'int';
f_hirs.H_TIME.realname = 'time';
f_hirs.H_TIME.atts.long_name = 'HIRS measurement time';
f_hirs.H_TIME.atts.units = timeunit;
f_hirs.H_LZA = lza;
f_hirs.H_LAA = laa;
f_hirs.H_BT.type = 'float';
f_hirs.H_BT.realname = 'tb';
f_hirs.H_BT.dims = {'HIRS_CHANS', 20};
f_hirs.H_BT.atts.long_name = 'HIRS Brightness Temperature';
f_hirs.H_BT.atts.units = 'Kelvin';
f_hirs.H_LINE.type = 'int';
f_hirs.H_LINE.realname = 'scanline_number';
f_hirs.H_LINE.atts.long_name = 'HIRS scanline number';
f_hirs.H_POS.type = 'byte';
f_hirs.H_POS.realname = 'scanline_position';
f_hirs.H_POS.atts.long_name = 'HIRS scanline position';
% FIXME: f_hirs.H_START
% FIXME: f_hirs.H_I
% FIXME: f_hirs.H_C

%f_cpr.C_LONG.type = 'double';
%f_cpr.C_LONG.realname = 'lon';
%f_cpr.C_LONG.atts.long_name = 'CloudSat Longitude';
%f_cpr.C_LONG.atts.units = longunit;
%f_cpr.C_LONG.atts.valid_range = longrange;
%f_cpr.C_LAT.type = 'double';
%f_cpr.C_LAT.realname = 'lat';
%f_cpr.C_LAT.atts.long_name = 'CloudSat Latitude';
%f_cpr.C_LAT.atts.units = latunit;
%f_cpr.C_LAT.atts.valid_range = latrange;
%f_cpr.C_TIME.type = 'int';
%f_cpr.C_TIME.realname = 'time';
%f_cpr.C_TIME.atts.long_name = 'CloudSat measurement time';
%f_cpr.C_TIME.atts.units = timeunit;
f_cpr.ROIWP.type = 'float';
f_cpr.ROIWP.realname = 'RO_ice_water_path';
f_cpr.ROIWP.atts.long_name = 'CloudSat Radar-Only CPR IWP';
f_cpr.ROIWP.atts.units = 'g/m^2';
f_cpr.dROIWP.type = 'float';
f_cpr.dROIWP.realname = 'RO_ice_water_path_uncertainty';
f_cpr.dROIWP.atts.long_name = 'CloudSat Radar-Only CPR IWP uncertainty';
f_cpr.dROIWP.atts.units = 'g/m^2';
f_cpr.IOROIWP.type = 'float';
f_cpr.IOROIWP.realname = 'IO_RO_ice_water_path';
f_cpr.IOROIWP.atts.long_name = 'CloudSat Radar-Only Ice-Only CPR IWP';
f_cpr.IOROIWP.atts.units = 'g/m^2';
f_cpr.dIOROIWP.type = 'float';
f_cpr.dIOROIWP.realname = 'IO_RO_ice_water_path_uncertainty';
f_cpr.dIOROIWP.atts.long_name = 'CloudSat Radar-Only Ice-Only CPR IWP uncertainty';
f_cpr.dIOROIWP.atts.units = 'g/m^2';
% FIXME: f_cpr.C_START
% FIXME: f_cpr.C_I
% FIXME: f_cpr.C_C


AssociatedPOESPlusCPR(f_mhs, f_amsua, f_hirs, f_cpr, ...
    'name', 'associated_CPR_MHS_AMSU_HIRS');

d = datasets;
global_lims = {@(X)(X(:, d.CollocatedDataset_mhs_cpr.cols.DIST)<7.5), ...
               @(X)(abs(X(:, d.CollocatedDataset_mhs_cpr.cols.INT))<600)};
appccs.ROIWP.limitators = {@(X)(X>=0)}; % not flagged
appccs.ROIWP.processors.NO = @length;
appccs.ROIWP.stored.NO.type = 'int';
appccs.ROIWP.stored.NO.atts.long_name = 'Number of CloudSat footprints used for statistics inside AMSU-B/MHS';
appccs.ROIWP.processors.MEAN = @mean;
appccs.ROIWP.stored.MEAN.type = 'float';
appccs.ROIWP.stored.MEAN.atts.long_name = ['MHS-averaged ' f_cpr.ROIWP.atts.long_name];
appccs.ROIWP.stored.MEAN.atts.units = f_cpr.ROIWP.atts.units;
appccs.ROIWP.processors.STD = @std;
appccs.ROIWP.stored.STD.type = 'float';
appccs.ROIWP.stored.STD.atts.long_name = ['CPR-in-MHS standard deviation for ' f_cpr.ROIWP.atts.long_name];
appccs.ROIWP.stored.STD.atts.units = f_cpr.ROIWP.atts.units;
appccs.ROIWP.processors.CV = @(X)(std(X) ./ mean(X));
appccs.ROIWP.stored.CV.type = 'int';
appccs.ROIWP.stored.CV.atts.long_name = ['Coefficient of variation of CPR ' f_cpr.ROIWP.atts.long_name];
appccs.ROIWP.processors.FRAC = @(X)(sum(X>0) / length(X));
appccs.ROIWP.stored.FRAC.type = 'float';
appccs.ROIWP.stored.FRAC.atts.long_name = ['Cloud fraction according to ' f_cpr.ROIWP.atts.long_name];


Collapser(d.associated_CPR_MHS_AMSU_HIRS, appccs, global_lims, ...
    'name', 'collapsed_associated_CPR_MHS_AMSU_HIRS');


%%

defined = true;
logtext(atmlab('OUT'), 'Datasets defined. Everything seems fine.\n');

end
