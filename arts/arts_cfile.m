% ARTS_CFILE   Generates a ARTS control file example.
%
%    Creates a control file matching the settings in a Qarts structure.
%
%    See *qarts2cfile* for existing choices for *parts*. 
%
% FORMAT   arts_cfile( Q, parts, cfile )
%        
% IN    Q       Qarts structure.
%       parts   Control file parts to include. See further above.
%       cfile   Name of control file to create.

% 2004-09-15   Created by Patrick Eriksson.


function arts_cfile( Q, parts, cfile )

tmpfolder   = create_tmpfolder;

S = qarts2cfile( Q, parts, tmpfolder );
tmpcfile = fullfile( tmpfolder, 'cfile.arts' );
qtool( S, tmpcfile, [], 0 );

copyfile( tmpcfile, cfile );

delete_tmpfolder( tmpfolder );

