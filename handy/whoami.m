% WHOAMI   Returns user name
%
% FORMAT   user = whoami
%        
% OUT   user   String with user name.

% 2005-02-15   Created by Patrick Eriksson.


function user = whoami


[st,user] = system( 'whoami' );


%= Remove domain name that can be included on Windows machines
%
if ispc
  i = find( user = '\' )
  if ~isempty(i)
    user = user((i+1):end);
  end
end