% READ_FIDUCEO_MW_FCDR  Reads FIDUCEO MW-FCDR NetCDF-file.
%
% This function reads Microwave FCDR level 1c data from FIDUCEO FCDR.
%
% FORMAT   data = read_FIDUCEO_MW_FCDR( filename );
%
% IN    file_name   MW-FCDR filename.
% OUT   data        Data structure. Containing all variables provided inthe
%                   FCDR. See FIDUCEO PUG (not yet released though,
%                   2018-02-14, Imke Hans)

% 2018-02-14   Created by Imke Hans.

function data = read_FIDUCEO_MW_FCDR( filename )

% read in time (it is in sec since 1970-01-01 00:00:00)
% Note: time in seconds scine start of day will be stored in data.time (see at the end)
data.time_since1970=double(ncread(filename,'/Time'));

% read in latitude and longitude and give them lat/lon name to be in line
% with other atmlab functions
 data.lat=double(ncread(filename,'/latitude'));
 data.lon=double(ncread(filename,'/longitude'));
 
 
 %%%% sensor specific %%%%
% read out senors name from attributes
sensor_chosen=ncreadatt(filename,'/','instrument');





if strcmp(sensor_chosen,'mhs')
%% MHS %%%%%%

% make a cell array filled with strings of all variables
finfo=ncinfo(filename);
for ii=1:length(finfo.Variables)
	variables{ii}=finfo.Variables(ii).Name;
end

%variables = {'scanline_origl1b','scanline_map_to_origl1bfile',...
%    'Solar_zenith_angle','Solar_azimuth_angle','Satellite_zenith_angle',...
%    'Satellite_azimuth_angle','SRF_frequencies','SRF_weights','quality_pixel_bitmask',...
%    'quality_scanline_bitmask','channel_correlation_matrix_independent','channel_correlation_matrix_structured','channel_correlation_matrix_common',...
%    'error_correlation_scale_cross_element_x','error_correlation_scale_cross_line_y'};

% looping over variables...
for k=1:numel(variables)
    
    % get the kth variable
    var = variables{k};

    % read from nc-file filename the variable var
    data.(var) = double(ncread(filename,var));

   
end

% Now, we still need to read the brightness temperatures, uncertainties and
% quality-issue-bitmasks that are given channel specific in the FCDR. Here
% we create a [channel pixel scanlines]-matrix out of them.


    qual_ch1=double(ncread(filename,'/quality_issue_pixel_Ch1_bitmask'));
    qual_ch2=double(ncread(filename,'/quality_issue_pixel_Ch2_bitmask'));
    qual_ch3=double(ncread(filename,'/quality_issue_pixel_Ch3_bitmask'));
    qual_ch4=double(ncread(filename,'/quality_issue_pixel_Ch4_bitmask'));
    qual_ch5=double(ncread(filename,'/quality_issue_pixel_Ch5_bitmask'));

    %create matrix for all channels
    qualbit_intermed=[shiftdim(qual_ch1,-1); shiftdim(qual_ch2,-1); shiftdim(qual_ch3,-1); shiftdim(qual_ch4,-1); shiftdim(qual_ch5,-1)];
    data.quality_issue_pixel_bitmask=permute(qualbit_intermed,[3 2 1]);


    tb_ch1=double(ncread(filename,'/Ch1_BT'));
    tb_ch2=double(ncread(filename,'/Ch2_BT'));
    tb_ch3=double(ncread(filename,'/Ch3_BT'));
    tb_ch4=double(ncread(filename,'/Ch4_BT'));
    tb_ch5=double(ncread(filename,'/Ch5_BT'));

    u_common_ch1=double(ncread(filename,'/u_common_Ch1_BT'));
    u_common_ch2=double(ncread(filename,'/u_common_Ch2_BT'));
    u_common_ch3=double(ncread(filename,'/u_common_Ch3_BT'));
    u_common_ch4=double(ncread(filename,'/u_common_Ch4_BT'));
    u_common_ch5=double(ncread(filename,'/u_common_Ch5_BT'));

    u_structured_ch1=double(ncread(filename,'/u_structured_Ch1_BT'));
    u_structured_ch2=double(ncread(filename,'/u_structured_Ch2_BT'));
    u_structured_ch3=double(ncread(filename,'/u_structured_Ch3_BT'));
    u_structured_ch4=double(ncread(filename,'/u_structured_Ch4_BT'));
    u_structured_ch5=double(ncread(filename,'/u_structured_Ch5_BT'));

    u_independent_ch1=double(ncread(filename,'/u_independent_Ch1_BT'));
    u_independent_ch2=double(ncread(filename,'/u_independent_Ch2_BT'));
    u_independent_ch3=double(ncread(filename,'/u_independent_Ch3_BT'));
    u_independent_ch4=double(ncread(filename,'/u_independent_Ch4_BT'));
    u_independent_ch5=double(ncread(filename,'/u_independent_Ch5_BT'));

    %create matrix for all channels
    tb_intermed=[shiftdim(tb_ch1,-1); shiftdim(tb_ch2,-1); shiftdim(tb_ch3,-1); shiftdim(tb_ch4,-1); shiftdim(tb_ch5,-1)];
    u_common_intermed=[shiftdim(u_common_ch1,-1); shiftdim(u_common_ch2,-1); shiftdim(u_common_ch3,-1); shiftdim(u_common_ch4,-1); shiftdim(u_common_ch5,-1)];
    u_structured_intermed=[shiftdim(u_structured_ch1,-1); shiftdim(u_structured_ch2,-1); shiftdim(u_structured_ch3,-1); shiftdim(u_structured_ch4,-1); shiftdim(u_structured_ch5,-1)];
    u_independent_intermed=[shiftdim(u_independent_ch1,-1); shiftdim(u_independent_ch2,-1); shiftdim(u_independent_ch3,-1); shiftdim(u_independent_ch4,-1); shiftdim(u_independent_ch5,-1)];

    data.tb=tb_intermed;
    data.u_common=u_common_intermed;
    data.u_structured=u_structured_intermed;
    data.u_independent=u_independent_intermed;

    % reshape to [scanline pixel channel]
    data.tb=permute(data.tb,[3 2 1]);
    data.u_common=permute(data.u_common,[3 2 1]);
    data.u_structured=permute(data.u_structured,[3 2 1]);
    data.u_independent=permute(data.u_independent,[3 2 1]);



