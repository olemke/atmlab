% Writes a GridPos to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGridPos(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       GridPos
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWriteGridPos(fid, data, precision)

xmlWriteTag (fid, 'GridPos', []);

xmlWriteIndex (fid, data.idx, precision);
xmlWriteNumeric (fid, data.fd(1), precision);
xmlWriteNumeric (fid, data.fd(2), precision);

xmlWriteCloseTag (fid, 'GridPos');

