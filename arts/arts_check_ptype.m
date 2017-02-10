% ARTS_CHECK_PTYPE   Validate ptype string
%
% FORMAT   s = arts_check_ptype( ptype, version )
%        
% IN    ptype        String with ptype
% IN    version      Version number of SingleScatteringData
% OUT   valid_ptype  True if the ptype is valid, otherwise False

% 2017-02-10   Created by Oliver Lemke.

function valid_ptype = arts_check_ptype( ptype, version )

if version == 2
    valid_particle_types = { 'general', 'macroscopically_isotropic', ...
        'horizontally_aligned' };
elseif version == 3
    valid_particle_types = { 'general', 'totally_random', ...
        'azimuthally_random' };
else
    error(['atmlab:' mfilename], ...
        ['Unsupported SingleScatteringData version: ' num2str(ptype)]);
end

valid_ptype = any( ismember( valid_particle_types, ptype ) );
