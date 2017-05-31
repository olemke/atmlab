% LOADVAR   Loads a specific variable from a MATLAB data file
%
%    The function enables direct loading of a named variable (matlab's load
%    function puts into a struct). To load the variable x from file data.mat:
%
%        x = loadvar( 'data.mat', 'x' )
%
% FORMAT   x = loadvar( filename, varname )
%
% OUT   x          Loaded variable
% IN    filename   Name of file.
%       varname    Name of variable.

% 2008-10-27   Created by Patrick Eriksson.
% 2017-05-31   Modified by Salomon Eliasson

function x = loadvar( filename, varname )

if ~iscell(varname), varname={varname}; end
    
for V = varname(:)'
    v = V{1};
    try
        X = load( filename, v );
    catch ME
        switch ME.identifier
            case 'MATLAB:load:numColumnsNotSame'
                % Matlab tried to load as ASCII and failed.
                % Try to load as binary MAT-file instead.
                X = load(filename, v, '-mat');
            otherwise
                ME.rethrow();
        end
    end
    
    if ~isfield( X, v )
        error( ['atmlab:' mfilename ':variableNotFound'],...
            lastwarn);
    else
        x.(v) = X.(v);
    end
end

end
