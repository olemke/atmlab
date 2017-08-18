% SMRAPI_BASIC_SETIINGS
%
%   The API structure holds settings associated with the SMR WebApi, that
%   normally should be static for one session. The fields are
%     webapi_url : The address to the WebApi server.
%        timeout : Timout value for calls of the WebApi [s].
%         robust : False means to issue an error if api call fails. 
%                  If set to true, data are instead set to NaN.
%     l1_version : The string used to identify the L1 version.
%     l2_version : The string used to identify the L2 version.
%     l2_project : The string used to identify the L2 project.
%   
% FORMAT   API = smrapi_basic_settings
%
% OUT   API   Structure holding the settings.

% 2017-08-18   Patrick Eriksson


function API = smrapi_basic_settings


API.webapi_url  = 'malachite.rss.chalmers.se';

API.timeout     = 120;

API.robust      = false;

API.l1_version  = 'v5';

API.l2_version  = 'v5';
API.l2_project  = '';   % Should be set to name of standard inversions

