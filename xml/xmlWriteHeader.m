% Writes XML header information to a file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   result = xmlWriteHeader(fid)
%
% IN    fid   File descriptor of XML file

% 2002-12-13   Created by Oliver Lemke.

function result = xmlWriteHeader(fid)

fprintf (fid, '<?xml version="1.0"?>\n');

attrlist = xmlAddAttribute([], 'format', 'ascii');
attrlist = xmlAddAttribute(attrlist, 'version', '1');

xmlWriteTag(fid, 'arts', attrlist);

