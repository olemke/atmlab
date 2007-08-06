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

% 2004-02-20   Created by Oliver Lemke.

function xmlWriteGriddedField4(fid, data, precision)

xmlWriteTag (fid, 'GriddedField4', []);

xmlWriteArrayOf (fid, data.field_names, 'String', precision);
xmlWriteVector (fid, data.p_grid, precision);
xmlWriteVector (fid, data.lat_grid, precision);
xmlWriteVector (fid, data.lon_grid, precision);
xmlWriteTensor4 (fid, data.data, precision);

xmlWriteCloseTag (fid, 'GriddedField4');

