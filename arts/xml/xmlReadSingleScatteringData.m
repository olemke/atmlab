% Reads a SingleScatteringData table from an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
%    Calls *xmlReadTag* for every member of the SingleScatteringData structure.
%
% FORMAT   result = xmlReadSingleScatteringData(fid, attrlist, itype, ftype, binary, fid2)
%
% OUT   result     SingleScatteringData
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2003-11-18   Created by Oliver Lemke.

function result = xmlReadSingleScatteringData(fid, attrlist, itype, ftype, binary, fid2)

vstr = xmlGetAttrValue (attrlist, 'version');
if isempty(vstr)
    result.version = 1;
else
    result.version = str2double(vstr);
end

result.ptype            = xmlReadTag(fid, '', itype, ftype, binary, fid2);

% Version 1 can be directly converted into version 2
if (result.version == 1)
    result.version = 2;
    result.ptype = arts_ptype2string(result.ptype, result.version);
end

if ~arts_check_ptype(result.ptype, result.version)
    error('atmlab:xmlWriteScatteringMetaData:IllegalParticleType', ...
        ['Illegal particle_type ' result.ptype '\n' ...
        'Valid types for version 3: general, totally_random, azimuthally_random\n' ...
        'Valid types for version 2: general, macroscopically_isotropic, horizontally_aligned'])
end

% Non-azimuthally random data can be converted directly to version 3
if result.version == 2 && ~strcmp(result.ptype, 'horizontally_aligned')
    result.version = 3;
    result.ptype = arts_update_ptype(result.ptype);
end

result.description      = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.f_grid           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.T_grid           = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.za_grid          = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.aa_grid          = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.pha_mat_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.ext_mat_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);
result.abs_vec_data     = xmlReadTag(fid, '', itype, ftype, binary, fid2);

