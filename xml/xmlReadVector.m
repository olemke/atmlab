% Reads a Vector from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadVector(fid, attrlist)
%
% OUT   result     Vector
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-11-14   Created by Oliver Lemke.

function result = xmlReadVector(fid, attrlist)

nr = str2num (xmlGetAttrValue (attrlist, 'nelem'));

result = fscanf (fid, '%f', nr);
xmlCheckSize (nr, size (result));

