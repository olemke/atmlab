% SMRAPI_FIND_L2_PERIOD   Find L2 data for a time period
%
%    See *smrapi_time* for valid formats for *start_time* and *end_time*.
%
% FORMAT  SMR = smrapi_find_l2_period(API,SMR,freqmode,start_time,end_time
%                                     [,limit,offset])
%
% OUT   SMR        Extended SMR structure, loaded data are appended.
%  IN   API        Structure with basic API settings.
%       SMR        Original SMR structure.
%       freqmode   Frequency mode number.
%       start_time Return data after this time (inclusive). 
%       end_time   Return data before this time (exclusive). 
% OPT   limit      Number of scans to return. Default is Inf.
% OPT   offset     Skip scans before returning. Default is NaN.

% 2017-08-18  Patrick Eriksson

function SMR = smrapi_find_l2_period(API,SMR,project,freqmode,start_time,end_time,...
                                     varargin)
%
[limit,offset] = optargs( varargin, { Inf, NaN } );

%http://odin.rss.chalmers.se/rest_api/v5/level2/development/meso_vds4/13/ ...
%    scans/?start_time=2012-02-29&end_time=2012-03-01&limit=100

if strcmp( API.version, 'v5' )
  %
  url = sprintf( 'http://%s/rest_api/%s/level2/development/%s/%d/scans', ...
                 API.url, API.version, project, freqmode );
  url = sprintf( '%s/?start_time=%s&end_time=%s', ...
                 url, smrapi_time(start_time), smrapi_time(end_time) );
 
  if ~isinf( limit )
    url = sprintf( '%s/&limit=%d', url, limit );
  end
  if ~isnan( offset )
    url = sprintf( '%s/&offset=%d', url, limit );
  end
  
  L2urls = smrapi_call( API, url );
  
  if  isstruct(L2urls)
    for i = 1 : length(L2urls)
      SMR(end+1).L2Project = project;
      SMR(end).FreqMode    = freqmode;
      SMR(end).ScanID      = L2urls(i).ScanID;
      L2                   = smrapi_call( API, L2urls(i).URLS.URL_level2 );
      SMR(end).L2          = L2.L2;
      SMR(end).L2c         = L2.L2c;
      SMR(end).L2i         = L2.L2i;
    end
  end
    
    
else
  error( 'API version %s is not supported.', API.version );
end


