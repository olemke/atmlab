% SMRAPI_L2_FIND_TIMERANGE   Finds L2 data for a time period
%
%   Use this function of the data extraction starts with ScanInfo. Otherwise
%   try to use *smrapi_append*.

% FORMAT   [SMR,e] = smrapi_l2_find_timerange(API,freqmode,start_time,end_time)
%
% OUT   SMR         Data structure, will contain fields API and ScanInfo.
%       e           Error message. Returned as [] if all OK.
%  IN   API         Structure with basic API settings.
%       freqmode    Frequency mode.
%       start_time  See *smrapi_time* for valid formats.
%       end_time    See *smrapi_time* for valid formats.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_l2_find_timerange(API,freqmode,start_time,end_time)



url = sprintf( ['http://%s/rest_api/%s/level2/%s/%d/scans/',...
                '?start_time=%s&end_time=%s'], ...
               API.webapi_url, API.l2_version, API.l2_project, freqmode, ...
               smrapi_time(start_time), smrapi_time(end_time) );

[W,e] = smrapi_call( API, url );

if ~isempty(e) | W.Count == 0
  SMR = [];
  return
end


for i = 1 : W.Count
  
  SMR(i).API = API;
  
  fields = fieldnames( W.Scans(i) );
  for j = 1 : length(fields)
    SMR(i).ScanInfo.(fields{j}) = W.Scans(i).(fields{j});
  end
end
