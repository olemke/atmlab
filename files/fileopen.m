% FILEOPEN   Open file with error message if not succesful.
%
%    This function calls *fopen* to open the given file, and gives an error
%    if the file could not be opened. This function saves you the trouble
%    of checking the file identified returned by *fopen*.
%
% FORMAT   See *fopen*.

% 2002-12-20   Created by Patrick Eriksson.


function fid = fileopen(filename,varargin)
                                                                           %&%
%= Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 1, nargin );                                                  %&%
rqre_datatype( filename, @ischar );                                        %&%


%= Call fopen
%
fid = fopen( filename, varargin{:} );


%= Was open succesful?
%
if fid < 0
  serr = sprintf( 'Could not open the file %s.', filename );
  error( serr );
end