% Writes a Tensor3 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor3(fid, data)
%
% IN    fid   File descriptor
% IN    data  Tensor3
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor3(fid, data)

s = size (data);

for i = (ndims (data)+1):3
  s(i) = 1
end

np = s(1);
nr = s(2);
nc = s(3);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor3', attrlist);

data = permute (data, [3 2 1]);

form='%e';
for i = 1:(nc-1)
  form = sprintf ('%s %%e', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor3');

clear attrlist form np nr nc;

