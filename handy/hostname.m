% HOSTNAME   Returns name of computer
%
%    So far only Unix type of computers are handled.
%
% FORMAT   hname = hostname
%        
% OUT   hname   String with computer name.

% 2005-02-15   Created by Patrick Eriksson.


function hname = hostname


if isunix

  [st,hname] = unix( 'hostname' );

else
  error('Our computer type is not handled.');
end