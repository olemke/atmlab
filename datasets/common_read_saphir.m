function S = common_read_saphir(file, varargin)

% read saphir data in the common format
%
% FIXME DOC
%
% See also: SatDataset/reader

core_fields = {'ScanTimestart', 'LatScan', 'LonScan'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

data = read_saphir_l1(file, all_fields);

% need to rotate lat and lon
S.lat = data.data.LatScan.';
S.lon = data.data.LonScan.';

% lon is in [0 360], convert to [-180, 180]
S.lon = convert_360_180(S.lon);

% interpret time strings
tmsm = cell2mat(data.data.ScanTimestart);
tt = textscan(tmsm(:, 1:21).', '%4d%2d%2d %2d%2d%2d%6d');
dv = double(horzcat(tt{:})); % need to convert to double for date2unixsecs

S.epoch = round(date2unixsecs(dv(1, 1), dv(1, 2), dv(1, 3), ...
            dv(1, 4), dv(1, 5), dv(1, 6)));
S.time = date2unixsecs(dv(:, 1), dv(:, 2), dv(:, 3), ...
            dv(:, 4), dv(:, 5), dv(:, 6)) - S.epoch;

% copy over extra fields
for i = 1:length(extra_fields)
    S.(extra_fields{i}) = data.(extra_fields{i});
end

end
