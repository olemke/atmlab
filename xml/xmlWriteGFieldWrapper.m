% Writes a GField to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteGFieldWrapper(fid, data, precision, dim)
%
% IN    fid        File descriptor
% IN    data       GriddedField3
% IN    precision  Precision for floats

% 2008-07-02   Created by Oliver Lemke.

function xmlWriteGFieldWrapper(fid, data, precision, dim)

  attrlist = [];
  if (isfield(data, 'name'))
    attrlist = xmlAddAttribute ([], 'name', data.name);
  end
  xmlWriteTag (fid, ['GriddedField' sprintf('%d', dim)], attrlist);

  for i = 1:dim
    attrlist = xmlAddAttribute ([], 'name', data.gridnames{i});
    if (length(data.grids{i})~=0 && iscellstr(data.grids{i}(1)))
      xmlWriteArrayOf (fid, data.grids{i}, 'String', precision, attrlist);
    else
      xmlWriteVector (fid, data.grids{i}, precision, attrlist);
    end
  end

  switch dim
    case 1
      xmlWriteVector (fid, data.data, precision);
    case 2
      xmlWriteMatrix (fid, data.data, precision);
    case 3
      xmlWriteTensor3 (fid, data.data, precision);
    case 4
      xmlWriteTensor4 (fid, data.data, precision);
  end

  xmlWriteCloseTag (fid, ['GriddedField' sprintf('%d', dim)]);

