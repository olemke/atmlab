% Writes a String to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   result = xmlWriteString(fid, data)
%
% IN    fid    File descriptor of XML file
% IN    data   String
                                                                                                                               
% 2003-01-09   Created by Oliver Lemke.

function result = xmlWriteString(fid, data)

xmlWriteTag (fid, 'String', []);
fprintf (fid, '"%s"\n', data);
xmlWriteCloseTag (fid, 'String');

