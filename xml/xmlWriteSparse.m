% Writes a Sparse to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSparse(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       Sparse
% IN    precision  Precision for floats

% 2003-06-16  Created by Mattias Ekström.

function xmlWriteSparse(fid, data, precision)

s = size (data);

nr = s(1);
nc = s(2);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Sparse', attrlist);

[r,c] = find (data);

xmlWriteRowIndex (fid, r - 1);
xmlWriteColIndex (fid, c - 1);
xmlWriteSparseData (fid, nonzeros(data), precision);

xmlWriteCloseTag (fid, 'Sparse');

clear attrlist form nr nc r c i;

