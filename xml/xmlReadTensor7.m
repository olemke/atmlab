% Reads a Tensor7 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadTensor7(fid, attrlist)
%
% OUT   result     Tensor7
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-10-18   Created by Oliver Lemke.

function result = xmlReadTensor7(fid, attrlist)

nl = str2num (xmlGetAttrValue (attrlist, 'nlibraries'));
nv = str2num (xmlGetAttrValue (attrlist, 'nvitrines'));
ns = str2num (xmlGetAttrValue (attrlist, 'nshelves'));
nb = str2num (xmlGetAttrValue (attrlist, 'nbooks'));
np = str2num (xmlGetAttrValue (attrlist, 'npages'));
nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nelem =  nl * nv * ns * nb * np * nr * nc;

result = fscanf (fid, '%f', nelem);
xmlCheckSize (nelem, size (result));

result = permute (reshape (result, [nc nr np nb ns nv nl]), [7 6 5 4 3 2 1]);

