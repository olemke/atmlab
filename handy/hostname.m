% HOSTNAME   Returns name of computer
%
% FORMAT   hname = hostname
%        
% OUT   hname   String with computer name.

% 2005-02-15   Created by Patrick Eriksson.


function hname = hostname


[st,hname] = system( 'hostname' );
