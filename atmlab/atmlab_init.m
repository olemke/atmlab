% ATMLAB_INIT   Initializes the Atmlab package
%
%    Atmlab folders are added to the search path. The folders are put 
%    at the start of the search path (prepended).
%
%    All Atmlab settings are first set to be empty ([]). After this,
%    the function *atmlab_conf* is executed, if such a function is found 
%    in the search path. See further CONFIGURE.
%  
% FORMAT   atmlab_init

% 2002-12-09   Created by Patrick Eriksson.


function atmlab_init


%= Determine path to Atmlab top folder
%
toppath = fileparts( fileparts( which( 'atmlab_init' ) ) );


%= Add folders to the search path
%
% If you create a new sub-folder, it should be added here.
% Please use reversed alphabetical order.
%
% Note that /obsolete or /versionfixes shall NOT be included here
%
addpath( fullfile( toppath, 'xml' ) ); 
addpath( fullfile( toppath, 'time' ) );
addpath( fullfile( toppath, 'tests' ) );
addpath( fullfile( toppath, 'sensors' ) ); 
addpath( fullfile( toppath, 'scattering' ) ); 
addpath( fullfile( toppath, 'retrieval' ) ); 
addpath( fullfile( toppath, 'randomize','iaaft' ) ); 
addpath( fullfile( toppath, 'randomize' ) ); 
addpath( fullfile( toppath, 'pyarts' ) ); 
addpath( fullfile( toppath, 'physics' ) ); 
addpath( fullfile( toppath, 'parametrisations' ) );
addpath( fullfile( toppath, 'mie' ) ); 
addpath( fullfile( toppath, 'math' ) ); 
addpath( fullfile( toppath, 'handy' ) ); 
addpath( fullfile( toppath, 'graphs' ) );
addpath( fullfile( toppath, 'gformat' ) );
addpath( fullfile( toppath, 'geoplots' ) ); 
addpath( fullfile( toppath, 'forwardmodel' ) );
addpath( fullfile( toppath, 'files' ) ); 
addpath( fullfile( toppath, 'demos' ) );
addpath( fullfile( toppath, 'atmlab' ) ); 
addpath( fullfile( toppath, 'arts1' ) ); 
addpath( fullfile( toppath, 'arts', 'scenegen' ) ); 
addpath( fullfile( toppath, 'arts' ) ); 


%=== Check if functions from newer Matlab versions shall be included
%
version_fixes( toppath )


%=== Read Atmlab settings
%
atmlab('defaults');
if exist( 'atmlab_conf' ) == 2
  atmlab_conf;
end


%=== Init random states
%
rand_state = atmlab( 'RAND_STATE' ); 
%
if isnan( rand_state )
  
  %- Create random state. Add window number to get different states for
  %  different matlab runs (works only for linux).
  %
  nr = getenv('WINDOWID');
  if isempty(nr)
    nr = 0;
  else
    nr = str2num( nr );
  end
  %
  rand( 'state', sum(100*clock) + nr );
  randn( 'state', sum(100*clock) + nr );
  
else
  rand( 'state', rand_state );
  randn( 'state', rand_state );
end


%----------------------------------------------------------------------------

function version_fixes( toppath )

infolder  = 'obsolete';
outfolder = 'AUTO_fixes';


%= Get functions residing in *infolder*
%
D = dir( fullfile( toppath, infolder, '*.m' ) );


%= Loop and see if function already exists
%
to_include = [];
%
for i = 1 : length(D)

  [pathstr,name] = fileparts( D(i).name );

  if ~strcmp(name,'Contents')  &  exist( name ) < 2
    to_include = [ to_include i ]; 
  end

end


if ~isempty( to_include )

  %= Create or empty target folder
  if ~exist( fullfile( toppath, outfolder ) )
    mkdir( toppath, outfolder );
  else
    delete( fullfile( toppath, outfolder, '*' ) );
  end

  for i = 1 : length(to_include)
    copyfile( fullfile( toppath, infolder,  D(to_include(i)).name) , ...
              fullfile( toppath, outfolder, D(to_include(i)).name) )
  end

  addpath( fullfile( toppath, outfolder ) ); 

end
