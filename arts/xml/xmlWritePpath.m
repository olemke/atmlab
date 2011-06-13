% Writes a Ppath to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWritePpath(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       Ppath
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWritePpath(fid, fidb, data, precision)

xmlWriteTag (fid, 'Ppath', []);

xmlWriteIndex (fid, fidb, data.dim, precision);
xmlWriteIndex (fid, fidb, data.np, precision);
xmlWriteNumeric (fid, fidb, data.constant, precision);
xmlWriteMatrix (fid, fidb, data.pos, precision);
xmlWriteVector (fid, fidb, data.z, precision);
xmlWriteVector (fid, fidb, data.l_step, precision);
xmlWriteArrayOf (fid, fidb, data.gp_p, 'GridPos', precision);
xmlWriteArrayOf (fid, fidb, data.gp_lat, 'GridPos', precision);
xmlWriteArrayOf (fid, fidb, data.gp_lon, 'GridPos', precision);
xmlWriteMatrix (fid, fidb, data.los, precision);
xmlWriteString (fid, fidb, data.background, precision);
xmlWriteVector (fid, fidb, data.tan_pos, precision);
xmlWriteVector (fid, fidb, data.geom_tan_pos, precision);
xmlWriteVector (fid, fidb, data.nreal, precision);

xmlWriteCloseTag (fid, 'Ppath');

