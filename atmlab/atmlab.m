% ATMLAB   Handling of Atmlab settings.
%
%   This function is based on *prstnt_struct* and for general help see 
%   the on-line help for that function. 
%
%   Existing fields, and possible settings, are listed below. The default 
%   value for all fields is to be empty.
%
%   For adding personal settings at startup, see the file CONFIGURE. To 
%   add or change settings after startup, follow the example below. x
%
%   To check all present settings
%      atmlab;
%
%   A specific setting is obtained as
%      value = atmlab( 'FMODEL_NAME' );
%
%   To set a field to a specic value
%      atmlab( 'FMODEL_NAME', 'arts' );
%
%   To set all fields to be empty
%      atmlab( 'defaults' );
%
% FORMAT   value = atmlab( [varargin] )
%        
% OUT   value      Setting, if a field is selected. See further 
%                  *prstnt_struct*.
% OPT   varargin   Field, field and setting or any option supported by
%                  *prstnt_struct*.
%
%----------------------------------------------------------------------------
% WORK_AREA
% 
% A folder to be used for calculations outside Matlab. For each calculation
% session, a folder is created in the given folder with name TmpXXXXXX where
% XXXXXX is an integer with up to 6 digits. Atmlab tries to keep the given
% folder clean by removing the temporary folders when ready, but if there
% is a crash the temporary folder will not be removed. The temporary folders
% are not re-used and before the debugging is finished a high number of
% folders can be created in the work area and it can be a good idea to remove
% old temporary folders.
%    The full path shall be given. A normal choice for work area on Unix type 
% platforms is '/tmp'.
%    The work area is primarily used for forward model calculations, but
% there could be other applications.
%
%----------------------------------------------------------------------------
% FMODEL_NAME
%
% The name of forward model to use (if any). If no forward model will be 
% used, just keep the field empty.
%    Atmlab folders with functions associated with a forward model are only
% included in the search path if that particular forward model is used. That
% is, if this field is empty, none of the forward model folders is added to
% the search path. Possible options are:
%
%    'arts' 
%       The latest ARTS version.
%
% (more forward models will hopefully be added later, at least, arts-1)
%
%----------------------------------------------------------------------------
% FMODEL_EXEC
%
% Forward model executable and general arguments.
%    This string shall include the name of the forward model executable,
% or the full path of the executable, depending on your configuration.
% If the forward model can take command line arguments, beside the name,
% of a control file, such arguments can be added to the string. An
% example: FMODEL_EXEC = '/home/patrick/bin/arts2 -r40'
%    The strings created to call different forward models are described
% in the header of the function *call_fmodel*.
%
%----------------------------------------------------------------------------

% 2003-07-06   Created by Patrick Eriksson.


function value = atmlab( varargin )
            
persistent A
          
[A,value] = prstnt_struct( A, @atmlab_defs, varargin );



function A = atmlab_defs

A.WORK_AREA   = [];
A.FMODEL_NAME = [];
A.FMODEL_EXEC = [];

