% Writes a Vector to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteVector(fid, data)
%
% IN    fid    File descriptor
% IN    data   Vector
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteVector(fid, data)

nrows = size (data, 1);
ncols = size (data, 2);

if nrows ~= 1 & ncols ~= 1
  error ('Either columns or rows must have size 1');
end

nelem = length (data);

xmlWriteTag (fid, 'Vector', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%e\n', data);

xmlWriteCloseTag (fid, 'Vector');

clear fid nrows ncols nelem;

