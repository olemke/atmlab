% Writes a Ppath to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWritePpath(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       Ppath
% IN    precision  Precision for floats

% 2003-01-09  Created by Oliver Lemke.

function xmlWritePpath(fid, data, precision)

xmlWriteTag (fid, 'Ppath', []);

xmlWriteIndex (fid, data.dim, precision);
xmlWriteIndex (fid, data.np, precision);
xmlWriteIndex (fid, data.refraction, precision);
xmlWriteString (fid, data.method, precision);
xmlWriteNumeric (fid, data.constant, precision);
xmlWriteMatrix (fid, data.pos, precision);
xmlWriteVector (fid, data.z, precision);
xmlWriteVector (fid, data.l_step, precision);
xmlWriteArrayOf (fid, data.gp_p, 'GridPos', precision);
xmlWriteArrayOf (fid, data.gp_lat, 'GridPos', precision);
xmlWriteArrayOf (fid, data.gp_lon, 'GridPos', precision);
xmlWriteMatrix (fid, data.los, precision);
xmlWriteString (fid, data.background, precision);
xmlWriteVector (fid, data.tan_pos, precision);
xmlWriteVector (fid, data.geom_tan_pos, precision);

xmlWriteCloseTag (fid, 'Ppath');

