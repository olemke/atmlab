% ARTS_PTYPE2STRING   Converts ptype number to string
%
%    Converts the ptype number to the corresponding string.
%
% FORMAT   s = arts_ptype2string( ptype, version )
%        
% IN    ptype     Number identifying the ptype (10, 20, 30)
% IN    version   Version number of SingleScatteringData
% OUT   s         The string identifier for this ptype

% 2014-09-29   Created by Oliver Lemke.

function s = arts_ptype2string( ptype, version )

switch version
    case 2
        switch ptype
            case 10
                s = 'general';
            case 20
                s = 'macroscopically_isotropic';
            case 30
                s = 'horizontally_aligned';
            otherwise
                error(['atmlab:' mfilename], ...
                    ['Unknown ptype ' num2str(ptype)]);
        end
    case 3
        switch ptype
            case 10
                s = 'general';
            case 20
                s = 'totally_random';
            case 30
                s = 'azimuthally_random';
            otherwise
                error(['atmlab:' mfilename], ...
                    ['Unknown ptype ' num2str(ptype)]);
        end
    otherwise
        error(['atmlab:' mfilename], ...
            ['Unsupported SingleScatteringData version: ' num2str(version)]);
end
