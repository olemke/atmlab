% Writes  data to an XML file.
%
%    This is the generic writing routine for XML files. You have to give
%    the filename, the data and the ARTS type of data as a string.
%
%    E.g. writing the vector v to file 'vect.xml':
%
%    xmlStoreWithComment ('vect.xml', 'My comment', v, 'Vector');
%
%    Make sure that the data you're passing has the correct type.
%
% FORMAT   xmlStoreWithComment(filename, comment, data, artstype, precision)
%
% IN    filename   Name of output file
% IN    comment    Comment to store along with the data
% IN    data       Data
% IN    artstype   ARTS Data type (e.g. 'Vector', 'ArrayOfVector')
% IN    precision  Precision for output of floating point numbers, could be
%                  either 'FLOAT' or 'DOUBLE' (Default: 'FLOAT')

% 2002-12-16  Created by Oliver Lemke.


function xmlStore(filename, comment, data, artstype, precision)

if nargin < 5
  xmlStoreImpl(filename, comment, data, artstype)
else
  xmlStoreImpl(filename, comment, data, artstype, precision)
end

