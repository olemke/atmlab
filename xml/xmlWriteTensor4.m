% Writes a Tensor4 to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteTensor4(filename, data)
%
% IN    filename   Name of output file
% IN    data       Tensor4
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor4(filename, data)

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

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Tensor4', attrlist);

data = permute (data, [4 3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor4');
xmlWriteFooter (fid);
fclose (fid);

clear attrlist fid form nb np nr nc;

