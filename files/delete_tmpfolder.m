% DELETE_TMPFOLDER   Removes folders in the work area.
%
%    The function removes a folder in the folder set as work area in
%    *atmlab*. See CONFIGURE for information about *atmlab*. A work area 
%    is a required setting. Only folders in the work area are removed for
%    safety reasons.
%
%    No good and safe way to use the Matlab delete function has been found,
%    and platforms specific commands are used. So far, only Unix type
%    platforms are handled.
%
% FORMAT   delete_tmpfolder(tmpfolder)
%
% IN       tmpfolder   Full path of folder to remove. 

% 2005-01-27  Added force (-f) flag to unix remove command. Without this
%             the function does not work for users with alias rm='rm -i'.
%             Mattias Ekstrom
% 2002-12-20  Created by Patrick Eriksson, based on older version
%             in AMI (part of arts-1).


function delete_tmpfolder(tmpfolder)


%=== Require that a work area is set as a personal setting
%
atmlab( 'require', {'WORK_AREA'} );
workarea = atmlab( 'WORK_AREA' );
%
if ~ischar( workarea )
  error( 'WORKAREA must be a string' );
end 


if ~strncmp( workarea, tmpfolder, length(workarea) )
  error('The given directory is not inside the work area.');
end


%=== The Matlab delete function was tested but no good and secury solution 
%=== could be found and system commands are used instead.
%
if isunix
  eval([ '!rm -rf ', tmpfolder ])
else
  error('Unknown computer type.');
end

