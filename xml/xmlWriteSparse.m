% Writes a Sparse to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSparse(fid, data)
%
% IN    fid    File descriptor
% IN    data   Sparse
                                                                                                                               
% 2003-06-16  Created by Mattias Ekström.

function xmlWriteSparse(fid, data)

s = size (data);

nr = s(1);
nc = s(2);
nonz = nnz (data);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));
attrlist = xmlAddAttribute (attrlist, 'nnz', sprintf ('%d', nonz));

xmlWriteTag (fid, 'Sparse', attrlist);

[r,c] = find (data);

form='%e';
for i = 1:(nonz-1)
  form = sprintf ('%s %%e', form);
end
form = sprintf ('%e\n', form);

fprintf (fid, '%d ', r-1);
fprintf (fid, '\n');

fprintf (fid, '%d ', c-1);
fprintf (fid, '\n');

fprintf (fid, '%e ', nonzeros(data));
fprintf (fid, '\n');

xmlWriteCloseTag (fid, 'Sparse');

clear attrlist form nr nc nonz r c i;

