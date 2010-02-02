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
xmlWriteString (fid, data.mode, precision);
xmlWriteIndex (fid, data.analytical, precision);
xmlWriteNumeric (fid, data.perturbation, precision);
xmlWriteArrayOf (fid, data.grids, 'Vector', precision);

xmlWriteCloseTag (fid, 'RetrievalQuantity');

