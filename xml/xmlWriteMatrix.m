% Writes a Matrix to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteMatrix(fid, data)
%
% IN    fid    File descriptor
% IN    data   Matrix
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteMatrix(fid, data)

s = size (data);

for i = (ndims (data)+1):2
  s(i) = 1
end

nr = s(1);
nc = s(2);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Matrix', attrlist);

data = reshape (data, [nr nc]);
data = data';

form='%e';
for i = 1:(nc-1)
  form = sprintf ('%s %%e', form);
end
form = sprintf ('%s\n', form);

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Matrix');

clear attrlist form nr nc;

