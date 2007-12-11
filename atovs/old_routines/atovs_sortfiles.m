% function atovs_sortfiles
% purpose:
% sorts after the starting time
% this is to avoid to be thrown away some files when the data for
% the time ovelap is extracted
%
% Input: years, month, days, t_start hour,  t_start minutes
% Ouput: I_time= index for the sorted files;
%
% format: I_time = atovs_sortfiles(years, month, days, t_start_h,  t_start_m)
%
% Created by Carmen Verdes. 22.10.2004

function  I_time = atovs_sortfiles(years, month, days, t_start_h,  t_start_m)
time_sort = datenum(years, month, days, t_start_h,  t_start_m, 0);
[time_sort, I_time] =sort(time_sort);