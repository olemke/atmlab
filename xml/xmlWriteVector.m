% Writes a Vector to an XML file.
%
%    Make sure that the argument you're passing has the correct type.
%
% FORMAT   xmlWriteVector(filename, data)
%
% IN    filename   Name of output file
% IN    data       Vector
                                                                                                                               
% 2002-12-13  Created by Oliver Lemke.

function xmlWriteVector(filename, data)

nelem = size (data, 1);

fid = xmlOpenOutputFile (filename);
xmlWriteHeader (fid);
xmlWriteTag (fid, 'Vector', ...
             xmlAddAttribute ([], 'nelem', sprintf ('%d', nelem)));

fprintf (fid, '%f\n', data);

xmlWriteCloseTag (fid, 'Vector');
xmlWriteFooter (fid);
fclose (fid);

clear fid nelem;

