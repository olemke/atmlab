% Writes a Tensor6 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor6(fid, data)
%
% IN    fid    File descriptor
% IN    data   Tensor6
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor6(fid, data)

s = size (data);

for i = (ndims (data)+1):6
  s(i) = 1
end

nv = s(1);
ns = s(2);
nb = s(3);
np = s(4);
nr = s(5);
nc = s(6);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nvitrines', sprintf ('%d', nv));
attrlist = xmlAddAttribute (attrlist, 'nshelves', sprintf ('%d', ns));
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Tensor6', attrlist);

data = permute (data, [6 5 4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor6');

clear attrlist fid form nv ns nb np nr nc;

