% ARTS1_CFILE   Generates a ARTS1 control file example.
%
%    Creates a control file matching the settings in a Qarts1 structure.
%
%    See *qarts12cfile* for existing choices for *parts*. 
%
% FORMAT   arts1_cfile( Q, parts, cfile )
%        
% IN    Q       Qarts structure.
%       parts   Control file parts to include. See further above.
%       cfile   Name of control file to create.

% 2004-09-15   Created by Patrick Eriksson.


function arts1_cfile( Q, parts, cfile )

tmpfolder   = create_tmpfolder;

S = qarts12cfile( Q, parts, tmpfolder );
tmpcfile = fullfile( tmpfolder, 'cfile.arts' );
qtool( S, tmpcfile, [], 0 );

copyfile( tmpcfile, cfile );

delete_tmpfolder( tmpfolder );
