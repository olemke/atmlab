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
%   To set all fields to default
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
% AMI_PATH
%
% The path to the AMI top folder. AMI contains Matlab functions needed for 
% communication with ARTS1. If you are not using ARTS1, just leave this field
% empty. 
% AMI is added by the function *addpath_ami*, where only the arts subfolder
% is added to the Matlab search path.
%----------------------------------------------------------------------------
% ARTS_PATH
%
% Path to executable for ARTS. For example '/home/patrick/ARTS/arts2/src/arts'.
%----------------------------------------------------------------------------
% ARTS_XMLDATA_PATH
%
% Path to main folder of arts-xml-data. 
% The arts-xml-data is a compilation of useful data for ARTS calculations.
% Contact the ARTS team if you want access to the data. The data is used
% as input for ARTS example functions. 
%----------------------------------------------------------------------------
% ARTS1_HDF
%
% Boolean to indicate if ARTS-1.0.x is compiled with HDF. If true, the binary
% file format will be used.
%----------------------------------------------------------------------------
% ARTS1_PATH
%
% Path to executable for ARTS-1.0.x. 
%----------------------------------------------------------------------------
% FMODEL_VERBOSITY
%
% Verbosity of forward model, if such a feature is supported. If field is
% is empty, this is interpreted as no verbosity. The forward models work as:
%   ARTS (both versions):
%     A number between 0 and 3, where 3 means highest level of verbosity.
%----------------------------------------------------------------------------
% SCREEN_WIDTH
% 
% The width, in number of characters, of the Matlab window.
% Used by the function *out* to make a frame around screen output.
%----------------------------------------------------------------------------
% VERBOSITY
% 
% The verbosity of Atmlab functions.  
% Functions writing to the screen set a report level for each output. If the
% the set report level is higher than VERBOSITY, the output is ignored.
% Output obeying this setting is most easily produced with the function *out*.
% Functions can also use VERBOSITY to decide if figures shall be produced
% (which is most easily checked by using *out*).
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
%----------------------------------------------------------------------------

% 2003-07-06   Created by Patrick Eriksson.


function value = atmlab( varargin )
            
persistent A
          
[A,value] = prstnt_struct( A, @atmlab_defs, varargin );



function A = atmlab_defs

A.AMI_PATH          = NaN;
A.ARTS_PATH         = NaN;
A.ARTS_XMLDATA_PATH = NaN;
A.ARTS1_HDF         = NaN;
A.ARTS1_PATH        = NaN;
A.FMODEL_VERBOSITY  = NaN;
A.SCREEN_WIDTH      = NaN;
A.VERBOSITY         = NaN;
A.WORK_AREA         = NaN;

