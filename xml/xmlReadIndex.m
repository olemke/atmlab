% Reads a Index from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadIndex(fid, attrlist)
%
% OUT   result     Index
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-12-13   Created by Oliver Lemke.

function result = xmlReadIndex(fid, attrlist)

result = fscanf (fid, '%d', 1);

