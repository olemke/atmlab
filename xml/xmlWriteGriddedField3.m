% Writes a GriddedField3 to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGriddedField3(fid, data)
%
% IN    fid    File descriptor
% IN    data   GriddedField
                                                                                                                               
% 2004-02-20   Created by Oliver Lemke.

function xmlWriteGriddedField3(fid, data)

xmlWriteTag (fid, 'GriddedField3', []);

xmlWriteVector (fid, data.p_grid);
xmlWriteVector (fid, data.lat_grid);
xmlWriteVector (fid, data.lon_grid);
xmlWriteTensor3 (fid, data.data);

xmlWriteCloseTag (fid, 'GriddedField3');

