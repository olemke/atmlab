% Writes an Array to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOf(fid, data, type)
%
% IN    fid    File descriptor
% IN    data   Array
% IN    type   Data type as string

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteArrayOf(fid, data, type)

nelem = size (data, 2);

attrlist = [];
attrlist = xmlAddAttribute ([], 'type', sprintf ('%d', nelem));
attrlist = xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
for i = 1:nelem
  func = str2func (strcat ('xmlWrite', type));
  feval (func, fid, data{i});
end
xmlWriteCloseTag (fid, 'Array');

clear fid nelem;

