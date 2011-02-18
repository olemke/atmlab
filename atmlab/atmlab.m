% ATMLAB   Handling of Atmlab settings.
%
%   This function is based on *prstnt_struct* and for general help see 
%   the on-line help for that function. 
%
%   Existing fields, and possible settings, are listed below. 
%
%   For adding personal settings at startup, see the file CONFIGURE. To 
%   add or change settings after startup, follow the example below. 
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
% ARTS_INCLUDES
%
% Path to main folder for ARTS include files. 
% For example '/home/patrick/ARTS/arts2/include'.
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
% as input for ARTS example/utility functions. 
%----------------------------------------------------------------------------
% DEBUG
%
% Flag to set to simplify debugging. No overall effect, but this flag is
% recognised by some functions. For example, if this flag is set the temporary
% work folders are not removed, to make it possible to check the content
% in these folders.
%----------------------------------------------------------------------------
% ERR
%
% Stream to log error messages to. Used by some subsystems.
%----------------------------------------------------------------------------
% EXTRAP
%
% Flag for automatic extrapolation of data at interpolation. The approach is to
% treat data to be constant outside end points. That is, the data values at end
% points are assumed to be valid to -Inf andf Inf, respectively. 
%     This functionality is implemented by the functions *interpd* and 
% *regrid*, which should be used of all atmlab functions of general
% character. Special functions may not obey this setting variable.
%----------------------------------------------------------------------------
% FMODEL_VERBOSITY
%
% Verbosity of forward model, if such a feature is supported. If field is
% is empty, this is interpreted as no verbosity. The forward models work as:
%   ARTS (both versions):
%     A number between 0 and 3, where 3 means highest level of verbosity.
%----------------------------------------------------------------------------
% OUT
%
% Stream to log ordinary messages to. Used by some subsystems.
%----------------------------------------------------------------------------
% RAND_STATE
%
% Initialisation of random states (for rand and randn). Performed inside
% *atmlab_init*. Either NaN or an integer. If set to NaN, a semi-random 
% state is generated. Otherwise the specified value is used as state for 
% both rand and randn.
%----------------------------------------------------------------------------
% SITE
%
% Location, system, e.g. Kiruna, Chalmers. If there is a directory
% site-specific/SITE, this will be used to initialise default values for
% the settings for some subsystems (for example, datasets will 'know' where to
% find data).
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
% ATMLAB_DATA_PATH
%
% Path to main directory of atmlab-data
% atmlab-data is a compilation of useful data for various atmlab tasks.
% It is available in the atmlab-data/trunk directory of the rt svn repo.


% 2003-07-06   Created by Patrick Eriksson.


function value = atmlab( varargin )
            
persistent A

[A,value] = prstnt_struct( A, @atmlab_defs, varargin );


function A = atmlab_defs

A.ARTS_INCLUDES     = NaN;
A.ARTS_PATH         = NaN;
A.ARTS_XMLDATA_PATH = NaN;
A.ATMLAB_DATA_PATH  = NaN;
A.DEBUG             = false;
A.ERR               = 2;
A.EXTRAP            = false;
A.FMODEL_VERBOSITY  = 0;
A.OUT               = 1;
A.RAND_STATE        = NaN;
A.SCREEN_WIDTH      = 70;
A.SITE              = NaN;
A.VERBOSITY         = 1;
A.WORK_AREA         = NaN;