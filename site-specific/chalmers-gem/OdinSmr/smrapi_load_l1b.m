% SMRAPI_LOAD_L1B   Appends L1b data to the SMR structure
%
%   The input SMR must contain fields ScanID and FreqMode.
%
%   Data obtained from API are returned as SMR.L1B.
%
% FORMAT   SMR = smrapi_load_l1b( API, SMR )
%
% OUT   SMR   Extended SMR structure
%  IN   API   Structure with basic API settings.
%       SMR   Original SMR structure.

% 2017-08-18   Patrick Eriksson


function SMR = smrapi_load_l1b( API, SMR )


if ~isfield(SMR,'ScanID') | ~isfield(SMR,'FreqMode') 
  error( 'Input SMR must contain fields *ScanID* and *FreqMode*.' );    
end


if strcmp( API.version, 'v5' )
  %
  for i = 1 : length(SMR)  
    url = sprintf( 'http://%s/rest_api/%s/level1/%d/%d/L1b/', ...
                   API.url, API.version, SMR(i).FreqMode, SMR(i).ScanID );
  
    SMR(i).L1B = smrapi_call( API, url );
  end
    
    
else
  error( 'API version %s is not supported.', API.version );
end