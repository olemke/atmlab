% Writes a Tensor3 to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteTensor3(filename, data)
%
% IN    filename   Name of output file
% IN    data       Tensor3
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor3(filename, data)

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

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Tensor3', attrlist);

data = permute (data, [3 2 1]);

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor3');
xmlWriteFooter (fid);
fclose (fid);

clear attrlist fid form np nr nc;

