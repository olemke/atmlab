% Writes an RowIndex vector to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteRowIndex(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       Index Vector
% IN    precision  Precision for floats

% 2003-06-18  Created by Oliver Lemke.

function xmlWriteIndexVector(fid, data, precision)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 & ncols ~=0 & nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

xmlWriteTag (fid, 'RowIndex', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%d\n', data);

xmlWriteCloseTag (fid, 'RowIndex');

clear fid nrows ncols nelem;

