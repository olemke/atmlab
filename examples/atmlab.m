% ATMLAB   Atmlab personal settings.
%
%   This function is a template for personal atmlab.m functions for
%   giving the personal settings.
%
%   This function shall be copied to a place outside Atmlab, to a position
%   where it can be found by Matlab. The personal settings are given inside
%   the local function *atmlab_local_defs*, and this is the only modification
%   of the function that shall be performed (this header can of course be
%   deleted). The version of *atmlab_local_defs* found here is not complete,
%   it just gives some examples. For information on existing setting fields, 
%   execute:
%      type atmlab_defs.m
%
%   This function is based on *prstnt_struct*. See the online help for
%   some info about how this type of functions work. Further instructions
%   are given in CONFIGURE in the Atmlab top folder.

% 2002-12-19   Created by Patyrick Eriksson.
 

function value = atmlab( varargin )
            
persistent A
          
[A,value] = prstnt_struct( A, @atmlab_local_defs, varargin );

return

%---

function A = atmlab_local_defs
  
  A = atmlab_defs;

  A.WORK_AREA = '/tmp';

  A.FMODEL    = 'arts';
  
return
