% Reads a Sparse from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadSparse(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     Sparse
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-06-16  Created by Mattias Ekström.

function result = xmlReadSparse(fid, attrlist, itype, ftype, binary, fid2)

nr = str2num (xmlGetAttrValue (attrlist, 'nrows'));
nc = str2num (xmlGetAttrValue (attrlist, 'ncols'));
nonz = str2num (xmlGetAttrValue (attrlist, 'nnz'));

if ~binary
  i = fscanf (fid, '%f', nonz)+1;
  j = fscanf (fid, '%f', nonz)+1;
  s = fscanf (fid, '%f', nonz);
else
  i = fread (fid2, nonz, itype)+1;
  j = fread (fid2, nonz, itype)+1;
  s = fread (fid2, nonz, ftype);
end
xmlCheckSize (nonz, size (i));
xmlCheckSize (nonz, size (j));
xmlCheckSize (nonz, size (s));

result = sparse (i, j, s, nr, nc, nonz);

