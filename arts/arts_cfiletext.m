% ARTS_CFILETEXT   Runs ARTS with control file as array of string
%
%   The function generates a control file of the input array of strings and
%   calls arts. The control file generated is 
%     workfolder/cfile.arts
%
% FORMAT arts_cfiletext(S,workfolder)
%
% IN   S            The control file text as an array of strings.
%                   The start 'Arts2{' and end '}' shall NOT be included.
%                   These lines are added automatically.
%      workfolder   A folder where the cfile can be stored

% 2014-09-23 Patrick Eriksson

function arts_cfiletext(S,workfolder)
  
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, { 'Arts2{', S{:}, '}' } );
arts( cfile );
