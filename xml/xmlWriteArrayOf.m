% Writes an Array to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteArrayOf(fid, data, type, precision)
%
% IN    fid        File descriptor
% IN    data       Array
% IN    type       Data type as string
% IN    precision  Precision for floats

% 2002-12-16  Created by Oliver Lemke.

function xmlWriteArrayOf(fid, data, type, precision)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 & ncols ~=0 & nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

attrlist = [];
attrlist = xmlAddAttribute ([], 'type', type);
attrlist = xmlAddAttribute (attrlist, 'nelem', sprintf ('%d', nelem));
xmlWriteTag (fid, 'Array', attrlist);
for i = 1:nelem
  func = str2func (strcat ('xmlWrite', type));
  feval (func, fid, data{i}, precision);
end
xmlWriteCloseTag (fid, 'Array');

clear fid ncols nrows nelem;

