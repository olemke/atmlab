% Writes a GridPos to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGridPos(fid, data)
%
% IN    fid    File descriptor
% IN    data   GridPos
                                                                                                                               
% 2003-01-09  Created by Oliver Lemke.

function xmlWriteGridPos(fid, data)

xmlWriteTag (fid, 'GridPos', []);

xmlWriteIndex (fid, data.idx);
xmlWriteNumeric (fid, data.fd(1));
xmlWriteNumeric (fid, data.fd(2));

xmlWriteCloseTag (fid, 'GridPos');

