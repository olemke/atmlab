% Writes a Ppath to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWritePpath(fid, data)
%
% IN    fid    File descriptor
% IN    data   Ppath
                                                                                                                               
% 2003-01-09  Created by Oliver Lemke.

function xmlWritePpath(fid, data)

xmlWriteTag (fid, 'Ppath', []);

xmlWriteIndex (fid, data.dim);
xmlWriteIndex (fid, data.np);
xmlWriteIndex (fid, data.refraction);
xmlWriteString (fid, data.method);
xmlWriteNumeric (fid, data.constant);
xmlWriteMatrix (fid, data.pos);
xmlWriteVector (fid, data.z);
xmlWriteVector (fid, data.l_step);
xmlWriteArrayOf (fid, data.gp_p, 'GridPos');
xmlWriteArrayOf (fid, data.gp_lat, 'GridPos');
xmlWriteArrayOf (fid, data.gp_lon, 'GridPos');
xmlWriteMatrix (fid, data.los);
xmlWriteString (fid, data.background);
xmlWriteVector (fid, data.tan_pos);
xmlWriteVector (fid, data.geom_tan_pos);

xmlWriteCloseTag (fid, 'Ppath');

