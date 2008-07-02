% Writes a GriddedField4 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGriddedField4(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       GriddedField4
% IN    precision  Precision for floats

% 2008-07-02   Created by Oliver Lemke.

function xmlWriteGriddedField4(fid, data, precision)

  xmlWriteGFieldWrapper (fid, data, precision, 4);

