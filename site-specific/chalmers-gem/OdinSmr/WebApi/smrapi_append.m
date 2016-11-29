% SMRAPI_APPEND    Appends data to an existing data structure
%
%   The function extracts the data matching a given URL. The data are
%   returned as fields of *W*, e.g. W.L2 and W.URLS. In contrast to
%   *smrapi_call*, the API settings are here assumed to be found as part of
%   *W*, e.g. *W.API* must exist.
%
%   If the URL is invalid or something else goes wrong, *W* is left untouched
%   and *e* contains the error message.
%
% See also SMRAPI_CALL
%   
% FORMAT   [W,e] = smrapi_call( W, url )
%
% OUT   W     Read data.
%       e     Error message. Returned as [] if all OK.
%  IN   W     An existing data structure. W.API must exist.
%       url   A complete API URL.

% 2016-11-29   Patrick Eriksson


function [W,e] = smrapi_append( W, url )


try
 
  w = webread( url, weboptions('ContentType','json','Timeout',W.API.timeout) );

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
  
  e = ME.message;
    
end
