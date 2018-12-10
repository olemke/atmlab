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
% OPT   debug Add debug flag when calling API. Default is false.

% 2017-08-18   Patrick Eriksson


function SMR = smrapi_load_l1b( API, SMR, debug )
%
if nargin < 3, debug = false; end


if ~isfield(SMR,'ScanID') | ~isfield(SMR,'FreqMode') 
  error( 'Input SMR must contain fields *ScanID* and *FreqMode*.' );    
end

if debug
  db_string = '/?debug=true';
else
  db_string = [];
end

if strcmp( API.version, 'v5' )
  %
  for i = 1 : length(SMR)  
    url = sprintf( 'http://%s/rest_api/%s/level1/%d/%d/L1b%s', ...
          API.url, API.version, SMR(i).FreqMode, SMR(i).ScanID, db_string );
  
    SMR(i).L1B = smrapi_call( API, url );
  end
    
    
else
  error( 'API version %s is not supported.', API.version );
end