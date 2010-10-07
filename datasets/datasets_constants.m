function value = datasets_constants(c)

% datasets_constants Defines (pseudo)-constants for datasets
%
% This m-file defines values required by functions in the datasets subsystem.
% It differs from datasets_config in the manner that the values here should
% not normally be changed. If called without arguments, returns
% the entire structure containing all properties and values.
%
% FORMAT
%
%   value = datasets_constants(c)
%
% IN
%
%   c   string      the property asked for (optional)
%
% OUT
%
%   v   (any)       the value of property c or the entire struct
%
% $Id$


%% all POES satellites with MHS/AMSUB

A.POES_satellite_names = {'noaa15', 'noaa16', 'noaa17', 'noaa18', 'noaa19', 'metopa'};
A.POES_satellite_numbers = [15 16 17 18 19 29499]; % for metopa, use NORAD number
A.POES_satellites_amsub = {'noaa15', 'noaa16', 'noaa17'};
A.POES_satellites_mhs = {'noaa18', 'noaa19', 'metopa'};

%% define what reading function to use for what sensor

A.read_cpr = @common_read_cpr_2BCWCRO;
A.read_mhs = @common_read_poes_radiometer;
A.read_amsua = @common_read_poes_radiometer;
A.read_amsub = @common_read_poes_radiometer;
A.read_hirs = @common_read_poes_radiometer;
A.read_avhrr = @common_read_avhrr;
A.read_hirscs = @common_read_hirscs;
A.read_collocation_cpr_poes = @common_read_collocation_cpr_poes;

%% define approximate granule durations

% by sensor rather than by satellite, because not all sensors are saved in
% the same chunks; in particular, stored collocations belong to a certain
% satellite (pair), but are stored per day

A.granule_duration_mhs = 6130; % seconds; upper estimate
A.granule_duration_amsua = 6130;
A.granule_duration_amsub = 6130;
A.granule_duration_hirs = 6130;

A.granule_duration_cpr = 5932; % seconds

A.granule_duration_hirscs = 86400; % one granule per da
A.granule_duration_collocation_cpr_poes = 86400;

if exist('c', 'var')
    value = A.(c);
else
    value = A;
end
