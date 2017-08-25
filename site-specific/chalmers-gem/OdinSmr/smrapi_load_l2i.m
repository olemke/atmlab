% SMRAPI_LOAD_L2I   Appends L2 data to the SMR structure
%
%   The input SMR must contain fields ScanID, FreqMode and L2Project.
%
%   Data obtained from API are returned as SMR.L2I.
%
% FORMAT   SMR = smrapi_load_l2i( API, SMR )
%
% OUT   SMR      Extended SMR structure
%  IN   API      Structure with basic API settings.
%       SMR      Original SMR structure.

% 2017-08-24   Patrick Eriksson


function SMR = smrapi_load_l2i( API, SMR )


if ~isfield(SMR,'ScanID') | ~isfield(SMR,'FreqMode') | ~isfield(SMR,'L2Project') 
  error( 'Input SMR must contain fields *ScanID*, *FreqMode* and *L2Project*.' );    
end

if strcmp( API.version, 'v5' )
  %
  for i = 1 : length(SMR)  
    url = sprintf( 'http://%s/rest_api/%s/level2/development/%s/%d/%d/L2i/', ...
                   API.url, API.version, SMR(i).L2Project, ...
                   SMR(i).FreqMode, SMR(i).ScanID );
  
    SMR(i).L2I = smrapi_call( API, url );
  end
    
    
else
  error( 'API version %s is not supported.', API.version );
end