% SMRAPI_APPEND    Appends data to an existing SMR structure
%
%   The function extracts the data matching a given URL field. The data are
%   returned as fields of *SMR*, e.g. SMR.L2 and SMR.URLS. In contrast to
%   *smrapi_call*, the API settings are here assumed to be found as part of
%   *SMR*, e.g. *SMR.API* must exist.
%
%   If the URL is invalid or something else goes wrong, *SMR* is left untouched
%   and *e* contains the error message.
%
%   Multiple SMR are handled.
%
% See also SMRAPI_CALL
%   
% FORMAT   [SMR,e] = smrapi_append( API, SMR, urlfield )
%
% OUT   SMR   Extended data structure.
%       e     Error message. Returned as [] if all OK.
%  IN   API   Structure with basic API settings.
%       SMR   An existing data structure. 
%       url   Name of field containing a valid WebApi URL, e.g. 'URLS.URL_spectra'.

% 2016-11-29   Patrick Eriksson


function [SMR,e] = smrapi_append( API, SMR, urlfield, structname )


% Handling of array SMR
%
if length(SMR) > 1
  TMP = SMR;
  clear SMR
  e   = [];
  n   = length(TMP);
  for i = 1 : n
    if nargin > 3
      [Si,ei] = smrapi_append( API, TMP(i), urlfield, structname );
    else
      [Si,ei] = smrapi_append( API, TMP(i), urlfield );
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



% Reading of a single SMR
try

  % Matlab can always not handle SMR.(urlfield) as urlfield can contain several
  % levels and we need to go down one level at the time
  %
  subfields = textscan( urlfield, '%s', 'Delimiter', '.' );
  url = SMR.(subfields{1}{1});
  for i = 2 : length(subfields{1})
    url = url.(subfields{1}{i});
  end

  w = webread( url, weboptions('ContentType','json','Timeout',API.timeout) );

  if nargin > 3
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
