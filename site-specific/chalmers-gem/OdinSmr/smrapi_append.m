% SMRAPI_APPEND    Appends data to an existing SMR structure
%
%   The function extracts the data matching a given URL. The data are
%   returned as fields of *SMR*, e.g. SMR.L2 and SMR.URLS. In contrast to
%   *smrapi_call*, the API settings are here assumed to be found as part of
%   *SMR*, e.g. *SMR.API* must exist.
%
%   If the URL is invalid or something else goes wrong, *SMR* is left untouched
%   and *e* contains the error message.
%
% See also SMRAPI_CALL
%   
% FORMAT   [SMR,e] = smrapi_call( SMR, url )
%
% OUT   SMR   Extended data structure.
%       e     Error message. Returned as [] if all OK.
%  IN   SMR   An existing data structure. SMR.API must exist.
%       url   A complete API URL.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_append( SMR, url, structname )


try
 
  w = webread( url, weboptions('ContentType','json','Timeout',SMR.API.timeout) );

  if nargin > 2
    if isfield( w, 'Info' )
      fields = fieldnames( w.Info );
      for i = 1 : length(fields)
        SMR.(structname).(fields{i}) = w.Info.(fields{i});
      end
    else
      fields = fieldnames( w );
      for i = 1 : length(fields)
        SMR.(structname).(fields{i}) = w.(fields{i});
      end
    end      
  
      
  else
    if isfield( w, 'Info' )
      fields = fieldnames( w.Info );
      for i = 1 : length(fields)
        SMR.(fields{i}) = w.Info.(fields{i});
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
  
  e = ME.message;
    
end
