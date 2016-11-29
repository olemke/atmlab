% SMRAPI_CALL    Basic data extraction 
%
%   The function extracts the data matching a given URL. The data are
%   returned as fields of *W*, e.g. W.L2 and W.URLS.
%
%   If the URL is invalid or something else goes wrong, *W* is returned as
%   empty and *e* contains the error message.
%
% See also SMRAPI_APPEND
%   
% FORMAT   [W,e] = smrapi_call( API, url )
%
% OUT   W     Read data.
%       e     Error message. Returned as [] if all OK.
%  IN   API   Structure wioth basic API settings.
%       url   A complete API URL.

% 2016-11-29   Patrick Eriksson


function [W,e] = smrapi_call( API, url )


try
 
  w = webread( url, weboptions('ContentType','json','Timeout',API.timeout) );

  if isfield( w, 'Info' )
    fields = fieldnames( w.Info );
    for i = 1 : length(fields)
      W.(fields{i}) = w.Info.(fields{i});
    end
  else
    fields = fieldnames( w );
    for i = 1 : length(fields)
      W.(fields{i}) = w.(fields{i});
    end
  end      
  
  e = [];
  
catch ME
  
  W = [];
  e = ME.message;
    
end
