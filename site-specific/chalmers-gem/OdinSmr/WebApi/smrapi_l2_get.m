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


function [SMR,e] = smrapi_l2_get(API,freqmode,scanid)


url = sprintf( 'http://%s/rest_api/%s/level2/%s/%d/%d', ...
               API.webapi_url, API.l2_version, API.l2_project, freqmode, scanid );

SMR.API = API;

[SMR,e] = smrapi_append( SMR, url );
