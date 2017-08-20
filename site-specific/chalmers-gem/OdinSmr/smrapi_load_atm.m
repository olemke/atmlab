% SMRAPI_LOAD_ATM   Appends L1b atmospheric/apriori data to the SMR structure
%
%   The input SMR must contain fields ScanID and FreqMode.
%
%   Data obtained from API are returned as SMR.ATM.xxx
%
%   The function hanldes both species and the PTZ part. Species must be
%   selected with their exact names, e.g. ClO. Both upper and lower case is
%   acceptyed for PTZ, but the output field is always set to be SMR.ATM.PTZ.
%
%   The argument *dataname* can either be a string or a cellstr, e.g.:
%     'O3', {'ptz',O3}.
%
% FORMAT   SMR = smrapi_load_atm( API, SMR, dataname )
%
% OUT   SMR      Extended SMR structure
%  IN   API      Structure with basic API settings.
%       SMR      Original SMR structure.
%       dataname Name of data to load, see above.

% 2017-08-18   Patrick Eriksson


function SMR = smrapi_load_atm( API, SMR, dataname )


% Handle multiple quantities by recursive calls: 
if iscellstr( dataname )
  for i = 1 : length(dataname)
    SMR = smrapi_load_atm( API, SMR, dataname{i} );
  end
  return
end


if ~isfield(SMR,'ScanID') | ~isfield(SMR,'FreqMode') 
  error( 'Input SMR must contain fields *ScanID* and *FreqMode*.' );    
end
if ~ischar( dataname )
  error( 'Valid formats of *dataname* are char and cellstr.' );
end
    
    
if strcmp( API.l1_version, 'v5' )
  %
  for i = 1 : length(SMR)
    if strcmp( dataname, 'PTZ' )  |  strcmp( dataname, 'ptz' )
      url = sprintf( 'http://%s/rest_api/%s/level1/%d/%d/ptz/', ...
                     API.webapi_url, API.l1_version, SMR(i).FreqMode, ...
                     SMR(i).ScanID );
      datanae = 'PTZ';
    else
      url = sprintf( 'http://%s/rest_api/%s/level1/%d/%d/apriori/%s', ...
                     API.webapi_url, API.l1_version, SMR(i).FreqMode, ...
                     SMR(i).ScanID, dataname );
    end
  end
    
  D = smrapi_call( API, url );
  SMR(i).ATM.(dataname) = D;
  
else
  error( 'L1 version %s is not supported.', API.l1_version );
end