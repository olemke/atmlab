% PYTHON   Runs python
%
% FORMAT   python( folder, cfile )
%        
% IN    folder   The folder where to run python.
%       cfile    The python script to run.

% 2005-06-08   Created by Patrick Eriksson.


function python( folder, cfile )

[s,pwd0] = system( 'pwd' );

system( ['cd ', folder, ';python ', cfile, ';cd ', pwd0 ] );

