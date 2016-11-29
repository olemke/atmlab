% SMRAPI_L1B_GET    Reads L1B data for specified scan.
%
% FORMAT   [SMR,e] = smrapi_l1b_get(API,freqmode,scanid)
%
% OUT   SMR       Data structure, will contain fields API, ???
%       e         Error message. Returned as [] if all OK.
%  IN   API       Structure wioth basic API settings.
%       freqmode  Frequency mode.
%       scanid    Scan ID number.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_l1b_get(API,freqmode,scanid)

error('Not yet working')

url = sprintf( 'http://%s/rest_api/%s/scan/AC2/%d/%d', ...
               API.webapi_url, API.l1_version, freqmode, scanid );

SMR.API      = API;

[SMR,e]      = smrapi_append( SMR, url );
