% Writes SparseData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSparseData(fid, data)
%
% IN    fid    File descriptor
% IN    data   SparseData
                                                                                                                               
% 2003-06-18  Created by Oliver Lemke.

function xmlWriteSparseData(fid, data)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 0 & ncols ~=0 & nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1 or both must be zero');
end

nelem = length (data);

xmlWriteTag (fid, 'SparseData', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%e\n', data);

xmlWriteCloseTag (fid, 'SparseData');

clear fid nrows ncols nelem;