%%  AMSUB %%%%%%
elseif strcmp(sensor_chosen,'amsub')
	
% make a cell array filled with strings of all variables
finfo=ncinfo(filename);
for ii=1:length(finfo.Variables)
	variables{ii}=finfo.Variables(ii).Name;
end
%variables = {'scanline_origl1b','scanline_map_to_origl1bfile',...
%    'Solar_zenith_angle','Solar_azimuth_angle','Satellite_zenith_angle',...
%    'Satellite_azimuth_angle','SRF_frequencies','SRF_weights','quality_pixel_bitmask',...
%    'quality_scanline_bitmask','channel_correlation_matrix_independent','channel_correlation_matrix_structured','channel_correlation_matrix_common',...
%    'error_correlation_scale_cross_element_x','error_correlation_scale_cross_line_y'};

% looping over variables...
for k=1:numel(variables)
    
    % get the kth variable
    var = variables{k};

    % read from nc-file filename the variable var
    data.(var) = double(ncread(filename,var));

   
end

% Now, we still need to read the brightness temperatures, uncertainties and
% quality-issue-bitmasks that are given channel specific in the FCDR. Here
% we create a [channel pixel scanlines]-matrix out of them.
	
	
    qual_ch1=double(ncread(filename,'/quality_issue_pixel_Ch16_bitmask'));
    qual_ch2=double(ncread(filename,'/quality_issue_pixel_Ch17_bitmask'));
    qual_ch3=double(ncread(filename,'/quality_issue_pixel_Ch18_bitmask'));
    qual_ch4=double(ncread(filename,'/quality_issue_pixel_Ch19_bitmask'));
    qual_ch5=double(ncread(filename,'/quality_issue_pixel_Ch20_bitmask'));

    %create matrix for all channels
    qualbit_intermed=[shiftdim(qual_ch1,-1); shiftdim(qual_ch2,-1); shiftdim(qual_ch3,-1); shiftdim(qual_ch4,-1); shiftdim(qual_ch5,-1)];
    data.quality_issue_pixel_bitmask=permute(qualbit_intermed,[3 2 1]);


    tb_ch1=double(ncread(filename,'/Ch16_BT'));
    tb_ch2=double(ncread(filename,'/Ch17_BT'));
    tb_ch3=double(ncread(filename,'/Ch18_BT'));
    tb_ch4=double(ncread(filename,'/Ch19_BT'));
    tb_ch5=double(ncread(filename,'/Ch20_BT'));

    u_common_ch1=double(ncread(filename,'/u_common_Ch16_BT'));
    u_common_ch2=double(ncread(filename,'/u_common_Ch17_BT'));
    u_common_ch3=double(ncread(filename,'/u_common_Ch18_BT'));
    u_common_ch4=double(ncread(filename,'/u_common_Ch19_BT'));
    u_common_ch5=double(ncread(filename,'/u_common_Ch20_BT'));

    u_structured_ch1=double(ncread(filename,'/u_structured_Ch16_BT'));
    u_structured_ch2=double(ncread(filename,'/u_structured_Ch17_BT'));
    u_structured_ch3=double(ncread(filename,'/u_structured_Ch18_BT'));
    u_structured_ch4=double(ncread(filename,'/u_structured_Ch19_BT'));
    u_structured_ch5=double(ncread(filename,'/u_structured_Ch20_BT'));

    u_independent_ch1=double(ncread(filename,'/u_independent_Ch16_BT'));
    u_independent_ch2=double(ncread(filename,'/u_independent_Ch17_BT'));
    u_independent_ch3=double(ncread(filename,'/u_independent_Ch18_BT'));
    u_independent_ch4=double(ncread(filename,'/u_independent_Ch19_BT'));
    u_independent_ch5=double(ncread(filename,'/u_independent_Ch20_BT'));

    %create matrix for all channels
    tb_intermed=[shiftdim(tb_ch1,-1); shiftdim(tb_ch2,-1); shiftdim(tb_ch3,-1); shiftdim(tb_ch4,-1); shiftdim(tb_ch5,-1)];
    u_common_intermed=[shiftdim(u_common_ch1,-1); shiftdim(u_common_ch2,-1); shiftdim(u_common_ch3,-1); shiftdim(u_common_ch4,-1); shiftdim(u_common_ch5,-1)];
    u_structured_intermed=[shiftdim(u_structured_ch1,-1); shiftdim(u_structured_ch2,-1); shiftdim(u_structured_ch3,-1); shiftdim(u_structured_ch4,-1); shiftdim(u_structured_ch5,-1)];
    u_independent_intermed=[shiftdim(u_independent_ch1,-1); shiftdim(u_independent_ch2,-1); shiftdim(u_independent_ch3,-1); shiftdim(u_independent_ch4,-1); shiftdim(u_independent_ch5,-1)];

    data.tb=tb_intermed;
    data.u_common=u_common_intermed;
    data.u_structured=u_structured_intermed;
    data.u_independent=u_independent_intermed;

    % reshape to [scanline pixel channel]
    data.tb=permute(data.tb,[3 2 1]);
    data.u_common=permute(data.u_common,[3 2 1]);
    data.u_structured=permute(data.u_structured,[3 2 1]);
    data.u_independent=permute(data.u_independent,[3 2 1]);


