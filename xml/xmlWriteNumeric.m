% Writes a Numeric to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteNumeric(fid, data)
%
% IN    fid    File descriptor
% IN    data   Numeric
                                                                                                                               
% 2002-12-17  Created by Oliver Lemke.

function xmlWriteNumeric(fid, data)

xmlWriteTag (fid, 'Numeric', []);

fprintf (fid, '%e\n', data);

xmlWriteCloseTag (fid, 'Numeric');

