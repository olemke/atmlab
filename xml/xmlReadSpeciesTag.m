% Reads a SpeciesTag from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadSpeciesTag(fid, attrlist)
%
% OUT   result     SpeciesTag
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
                                                                                                                               
% 2002-12-13   Created by Oliver Lemke.

function result = xmlReadSpeciesTag(fid, attrlist)

c = fgets (fid, 1);
while ~feof (fid) & (c == 10 | c == 32)
  c = fgets (fid, 1);
end

if c ~= '"'
  error (sprintf ('Invalid species tag: Not starting with "'));
end

result = '';
c = fgets (fid, 1);
while ~feof (fid) & c ~= '"'
  result = strcat (result, c);
  c = fgets (fid, 1);
end

if c ~= '"'
  error (sprintf ('Invalid species tag: Not ending with "'));
end


