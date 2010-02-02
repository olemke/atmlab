% Writes a Matrix to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteMatrix(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       Matrix
% IN    precision  Precision for floats

% 2002-12-13  Created by Oliver Lemke.

function xmlWriteMatrix(fid, data, precision)

s = size (data);

for i = (ndims (data)+1):2
  s(i) = 1;
end

nr = s(1);
nc = s(2);

attrlist = [];
attrlist = xmlAddAttribute (attrlist, 'nrows', sprintf ('%d', nr));
attrlist = xmlAddAttribute (attrlist, 'ncols', sprintf ('%d', nc));

xmlWriteTag (fid, 'Matrix', attrlist);

data = reshape (data, [nr nc]);
data = data';

format=xmlGetPrecisionFormatString (precision);
form=format;
for i = 1:(nc-1)
  form = sprintf ('%s %s', form, format);
end
form = strcat (form, '\n');

fprintf (fid, form, data);

xmlWriteCloseTag (fid, 'Matrix');

clear attrlist form format nr nc;

