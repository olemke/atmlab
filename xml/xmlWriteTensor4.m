% Writes a Tensor4 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteTensor4(fid, data, precision)
%
% IN    fid    File descriptor
% IN    data   Tensor4
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteTensor4(fid, data, precision)

s = size (data);

for i = (ndims (data)+1):4
  s(i) = 1;
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

format=xmlGetPrecisionFormatString (precision);
form=format;
for i = 1:(nc-1)
  form = sprintf ('%s %s', form, format);
end
form = strcat (form, '\n');

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Tensor4');

clear attrlist form format nb np nr nc;

