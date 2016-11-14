function S = saphir_l2b(file, varargin)


core_fields = {'BrightnessTemperature', 'BrightnessTemperatureFactors', 'LatitudeScan', 'LongitudeScan'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

uth = ncread(file, 'UTH');
lat = ncread(file, 'latitude');
lon = ncread(file, 'longitude');

S.uth = uth;
S.lat = lat;
S.lon = lon;

end
