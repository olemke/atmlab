% Reads a Numeric from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadNumeric(fid, attrlist)
%
% OUT   result     Numeric
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-12-13   Created by Oliver Lemke.

function result = xmlReadNumeric(fid, attrlist)

result = fscanf (fid, '%f', 1);

