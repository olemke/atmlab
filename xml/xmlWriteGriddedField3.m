% Writes a GriddedField3 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGriddedField3(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       GriddedField3
% IN    precision  Precision for floats

% 2004-02-20   Created by Oliver Lemke.

function xmlWriteGriddedField3(fid, data, precision)

xmlWriteTag (fid, 'GriddedField3', []);

xmlWriteVector (fid, data.p_grid, precision);
xmlWriteVector (fid, data.lat_grid, precision);
xmlWriteVector (fid, data.lon_grid, precision);
xmlWriteTensor3 (fid, data.data, precision);

xmlWriteCloseTag (fid, 'GriddedField3');

