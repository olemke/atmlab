% ARTS1_LOADFILE   Loads file created by cfile from ARTS1_CFILE
%
%    This function loads an output file created by running a control file
%    created by *arts1_cfile*. These files can either be in ASCII or
%    binary format depending on if HDF is available or not, and the 
%    function resolves this and tries to load a file with the expected
%    name and extension.
%
% FORMAT   a = arts1_loadfile( folder, varname, type )
%        
% OUT   a        Loaded data.
% IN    folder   Folder holding file to load.
%       varname  ARTS1 variable name.
%       type     ARTS1 variable type.

% 2004-09-11   Created by Patrick Eriksson.


function a = arts1_loadfile( folder, varname, type )


%=== What ARTS1 file format to use?
%
use_binary = atmlab( 'ARTS1_HDF' );
rqre_bool( 'Atmlab setting ARTS1_HDF', use_binary );
if use_binary
  fileext = '.ab';
else
  fileext = '.aa';
end


a = read_datafile( fullfile( folder, [varname,fileext] ), type );
