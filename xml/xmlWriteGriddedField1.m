% Writes a GriddedField1 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGriddedField1(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       GriddedField1
% IN    precision  Precision for floats

% 2008-07-02   Created by Oliver Lemke.

function xmlWriteGriddedField1(fid, data, precision)

  xmlWriteGFieldWrapper (fid, data, precision, 1);

