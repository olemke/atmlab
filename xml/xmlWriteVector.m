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

nelem = size (data, 1);

xmlWriteTag (fid, 'Vector', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%f\n', data);

xmlWriteCloseTag (fid, 'Vector');

clear fid nelem;

