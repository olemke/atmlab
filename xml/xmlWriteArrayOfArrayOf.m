% Writes an ArrayOfArray to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOfArrayOf(fid, data, type)
%
% IN    fid    File descriptor
% IN    data   Vector
% IN    type   Data type as string

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteArrayOfArrayOf(fid, data, type)

nelem = size (data, 1);

attrlist = [];
attrlist = xmlAddAttribute ([], 'type', sprintf ('ArrayOf%s', type));
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
for i = 1:nelem
  xmlWriteArrayOf (fid, data{i}, type);
  xmlWriteCloseTag (fid, 'Array');
end
clear i nelem;

