% ATMLAB_DEFS   Defaults for Atmlab user settings.
%
%    A structure of the type used for the Atmlab personal settings is created
%    where all fields are set to be empty.
%
%    Only fields defined here are valid setting options. The fields, and their
%    options are described in the function body. To display the function
%    execute:
%       type atmlab_defs.m 
%
%    The personal settings are given in function called *atmplot*. You find
%    a template function as examples/atmplot.m.
%
% FORMAT   A = atmlab_defs
%        
% OUT   A   A structure with just empty fields. See the function body
%           for field names.

% 2002-12-19   Created by Patrick Eriksson.


function A = atmlab_defs


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
A.WORK_AREA = [];


% FMODEL
%
% The forward model to use (if any). If no forward model will be used, just
% keep the field empty.
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
A.FMODEL    = [];

