% ASG_USE_V2   Modifies Matlab's path to use scenegen2
%
%    The folder scenegen is replaced with scenegen2 in the search path.
%
% FORMAT   asg_use_v2

% 2012-01-01   Created by Patrick Eriksson.

function asg_use_v2
  
folder = fileparts( which( 'asg2q' ) )

rmpath( folder )

addpath( [folder,'2'], '-begin' )