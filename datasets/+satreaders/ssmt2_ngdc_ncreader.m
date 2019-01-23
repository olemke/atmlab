

function data_struct=ssmt2_ngdc_ncreader( filename )

% FORMAT
% data_struct=satreaders.ssmt2_ngdc_ncreader( filename )

% IN 	filename 	full path to smt2 netcdf-NGDC file

% OUT 	data_struct	structure with fileds for all entries in the NGDC netcdf file
%			tb: [scnlin x pixel x channel double]

% function based on
%https://atmos.washington.edu/~cjones/public/load_from_netcdf_to_structure.html (acess: 27.03.2018)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get info of NC file
finfo=ncinfo(filename);

% make sure that file is not empty 
assert(~isempty(finfo.Dimensions), ...
    'atmlab:invalid_data', ...
    'File is empty: %s', filename)



% create a cell array of variables to load
variables_to_load = {'ancil_data','channel_quality_flag','cold_counts','counts_to_tb_gain','counts_to_tb_offset','gain_control','lat','lon','tb','Temperature_misc_housekeeping','thermal_reference','warm_counts'};

% loop over the variables
for j=1:numel(variables_to_load)
    % extract the jth variable (type = string)
    var = variables_to_load{j};

    % use dynamic field name to add this to the structure
    data_struct.(var) = ncread(filename,var);

    %%convert from single to double, if that matters to you (it does to me)
    %if isa(data_struct.(var),'single')
    %    data_struct.(var) = double(data_struct.(var));
    %end
end






% need to permute some columns in order to meet the POES format [scnlin x pixel x channel double]


for field = {'lat', 'lon'}
    if isfield(data_struct, field)
        data_struct.(field{1}) = shiftdim(data_struct.(field{1}), 1);
    end
end


for field = {'channel_quality_flag', 'tb'}
    if isfield(data_struct, field)
        data_struct.(field{1}) = permute(data_struct.(field{1}),[3 2 1] );
    end
end

for field = {'cold_counts','warm_counts'}
    if isfield(data_struct, field)
        data_struct.(field{1}) = permute(data_struct.(field{1}),[3 1 2] );
    end
end

for field = {'ancil_data','counts_to_tb_gain','counts_to_tb_offset','gain_control','Temperature_misc_housekeeping'}
    if isfield(data_struct, field)
        data_struct.(field{1}) = permute(data_struct.(field{1}),[2 1] );
    end
end


% Set all Tb values to NaN for which the channel_quality_flag is NONZERO.
data_struct.tb(data_struct.channel_quality_flag~=0)=nan;

% Extract time in seconds of day
time_sec_of_day=data_struct.ancil_data(:,10);
data_struct.time=time_sec_of_day;
data_struct.time = compensate_wraparound(data_struct.time);

% verify data integrity

assert(~isempty(data_struct.time), ...
    'atmlab:invalid_data', ...
    'Time axis empty: %s', filename)

assert(all(diff(data_struct.time)>0), ...
    'atmlab:invalid_data', ...
    'POES time not monotonically increasing: %s', filename);




