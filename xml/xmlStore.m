% Writes a data to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlStore(filename, data, type)
%
% IN    filename   Name of output file
% IN    data       Data
% IN    type       Data type
                                                                                                                               
% 2002-12-16  Created by Oliver Lemke.

function xmlWriteVector(filename, data, type)

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);

if length (type) > 14 & type(1:14) == 'ArrayOfArrayOf'
  xmlWriteArrayOfArrayOf (fid, data, type(15:length(type)));
elseif length (type) > 7 & type(1:7) == 'ArrayOf'
  xmlWriteArrayOf (fid, data, type(8:length(type)));
else
  func = str2func (strcat ('xmlWrite', type));
  feval (func, fid, data);
end

xmlWriteFooter (fid);
fclose (fid);

clear fid func;

