% Writes a Tensor5 to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteTensor5(filename, data)
%
% IN    filename   Name of output file
% IN    data       Tensor5
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor5(filename, data)

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

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Tensor5', attrlist);

data = permute (data, [5 4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor5');
xmlWriteFooter (fid);
fclose (fid);

clear attrlist fid form ns nb np nr nc;

