% Writes a Tensor4 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor4(fid, data)
%
% IN    fid    File descriptor
% IN    data   Tensor4
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor4(fid, data)

s = size (data);

for i = (ndims (data)+1):4
  s(i) = 1
end

nb = s(1);
np = s(2);
nr = s(3);
nc = s(4);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor4', attrlist);

data = permute (data, [4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor4');

clear attrlist form nb np nr nc;

