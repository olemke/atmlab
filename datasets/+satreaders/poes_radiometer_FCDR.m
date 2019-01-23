function data = poes_radiometer_FCDR(file, ~)

% satreaders.poes_radiometer_FCDR Read POES FIDUCEO FCDR data.
%
% This file reads data from a FIDUCEO FCDR file (from at POES radiometer) and rearranges the
% fields to the common format. 
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   data = satreaders.poes_radiometer_FCDR(file)
%
% IN
%
%   file    string  Path to FIDUCEO FCDR file. Must be FULL PATH!
%
% OUT
%
%   data    struct  With fields:
%
%
%                             time_since1970: [scnlin x 1 double] in seconds since 1970-01-01 00:00:00
%                                        lat: [scnlin x pixel double] in degrees
%                                        lon: [scnlin x pixel double] in [-180, 180] degrees
%                           scanline_origl1b: [scnlin x 1 double]
%                scanline_map_to_origl1bfile: [scnlin x 1 double]
%                         Solar_zenith_angle: [scnlin x pixel double]
%                        Solar_azimuth_angle: [scnlin x pixel double]
%                     Satellite_zenith_angle: [scnlin x pixel double]
%                    Satellite_azimuth_angle: [scnlin x pixel double]
%                            SRF_frequencies: [num_freq x channel double]
%                                SRF_weights: [num_freq x channel double]
%                      quality_pixel_bitmask: [scnlin x pixel double]
%                   quality_scanline_bitmask: [scnlin x 1 double]
%     channel_correlation_matrix_independent: [channel x channel double]
%      channel_correlation_matrix_structured: [channel x channel double]
%      	   channel_correlation_matrix_common: [channel x channel double]
%    error_correlation_scale_cross_element_x: [channel x 1 double]
%       error_correlation_scale_cross_line_y: [channel x 1 double]
%                quality_issue_pixel_bitmask: [scnlin x pixel x channel double]
%                                         tb: [scnlin x pixel x channel double]
%                                   u_common: [scnlin x pixel x channel double]
%                               u_structured: [scnlin x pixel x channel double]
%                              u_independent: [scnlin x pixel x channel double]
%                                       time: [scnlin x 1 double] in seconds since 00:00 UT

   
% call function to read MW data

data = read_FIDUCEO_MW_FCDR(file);




% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% verify data integrity

assert(~isempty(data.time), ...
    'atmlab:invalid_data', ...
    'Time axis empty: %s', file)


% The following 3 lines should not be necessary for FCDR. There might be gaps though (missing
% scanlines) that would be even captured erroneously by this line!
% assert(all(diff(data.time)>0), ...
%     'atmlab:invalid_data', ...
%     'POES time not monotonically increasing: %s', file);



% shift dimensions so that it's [row col (channel)]

for field = {'lat', 'lon', 'Solar_zenith_angle', 'Solar_azimuth_angle', 'Satellite_zenith_angle',...
'Satellite_azimuth_angle', 'quality_pixel_bitmask'}
    if isfield(data, field)
        data.(field{1}) = shiftdim(data.(field{1}), 1);
    end
end


% add filename and version

data.path = file;
data.version = '0'; % dunno

% % add epoch
% 
% d = datasets;
% info = d.mhs_FCDR.find_info_from_granule(file);
% data.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), ...
%     str2double(info.day)));
