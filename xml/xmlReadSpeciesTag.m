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

%=== Validate XML file header
result = fscanf (fid, '%s', 1);

if result (1) ~= '"'
  error (sprintf ('Invalid species tag: Expected " but got %s', s(1)));
end

limit = 255;
result = fscanf (fid, '%s', 1);
while limit & result(length (result)) ~= '"'
  result = strcat (result, fscanf (fid, '%s', 1));
  limit = limit - 1
end

if result (length (result)) ~= '"' | ~limit
  error (sprintf ('Invalid species tag: Not terminated with "'));
end

result = result (1:length (result) - 1);

