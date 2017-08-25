% SMRAPI_FIND_LOG_PERIOD   Find LOG data for a time period
%
%    See *apihelp_time* for valid formats for *start_time* and *end_time*.
%
%    Valid formats for *species* is string and cellstring, e.g. 'O3* and
%    {'O3','ClO'}. Set species = 'all';, to include all species defined.
%
% FORMAT  SMR = smrapi_find_log_period(API,SMR,freqmode,start_time,end_time[,species])
%
% OUT   SMR        Extended SMR structure, loaded data are appended.
%  IN   API        Structure with basic API settings.
%       SMR        Original SMR structure.
%       freqmode   Frequency mode number.
%       start_time Return data after this time (inclusive). 
%       end_time   Return data before this time (exclusive). 
% OPT   species    Include apriori URL for these species. See above. Defualt is [].

% 2017-08-18  Patrick Eriksson

function SMR = smrapi_find_log_period(API,SMR,freqmode,start_time,end_time,varargin)
%
[species] = optargs( varargin, { [] } );


if strcmp( API.version, 'v5' )
  %
  url = sprintf( 'http://%s/rest_api/%s/level1/%d/scans/?start_time=%s&end_time=%s', ...
                 API.url, API.version, freqmode, ...
                 apihelp_time(start_time), apihelp_time(end_time) );
  
  if ~isempty( species )
    if ischar( species )
      url = sprintf( '%s&apriori=%s', url, species );
    elseif iscellstr( species )
      for i = 1 : length(species)
        url = sprintf( '%s&apriori=%s', url, species{i} );
      end
    else
      error( 'Valid formats for *species* is string and cellstr.' );
    end
  end
  
  LOG = smrapi_call( API, url );
  
  if  isstruct(LOG)
    for i = 1 : length(LOG)
      SMR(end+1).FreqMode = freqmode;
      SMR(end).ScanID     = LOG(i).ScanID;
      SMR(end).LOG        = LOG(i);
    end
  end
    
    
else
  error( 'API version %s is not supported.', API.version );
end


