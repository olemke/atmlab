% Reads a Tensor5 from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadTensor5(fid, attrlist)
%
% OUT   result     Tensor5
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-10-18   Created by Oliver Lemke.

function result = xmlReadTensor5(fid, attrlist)

ns = str2num (xmlGetAttrValue (attrlist, 'nshelves'));
nb = str2num (xmlGetAttrValue (attrlist, 'nbooks'));
np = str2num (xmlGetAttrValue (attrlist, 'npages'));
nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nelem =  ns * nb * np * nr * nc;

result = fscanf (fid, '%f', nelem);
xmlCheckSize (nelem, size (result));

result = permute (reshape (result, [nc nr np nb ns]), [5 4 3 2 1]);

