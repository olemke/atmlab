% Writes a Tensor5 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor5(fid, data)
%
% IN    fid    File descriptor
% IN    data   Tensor5
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor5(fid, data)

s = size (data);

for i = (ndims (data)+1):5
  s(i) = 1
end

ns = s(1);
nb = s(2);
np = s(3);
nr = s(4);
nc = s(5);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nshelves', sprintf ('%d', ns));
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor5', attrlist);

data = permute (data, [5 4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor5');

clear attrlist form ns nb np nr nc;

