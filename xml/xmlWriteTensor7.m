% Writes a Tensor7 to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteTensor7(filename, data)
%
% IN    filename   Name of output file
% IN    data       Tensor7
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor7(filename, data)

s = size (data);

for i = (ndims (data)+1):7
  s(i) = 1
end

nl = s(1);
nv = s(2);
ns = s(3);
nb = s(4);
np = s(5);
nr = s(6);
nc = s(7);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nlibraries', sprintf ('%d', nl));
attrlist = xmlAddAttribute (attrlist, 'nvitrines', sprintf ('%d', nv));
attrlist = xmlAddAttribute (attrlist, 'nshelves', sprintf ('%d', ns));
attrlist = xmlAddAttribute (attrlist, 'nbooks', sprintf ('%d', nb));
attrlist = xmlAddAttribute (attrlist, 'npages', sprintf ('%d', np));
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Tensor7', attrlist);

data = permute (data, [7 6 5 4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor7');
xmlWriteFooter (fid);
fclose (fid);

clear attrlist fid form nl nv ns nb np nr nc;

