% Reads a Matrix from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadMatrix(fid, attrlist)
%
% OUT   result     Matrix
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-09-25  Created by Oliver Lemke.

function result = xmlReadMatrix(fid, attrlist)

nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nelem = nr * nc;

result = fscanf (fid, '%f', nelem);
xmlCheckSize (nelem, size (result));

result = reshape (result, [nc nr]);
result = result';

