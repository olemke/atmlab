% Reads a GridPos from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the GridPos structure.
%
% FORMAT   result = xmlReadGridPos(fid, attrlist)
%
% OUT   result     GridPos
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2003-01-09   Created by Oliver Lemke.

function result = xmlReadGridPos(fid, attrlist)

  result.idx   = xmlReadTag(fid);
  fd1 = xmlReadTag(fid);
  fd2 = xmlReadTag(fid);

  result.fd = [fd1 fd2];

  clear fd1 fd2;
