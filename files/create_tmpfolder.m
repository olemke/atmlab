% CREATE_TMPFOLDER   Creation of a temporary folder in the work area.
%
%    The function creates a folder in the folder set as work area in
%    *atmlab*. See CONFIGURE for information about *atmlab*. A work area 
%    is a required setting.
%
%    The folder is named as TmpXXXXXX, where XXXXXX is a random number 
%    between 1 and 999999. The created folder will have an unique name. 
%    Random numbers are generated until an unique folder name is found.
%
% FORMAT   tmpfolder = create_tmpfolder
%        
% OUT      tmpfolder   Full path to created folder.
% ATMLAB   WORK_AREA   The work area is required as a personal setting.

% 2002-12-20  Created by Patrick Eriksson, based on older version
%             in AMI (part of arts-1).


function tmpfolder = create_tmpfolder


%=== Require that a work area is set as a personal setting
%
atmlab( 'require', {'WORK_AREA'} );
workarea = atmlab( 'WORK_AREA' );
%
if ~ischar( workarea )
  error( 'WORKAREA must be a string' );
end 


if ~exist( workarea, 'dir' )
  error(sprintf('The given work area (%s) does not exist.',workarea));  
end


startdir = pwd;


cd( workarea );

ready = 0;

s = rand( 'state' );

rand( 'state', 1e6*sum(clock) )

%=== Loop until a new folder with unique name has been created
%
while ~ready
  
  tmpfolder = sprintf('Tmp%d',floor(1e6*rand(1)));

  if ~exist( tmpfolder, 'dir' )
    [a,b] = mkdir(tmpfolder);     
    if isempty(b)              % Check again if folder exist, for extra safety
      ready = 1;
    end
  end

end

rand( 'state', s );

cd( startdir );

tmpfolder = fullfile( workarea, tmpfolder );
