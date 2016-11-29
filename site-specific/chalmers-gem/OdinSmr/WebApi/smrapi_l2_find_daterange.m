% SMRAPI_L2_GET    Reads L2 data for specified scan.
%
% FORMAT   [SMR,e] = smrapi_l2_get(API,freqmode,scanid)
%
% OUT   SMR       Data structure, will contain fields API, L2, L2i etc.
%       e         Error message. Returned as [] if all OK.
%  IN   API       Structure wioth basic API settings.
%       freqmode  Frequency mode.
%       scanid    Scan ID number.

% 2016-11-29   Patrick Eriksson


function [I,e] = smrapi_l2_find_daterange(API,freqmode,start_time,end_time)

url = sprintf( ['http://%s/rest_api/%s/level2/%s/%d/scans/',...
                '?start_time=%s&end_time=%s'], ...
               API.webapi_url, API.l2_version, API.l2_project, freqmode, ...
               start_time, end_time );

[W,e] = smrapi_call( API, url );

if ~isempty(e) | W.Count == 0
  I = [];
  return
end


for i = 1 : W.Count
  
  I(i).API = API;
  
  fields = fieldnames( W.Scans(i) );
  for j = 1 : length(fields)
    I(i).(fields{j}) = W.Scans(i).(fields{j});
  end
end
