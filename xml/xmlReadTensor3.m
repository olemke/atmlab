% Reads a Tensor3 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadTensor3(fid, attrlist)
%
% OUT   result     Tensor3
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-10-18   Created by Oliver Lemke.

function result = xmlReadTensor3(fid, attrlist)

np = str2num (xmlGetAttrValue (attrlist, 'npages'));
nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nelem =  np * nr * nc;

result = fscanf (fid, '%f', nelem);
xmlCheckSize (nelem, size (result));

result = permute (reshape (result, [nc nr np]), [3 2 1]);

