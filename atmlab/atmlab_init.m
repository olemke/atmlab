% ATMLAB_INIT   Adds the folders of Atmlab search path.
%
%    The folders are put at the start of the search path (prepended).
%  
%    This function must be placed at the top folder of Atmlab.
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
%
addpath( fullfile( toppath, 'xml' ) ); 
addpath( fullfile( toppath, 'physics' ) ); 
addpath( fullfile( toppath, 'math' ) ); 
addpath( fullfile( toppath, 'handy' ) ); 
addpath( fullfile( toppath, 'graphs' ) );
addpath( fullfile( toppath, 'forwardmodel' ) );
addpath( fullfile( toppath, 'files' ) ); 
addpath( fullfile( toppath, 'atmscenarios' ) ); 
addpath( fullfile( toppath, 'atmplots' ) ); 
addpath( fullfile( toppath, 'atmlab' ) ); 



%= Add forward model folder(s), if a forward model is specified
%
fmodel = atmlab_get( 'FMODEL_NAME' );
%
if ~isempty( fmodel )
  
  switch fmodel

    case 'arts'
      %
      addpath( fullfile( toppath, 'arts' ) );

    otherwise
      % 
      serr = sprintf('You have selected an unknown forwrad model (%s).', ...
                                                                      fmodel );
      error( serr );
  end
end