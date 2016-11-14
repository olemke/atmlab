function S = atms(file, varargin)

% read saphir data in the common format
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FIXME DOC
%
% See also: SatDataset/reader

core_fields = {'BrightnessTemperature', 'BrightnessTemperatureFactors', 'LatitudeScan', 'LongitudeScan'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

filen = file;
try
    info=h5info(file);
catch ME
    switch ME.identifier
        case {'MATLAB:imagesci:deprecatedHDF5:libraryError', ...
                'MATLAB:imagesci:h5info:fileOpenErr'} % probably compressed
            file = uncompress(file, atmlab('WORK_AREA'), ...
                struct('unidentified', 'error'));
            % if we reach here, it means filename uncompressed is not the
            % original filename!
            cleanupObj = onCleanup(@()delete(file));
            hinfo = h5info(file);
        otherwise
            ME.rethrow();
    end
end
% Check where is the real file
tf = strcmp(filen, file);
if tf == 0
    file = filen;
end


% Get information about the file.
f = h5read( hinfo.Filename, '/All_Data/ATMS-SDR_All/BrightnessTemperature/' );
fac = h5read( hinfo.Filename, '/All_Data/ATMS-SDR_All/BrightnessTemperatureFactors/' );
f_cor = double(f)*fac(1);

% Lat, lon

lat  = h5read( hinfo.Filename, '/All_Data/ATMS-SDR-GEO_All/Latitude/');
lon  = h5read( hinfo.Filename, '/All_Data/ATMS-SDR-GEO_All/Longitude/');
time = h5read( hinfo.Filename, '/All_Data/ATMS-SDR-GEO_All/MidTime/');

% Start time
time    = double(time/1e6);
t_conv2 = zeros( length(time),6);
sec     = zeros( length(time),1);

for idx=1:length(time)
    dnum2 = datenum( 1958,1,1,0,0,time(idx) );
    [t_conv2(idx,1), t_conv2(idx,2), t_conv2(idx,3), t_conv2(idx,4), t_conv2(idx,5), t_conv2(idx,6)] = datevec(dnum2);
    sec(idx,1) = hms2sec( t_conv2(idx,4), t_conv2(idx,5), t_conv2(idx,6) );
end

S.tb       = permute(f_cor, [3,2,1]);
S.lat      = lat';
S.lon      = lon';
S.time     = sec;
S.fullt    = t_conv2;
S.filename = file;

%wrong_way = {'TbCh1', 'TbCh2', 'TbCh3', 'TbCh4', 'TbCh5', 'TbCh6', 'IncidencAngle'};
%% copy over extra fields
%for i = 1:length(extra_fields)
%    S.(extra_fields{i}) = data.data.(extra_fields{i});
%    if any(strcmp(extra_fields{i}, wrong_way))
%        S.(extra_fields{i}) = S.(extra_fields{i}).';
%    end
%        
%end

end
