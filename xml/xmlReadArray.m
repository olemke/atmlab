% Reads an abitrary array from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    The array can contain any kind of data. For ArrayOfArray the function
%    calls itself recursively.
%
% FORMAT   result = xmlReadArray(fid, attrlist)
%
% OUT   result     Array
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-09-25   Created by Oliver Lemke.

function result = xmlReadArray(fid, attrlist)

ne = str2num (xmlGetAttrValue (attrlist, 'nelem'));

e = 0;
while e ~= ne
  e = e + 1;
  result{e} = xmlReadTag(fid);
end

