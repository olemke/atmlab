% WHOAMI   Returns user name
%
%    So far only Unix type of computers are handled.
%
% FORMAT   user = whoami
%        
% OUT   user   String with user name.

% 2005-02-15   Created by Patrick Eriksson.


function user = whoami


if isunix

  [st,user] = unix( 'whoami' );

else
  error('Our computer type is not handled.');
end