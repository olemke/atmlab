% Writes an Index to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteIndex(fid, data)
%
% IN    fid        File descriptor
% IN    data       Index
% IN    precision  Precision for floats

% 2002-12-17  Created by Oliver Lemke.

function xmlWriteIndex(fid, data, precision)

xmlWriteTag (fid, 'Index', []);

fprintf (fid, '%d\n', data);

xmlWriteCloseTag (fid, 'Index');

