% ARTS_UPDATE_PTYPE   Update particle type string
%
% Maps old ptype names to current version.
%
% FORMAT   new_ptype = arts_update_ptype( ptype )
%        
% IN    ptype      String with ptype
% OUT   new_ptype  Updated ptype name

% 2017-02-10   Created by Oliver Lemke.

function new_ptype = arts_update_ptype( ptype )

new_ptype = ptype;

if strcmp(ptype, 'macroscopically_isotropic')
    new_ptype = 'totally_random';
elseif strcmp(ptype, 'horizontally_aligned')
    new_ptype = 'azimuthally_random';
end
