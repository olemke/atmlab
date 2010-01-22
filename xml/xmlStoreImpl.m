% Writes  data to an XML file.
%
%    This is the generic writing routine for XML files. You have to give
%    the filename, the data and the type of data as a string.
%
%    E.g. writing the vector v to file 'vect.xml':
%
%    xmlStoreImpl ('vect.xml', 'Some comment', v, 'Vector');
%
%    Make sure that the data you're passing has the correct type.
%
% FORMAT   xmlStoreImpl(filename, comment, data, type, precision)
%
% IN    filename   Name of output file
% IN    comment    Comment to store along with the data
% IN    data       Data
% IN    type       Data type

% 2002-12-16  Created by Oliver Lemke.


function xmlStoreImpl(filename, comment, data, type, precision)

%=== Basic ckeck of input
%
rqre_nargin( 2, nargin );
%
if nargin < 5
  precision = 'FLOAT';
end

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);

if length (comment) > 0
  xmlWritecomment (fid, comment);
end

if length (type) > 14 & type (1:14) == 'ArrayOfArrayOf'
  xmlWriteArrayOfArrayOf (fid, data, type(15:length(type)), precision);
elseif length (type) > 7 & type (1:7) == 'ArrayOf'
  xmlWriteArrayOf (fid, data, type (8:length(type)), precision);
else
  func = str2func (strcat ('xmlWrite', type));
  feval (func, fid, data, precision);
end

xmlWriteFooter (fid);
fclose (fid);

clear fid func;

