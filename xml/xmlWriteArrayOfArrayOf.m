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

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1');
end

nelem = length (data);

attrlist = [];
attrlist = xmlAddAttribute ([], 'type', sprintf ('ArrayOf%s', type));
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
for i = 1:nelem
  xmlWriteArrayOf (fid, data{i}, type);
  xmlWriteCloseTag (fid, 'Array');
end
clear i nrows ncols nelem;

