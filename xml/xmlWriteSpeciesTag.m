% Writes a SpeciesTag to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   result = xmlWriteSpeciesTag(fid, data)
%
% IN    fid    File descriptor of XML file
% IN    data   SpeciesTag
                                                                                                                               
% 2002-12-17   Created by Oliver Lemke.

function result = xmlWriteSpeciesTag(fid, data)

xmlWriteTag (fid, 'SpeciesTag', []);
fprintf (fid, '"%s"\n', data);
xmlWriteCloseTag (fid, 'SpeciesTag');

