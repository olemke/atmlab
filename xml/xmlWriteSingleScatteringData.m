% Writes SingleScatteringData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSingleScatteringData(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       SingleScatteringData
% IN    precision  Precision for floats

% 2005-03-15   Created by Oliver Lemke.

function xmlWriteSingleScatteringData(fid, data, precision)

xmlWriteTag (fid, 'SingleScatteringData', []);

xmlWriteIndex (fid, data.ptype, precision);
xmlWriteString (fid, data.description, precision);
xmlWriteVector (fid, data.f_grid, precision);
xmlWriteVector (fid, data.T_grid, precision);
xmlWriteVector (fid, data.za_grid, precision);
xmlWriteVector (fid, data.aa_grid, precision);
xmlWriteTensor7 (fid, data.pha_mat_data, precision);
xmlWriteTensor5 (fid, data.ext_mat_data, precision);
xmlWriteTensor5 (fid, data.abs_vec_data, precision);

xmlWriteCloseTag (fid, 'SingleScatteringData');

