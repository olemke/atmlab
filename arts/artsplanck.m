% ARTSPLANCK   The ARTS implementation of Planck
%
%    The main purpose of this function is to show how control file
%    templates and the Qtool can be used to control ARTS calculations.
%
%    This function will later be removed.
%
%    The functyion can be tested as:
%       artsplanck(logspace(11,14,1000),200);
%
% FORMAT   iplanck = artsplanck(f,t)
%        
% OUT   iplanck   Calculated intensities [W/(Hz sr m2)]
% IN    f         A vector with frequencies [Hz].
%       t         A temperature [K]. 

% 2002-12-21   Created by Patrick Eriksson.


function iplanck = artsplanck(f,t)


%= Create a temporary folder
%
tmpfolder = create_tmpfolder;


%= Create a name of a control file inside the temporary folder
%
cfile = fullfile( tmpfolder, 'cfile.arts' );


%= Set the fields of Q. Requiered fields depends what variables that are
%= used in the template (see below).
%
Q.T = t;
Q.TMPFOLDER = tmpfolder;


%= Create the control file
%
qtool( cfiletemplate, cfile, Q );


%= Save the frequency vector to the temporary folder
%
xmlStore( fullfile( tmpfolder, 'f.xml' ), f, 'Vector');


%= Execute ARTS and load the result
%
call_fmodel( cfile );
%
iplanck = xmlLoad( fullfile( tmpfolder, 'i.xml' ) );


%= Remove the temporary folder
%
delete_tmpfolder( tmpfolder );


%= Display result
%
loglog(f,iplanck)

return



%------------------------------------------------------------------------------
%
% For this simple case, we don't need a seperate file to give the control 
% file template. The new version of Qtool takes the template as string array,
% exactly to enable the definition of the templates by local functions, as
% the one below.
%

function S = cfiletemplate

S = { ...
'Main{', ...
'output_file_formatSetAscii{}', ...
'IndexSet( stokes_dim ) { 1 }', ...
'ReadXML( vector_1 ) { "$Q.TMPFOLDER$$Q.FILESEP$f.xml" }', ...
'MatrixPlanck( matrix_1, vector_1 ) { $Q.T$ }', ...
'WriteXML( matrix_1 ) { "$Q.TMPFOLDER$$Q.FILESEP$i.xml" }', ...
'}'
};
