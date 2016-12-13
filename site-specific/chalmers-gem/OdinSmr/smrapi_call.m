% SMRAPI_CALL    Initial data extraction 
%
%   The function extracts the data matching a given URL. The data are
%   returned as fields of *SMR*, e.g. SMR.L2 and W.URLS. 
%
%   If the URL is invalid or something else goes wrong, *SMR* is returned as
%   empty and *e* contains the error message.
%
%   Multiple URLs are handled.
%
% See also SMRAPI_APPEND
%   
% FORMAT   [W,e] = smrapi_call( API, url )
%
% OUT   W   Read data.
%       e     Error message. Returned as [] if all OK.
%  IN   API   Structure with basic API settings.
%       url   One or several complete API URLs.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_call( API, url, structname )


% Handling of multiple URLs
%
if iscellstr( url )
  e = [];
  n = length(url);
  for i = 1 : n
    if nargin > 2
      [Si,ei] = smrapi_call( API, url{i}, structname );
    else
      [Si,ei] = smrapi_call( API, url{i} );
    end
    if isempty(ei)
      SMR(i) = Si;
    else
      e{i} = ei;
    end
  end
  if ~isempty(e) & length(e) < n
    e{n} = [];
  end
  return;
end


% Reading of a single URL:
%
try

  SMR = [];
  
  w = webread( url, weboptions('ContentType','json','Timeout',API.timeout) );

  if nargin > 2
    if isfield( w, 'Info' )
      for i = 1 : length( w.Info )
        fields = fieldnames( w.Info(i) );
        for j = 1 : length(fields)
          SMR(i).(structname).(fields{j}) = w.Info(i).(fields{j});
        end
      end
    else
      fields = fieldnames( w );
      for i = 1 : length(fields)
        SMR.(structname).(fields{i}) = w.(fields{i});
      end
    end      
  
  else
    if isfield( w, 'Info' )
      for i = 1 : length( w.Info )
        fields = fieldnames( w.Info(i) );
        for j = 1 : length(fields)
          SMR(i).(fields{j}) = w.Info(i).(fields{j});
        end
      end
    else
      fields = fieldnames( w );
      for i = 1 : length(fields)
        SMR.(fields{i}) = w.(fields{i});
      end
    end      
  end
  e = [];
  
catch ME
  
  SMR = [];
  e   = ME.message;
    
end
