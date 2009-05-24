% HOMEDIR   Returns users home directory
%
% FORMAT   d = homedir
%        
% OUT   d   String with path of home directory.

% 2009-05-24   Created by Patrick Eriksson.


function d = homedir


[s,d] = system( 'echo $HOME' );

if s
  error( 'System call to establish home directory failed.' );
end

