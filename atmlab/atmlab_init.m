% ATMLAB_INIT   Initializes the Atmlab package
%
%    Atmlab folders are added to the search path. The folders are put 
%    at the start of the search path (prepended).
%
%    All Atmlab settings are first set to default values. After this,
%    the function *atmlab_conf* is executed, if such a function is found 
%    in the search path. See further CONFIGURE.
%
%    The random state is initialised according to atmlab setting RAND_STATE.
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
addpath( fullfile( toppath, 'time' ) );
addpath( fullfile( toppath, 'tests' ) );
addpath( fullfile( toppath, 'sensors', 'atovs' ) ); 
addpath( fullfile( toppath, 'sensors' ) ); 
addpath( fullfile( toppath, 'scattering' ) ); 
addpath( fullfile( toppath, 'retrieval','qpack2' ) ); 
addpath( fullfile( toppath, 'retrieval' ) ); 
addpath( fullfile( toppath, 'randomize','iaaft' ) ); 
addpath( fullfile( toppath, 'randomize' ) ); 
addpath( fullfile( toppath, 'pyarts' ) ); 
addpath( fullfile( toppath, 'physics' ) ); 
addpath( fullfile( toppath, 'mie' ) ); 
addpath( fullfile( toppath, 'math' ) ); 
addpath( fullfile( toppath, 'handy' ) ); 
addpath( fullfile( toppath, 'h2o', 'parametrisations' ) ); 
addpath( fullfile( toppath, 'h2o', 'thermodynamics' ) ); 
addpath( fullfile( toppath, 'gridcreation', 'annealing' ) ); 
addpath( fullfile( toppath, 'gridcreation' ) ); 
addpath( fullfile( toppath, 'graphs' ) );
addpath( fullfile( toppath, 'gformat' ) );
addpath( fullfile( toppath, 'geoplots', 'gmt') );
addpath( fullfile( toppath, 'geoplots' ) );
addpath( fullfile( toppath, 'geophysics' ) );
addpath( fullfile( toppath, 'forwardmodel' ) );
addpath( fullfile( toppath, 'files' ) ); 
addpath( fullfile( toppath, 'demos' ) );
addpath( fullfile( toppath, 'datasets' ) ); 
addpath( fullfile( toppath, 'circular' ) ); 
addpath( fullfile( toppath, 'covmat' ) );
addpath( fullfile( toppath, 'collocations' ) ); 
addpath( fullfile( toppath, 'atmlab' ) ); 
addpath( fullfile( toppath, 'arts', 'netcdf' ) ); 
addpath( fullfile( toppath, 'arts', 'scenegen', 'amsu' ) ); 
addpath( fullfile( toppath, 'arts', 'scenegen' ) ); 
addpath( fullfile( toppath, 'arts', 'xml' ) ); 
addpath( fullfile( toppath, 'arts' ) ); 
%
if nversion < 7.04
  addpath( fullfile( toppath, 'V7-4' ) ); 
end

%=== Read Atmlab settings
%
if exist( 'atmlab_conf' ) == 2
  atmlab_conf;
else
  atmlab('defaults');  
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

% Add directory for site-specific settings, initialise subsystems

if ~isnan(atmlab('SITE'))
    sitedir = fullfile(toppath, 'site-specific', atmlab('SITE'));
    if exist(sitedir, 'dir')
        addpath(sitedir);
        % execute any initialisation m-files
        W = whichfiles('*init.m', sitedir);
        for i = 1:length(W)
            run(W{1});
        end
    else
        warning('ATMLAB:unkownsite','Unknown site: %s',atmlab('SITE'))
    end
end

% define some aliases

alias('amsub', 'mhs');