% SMRAPI_CALL    Calls API with prepared URL
%
%   The function is general, it requires a valid URL string as input.
%
%   If failure, an error is issued or NaN is returned depending on value of
%   API. robust.
%   
% FORMAT   D = smrapi_call( API, url )
%
% OUT   D     Obtained data.
%  IN   API   Structure with basic API settings.
%       url   URL to use.

% 2017-08-18   Patrick Eriksson


function D = smrapi_call( API, url )
  
for i = 1 : API.retries
  try
    w = webread( url, weboptions('ContentType','json','Timeout',API.timeout) );
  catch ME
    w = NaN;
  end

  if isstruct(w)  
    D = w.Data;  
    return
  end
  
end


if API.robust
  D = NaN;
else
  if isnan(w)
    error( ME.message );
  elseif isempty(w)
    error( 'webread gave an empty result.' );
  else
    error( 'Something went wrong when calling webread.' );
  end
end
