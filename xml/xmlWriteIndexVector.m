% Writes an Index Vector to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteIndexVector(fid, data)
%
% IN    fid    File descriptor
% IN    data   Index Vector
                                                                                                                               
% 2003-06-18  Created by Oliver Lemke.

function xmlWriteIndexVector(fid, data)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 & ncols ~=0 & nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

xmlWriteTag (fid, 'IndexVector', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%d\n', data);

xmlWriteCloseTag (fid, 'IndexVector');

clear fid nrows ncols nelem;

