% ARTS_PTYPE2STRING   Converts ptype number to string
%
%    The version is reported as a short string. Complete information can be
%    printed on the screen.
%
% FORMAT   s = arts_ptype2string( ptype )
%        
% IN    ptype     Number identifying the ptype (10, 20, 30)
% OUT   s         The string identifier for this ptype

% 2014-09-29   Created by Oliver Lemke.

function s = arts_ptype2string( ptype )

switch ptype
    case 10
        s = 'general';
    case 20
        s = 'macroscopically_isotropic';
    case 30
        s = 'spherical';
    otherwise
        error(['atmlab:' mfilename], ...
            ['Unknown ptype ' num2str(ptype)]);
end
