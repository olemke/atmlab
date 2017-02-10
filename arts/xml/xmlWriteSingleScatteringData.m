% Writes SingleScatteringData to an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlStore* instead.
%
% FORMAT   xmlWriteSingleScatteringData(fid, fidb, data, precision)
%
% IN    fid        File descriptor
% IN    fidb       File descriptor for binary file
% IN    data       SingleScatteringData
% IN    precision  Precision for floats

% 2005-03-15   Created by Oliver Lemke.

function xmlWriteSingleScatteringData(fid, fidb, data, precision)

if ~isfield(data, 'version')
    error(['atmlab:' mfilename], ...
        'SingleScatteringData variable must contain a version number');
end

if data.version ~= 2 && data.version ~= 3
    error(['atmlab:' mfilename], ...
        ['Unsupported SingleScatteringData version: ' num2str(data.version)]);
end

if isnumeric(data.ptype)
    data.ptype = arts_ptype2string(data.ptype, data.version);
else
    if ~arts_check_ptype(data.ptype, data.version)
        error('atmlab:xmlWriteScatteringMetaData:IllegalParticleType', ...
            ['Illegal particle_type ' data.ptype '\n' ...
            'Valid types for version 3: general, totally_random, azimuthally_random\n' ...
            'Valid types for version 2: general, macroscopically_isotropic, horizontally_aligned'])
    end
end

% Non-azimuthally random data can be converted directly to version 3
if data.version == 2 && ~strcmp(data.ptype, 'horizontally_aligned')
    data.version = 3;
    data.ptype = arts_update_ptype(data.ptype);
end

xmlWriteTag (fid, 'SingleScatteringData', xmlAddAttribute([], 'version', num2str(data.version)));

xmlWriteString (fid, fidb, data.ptype, precision);
xmlWriteString (fid, fidb, data.description, precision);
xmlWriteVector (fid, fidb, data.f_grid, precision);
xmlWriteVector (fid, fidb, data.T_grid, precision);
xmlWriteVector (fid, fidb, data.za_grid, precision);
xmlWriteVector (fid, fidb, data.aa_grid, precision);
xmlWriteTensor7 (fid, fidb, data.pha_mat_data, precision);
xmlWriteTensor5 (fid, fidb, data.ext_mat_data, precision);
xmlWriteTensor5 (fid, fidb, data.abs_vec_data, precision);

xmlWriteCloseTag (fid, 'SingleScatteringData');

