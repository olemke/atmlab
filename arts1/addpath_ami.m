% ADDPATH_AMI   Adds required parts of AMI to search path
%
%    The arts subfolder is added to the end of the Matlab search path.
%
% FORMAT   addpath_ami

% 2004-09-07   Created by Patrick Eriksson.


function addpath_ami

atmlab( 'require', {'AMI_PATH'} );
amipath = atmlab( 'AMI_PATH' );
addpath( fullfile( amipath, 'arts' ), '-end' );
