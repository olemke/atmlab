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
addpath( fullfile( toppath, 'xml' ) ); 
addpath( fullfile( toppath, 'sensors' ) ); 
addpath( fullfile( toppath, 'physics' ) ); 
addpath( fullfile( toppath, 'mie' ) ); 
addpath( fullfile( toppath, 'math' ) ); 
addpath( fullfile( toppath, 'handy' ) ); 
addpath( fullfile( toppath, 'graphs' ) );
addpath( fullfile( toppath, 'forwardmodel' ) );
addpath( fullfile( toppath, 'files' ) ); 
addpath( fullfile( toppath, 'atmscenarios' ) ); 
addpath( fullfile( toppath, 'atmplots' ) ); 
addpath( fullfile( toppath, 'atmlab' ) ); 



%=== Read Atmlab settings
%
atmlab('defaults');
if exist( 'atmlab_conf' ) == 2
  atmlab_conf;
end



%= Add forward model folder(s), if a forward model is specified
%
fmodel = atmlab( 'FMODEL_NAME' );
%
if ~isempty( fmodel )
  
  switch fmodel

    case 'arts'
      %
      addpath( fullfile( toppath, 'arts' ) );

    otherwise
      % 
      serr = sprintf('You have selected an unknown forward model (%s).', ...
                                                                      fmodel );
      error( serr );
  end
end