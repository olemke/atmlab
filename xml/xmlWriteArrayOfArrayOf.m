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

nelem = size (data, 2);

attrlist = [];
attrlist = xmlAddAttribute ([], 'type', sprintf ('ArrayOf%s', type));
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
xmlWriteArrayOf (fid, data, type);
xmlWriteCloseTag (fid, 'Array');

clear nelem;

