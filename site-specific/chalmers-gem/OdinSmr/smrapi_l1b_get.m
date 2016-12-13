% SMRAPI_L1B_GET    Reads L1B data for specified scan.
%
%   Use this function of the data extraction starts with L1b. Otherwise try
%   to use *smrapi_append*.
%
% FORMAT   [SMR,e] = smrapi_l1b_get(API,freqmode,scanid)
%
% OUT   SMR       Data structure, will contain fields API and L1b
%       e         Error message. Returned as [] if all OK.
%  IN   API       Structure with basic API settings.
%       freqmode  Frequency mode.
%       scanid    Scan ID number.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_l1b_get(API,freqmode,scanid)


switch freqmode

  case { 2, 13 }
    %
    backend = 'AC1';
  
  case { 1 }
    %
    backend = 'AC2';

  otherwise
    %
    error( 'Don''t know backend for this freqmode (%d).', freqmode );
end

    
url = sprintf( 'http://%s/rest_api/%s/scan/%s/%d/%d', ...
               API.webapi_url, API.l1_version, backend, freqmode, scanid );

SMR.API      = API;

[SMR,e]      = smrapi_append( SMR, url, 'L1b' );


