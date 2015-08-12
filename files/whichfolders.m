% WHICHFOLDERS   Gives a list of folders in a folder
%
%    The function returns all folders in a folder that match some regular
%    search expression. 
%
%    The folders . and .. are ignored.
%    
%    See also *whichfiles*.
% 
% FORMAT   foldernames = whichfiles( [ rgexp, folder ] )
%        
% OUT   foldernames Cell array of strings with names of folders. Complete path
%                   is given.
% OPT   rgexp       Search expression, such as '*.mat'. Default is '*'.
%       folder      Path to folder. If not given, pwd is used.

% 2015-08-11   Created by Patrick Eriksson.


function foldernames = whichfolders( rgexp, folder )


if nargin < 1
  rgexp = '*';
end
if nargin < 2
  folder = pwd;
end


%= Search folder 
%
D = dir( fullfile( folder, rgexp ) );


%= Create filenames
%
foldernames = [];  % If no files found
%
if ~isempty(D)
  j = 0;
  for i = 1:length(D)
    if D(i).isdir  &  ~strcmp(D(i).name,{'.','..'})
      j = j + 1;
      foldernames{j} = fullfile( folder, D(i).name );
    end
  end
end
 
