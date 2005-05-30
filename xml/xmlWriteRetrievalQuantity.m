% Writes a RetrievalQuantity to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteRetrievalQuantity(fid, data, precision)
%
% IN    fid        File descriptor
% IN    data       RetrievalQuantity
% IN    precision  Precision for floats

% 2005-05-30   Created by Mattias Ekstrom.

function xmlWriteRetrievalQuantity(fid, data, precision)

xmlWriteTag (fid, 'RetrievalQuantity', []);

xmlWriteString (fid, data.maintag, precision);
xmlWriteString (fid, data.subtag, precision);
xmlWriteString (fid, data.unit, precision);
xmlWriteIndex (fid, data.method, precision);
xmlWriteNumeric (fid, data.perturbation, precision);
xmlWriteArrayOf (fid, data.grids, 'Vector', precision);
% Convert back to cell and 0-based indexing
ji = mat2cell(data.jacobian_indices-1,[[] 1],[1 1]);
xmlWriteArrayOf (fid, ji, 'Index', precision);

xmlWriteCloseTag (fid, 'RetrievalQuantity');

