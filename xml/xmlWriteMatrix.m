% Writes a Matrix to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteMatrix(filename, data)
%
% IN    filename   Name of output file
% IN    data       Matrix
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteMatrix(filename, data)

s = size (data);

for i = (ndims (data)+1):2
  s(i) = 1
end

nr = s(1);
nc = s(2);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Matrix', attrlist);

data = reshape (data, [nr nc]);
data = data';

form='%f';
for i = 1:(nc-1)
  form = sprintf ('%s %%f', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Matrix');
xmlWriteFooter (fid);
fclose (fid);

clear attrlist fid form nr nc;