%%  SSMT-2 %%%%%%
elseif strcmp(sensor_chosen,'ssmt2')
	
% make a cell array filled with strings of all variables
finfo=ncinfo(filename);
for ii=1:length(finfo.Variables)
	variables{ii}=finfo.Variables(ii).Name;
end
%variables = {'scanline_origl1b','scanline_map_to_origl1bfile',...
%    'SRF_frequencies','SRF_weights','quality_pixel_bitmask',...
%    'quality_scanline_bitmask','channel_correlation_matrix_independent','channel_correlation_matrix_structured','channel_correlation_matrix_common',...
%    'error_correlation_scale_cross_element_x','error_correlation_scale_cross_line_y'};

% looping over variables...
for k=1:numel(variables)
    
    % get the kth variable
    var = variables{k};

    % read from nc-file filename the variable var
    data.(var) = double(ncread(filename,var));

   
end

% Now, we still need to read the brightness temperatures, uncertainties and
% quality-issue-bitmasks that are given channel specific in the FCDR. Here
% we create a [channel pixel scanlines]-matrix out of them.
    
    qual_ch1=double(ncread(filename,'/quality_issue_pixel_Ch4_bitmask'));
    qual_ch2=double(ncread(filename,'/quality_issue_pixel_Ch5_bitmask'));
    qual_ch3=double(ncread(filename,'/quality_issue_pixel_Ch2_bitmask'));
    qual_ch4=double(ncread(filename,'/quality_issue_pixel_Ch1_bitmask'));
    qual_ch5=double(ncread(filename,'/quality_issue_pixel_Ch3_bitmask'));

    %create matrix for all channels
    qualbit_intermed=[shiftdim(qual_ch1,-1); shiftdim(qual_ch2,-1); shiftdim(qual_ch3,-1); shiftdim(qual_ch4,-1); shiftdim(qual_ch5,-1)];
    data.quality_issue_pixel_bitmask=permute(qualbit_intermed,[3 2 1]);


    tb_ch1=double(ncread(filename,'/Ch4_BT'));
    tb_ch2=double(ncread(filename,'/Ch5_BT'));
    tb_ch3=double(ncread(filename,'/Ch2_BT'));
    tb_ch4=double(ncread(filename,'/Ch1_BT'));
    tb_ch5=double(ncread(filename,'/Ch3_BT'));

    u_common_ch1=double(ncread(filename,'/u_common_Ch4_BT'));
    u_common_ch2=double(ncread(filename,'/u_common_Ch5_BT'));
    u_common_ch3=double(ncread(filename,'/u_common_Ch2_BT'));
    u_common_ch4=double(ncread(filename,'/u_common_Ch1_BT'));
    u_common_ch5=double(ncread(filename,'/u_common_Ch3_BT'));

    u_structured_ch1=double(ncread(filename,'/u_structured_Ch4_BT'));
    u_structured_ch2=double(ncread(filename,'/u_structured_Ch5_BT'));
    u_structured_ch3=double(ncread(filename,'/u_structured_Ch2_BT'));
    u_structured_ch4=double(ncread(filename,'/u_structured_Ch1_BT'));
    u_structured_ch5=double(ncread(filename,'/u_structured_Ch3_BT'));

    u_independent_ch1=double(ncread(filename,'/u_independent_Ch4_BT'));
    u_independent_ch2=double(ncread(filename,'/u_independent_Ch5_BT'));
    u_independent_ch3=double(ncread(filename,'/u_independent_Ch2_BT'));
    u_independent_ch4=double(ncread(filename,'/u_independent_Ch1_BT'));
    u_independent_ch5=double(ncread(filename,'/u_independent_Ch3_BT'));

    %create matrix for all channels
    tb_intermed=[shiftdim(tb_ch1,-1); shiftdim(tb_ch2,-1); shiftdim(tb_ch3,-1); shiftdim(tb_ch4,-1); shiftdim(tb_ch5,-1)];
    u_common_intermed=[shiftdim(u_common_ch1,-1); shiftdim(u_common_ch2,-1); shiftdim(u_common_ch3,-1); shiftdim(u_common_ch4,-1); shiftdim(u_common_ch5,-1)];
    u_structured_intermed=[shiftdim(u_structured_ch1,-1); shiftdim(u_structured_ch2,-1); shiftdim(u_structured_ch3,-1); shiftdim(u_structured_ch4,-1); shiftdim(u_structured_ch5,-1)];
    u_independent_intermed=[shiftdim(u_independent_ch1,-1); shiftdim(u_independent_ch2,-1); shiftdim(u_independent_ch3,-1); shiftdim(u_independent_ch4,-1); shiftdim(u_independent_ch5,-1)];

    data.tb=tb_intermed;
    data.u_common=u_common_intermed;
    data.u_structured=u_structured_intermed;
    data.u_independent=u_independent_intermed;

    % reshape to [scanline pixel channel]
    data.tb=permute(data.tb,[3 2 1]);
    data.u_common=permute(data.u_common,[3 2 1]);
    data.u_structured=permute(data.u_structured,[3 2 1]);
    data.u_independent=permute(data.u_independent,[3 2 1]);

%% else case
else
    disp('read_FIDUCEO_MW_FCDR: Invalid choice of sensor.')

end

%%  Conversions %%%%%%%%%%%%%

% convert matlab-time to seconds since start of day (UTC) to get data.time
% as needed by other functions
matlabtime=unix2matlab(data.time_since1970);
vectordate=datevec(matlabtime);
data.time=vectordate(:,6)+vectordate(:,5)*60+vectordate(:,4)*60*60;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert seconds since 1970-01-01 00:00:00 to matlab serial time
function tm = unix2matlab(tu)
    UnixOrigin=datenum('19700101 000000','yyyymmdd HHMMSS');
    tm = UnixOrigin + tu / 86400;
end 
end
