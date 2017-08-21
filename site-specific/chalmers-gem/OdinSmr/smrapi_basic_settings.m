% SMRAPI_BASIC_SETIINGS
%
%   The API structure holds settings associated with the SMR WebApi, that
%   normally should be static for one session. The fields are
%            url : The address to the WebApi server.
%        version : The API version.
%        timeout : Timout value for calls of the WebApi [s].
%         robust : False means to issue an error if api call fails. 
%                  If set to true, data are instead set to NaN (and no error
%                  is issued).
%   
% FORMAT   API = smrapi_basic_settings
%
% OUT   API   Structure holding the settings.

% 2017-08-18   Patrick Eriksson


function API = smrapi_basic_settings


API.url     = 'malachite.rss.chalmers.se';

API.version = 'v5';

API.timeout = 120;

API.robust  = false;



