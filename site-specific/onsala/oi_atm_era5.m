% Sets the atmosphere based on ERA5, CIRA86 and Fascod MLW
%
%   A has fields: p, z, t, n2, o2, h2o, o3, and co
%
% FORMAT A = oi_atm_era5(P,mjd)
%
% OUT  A        Atmosphere data structure
% IN   P        Project settings structure
%      mjd      Modified Julian date

% 2021-02-22 Patrick Eriksson


function A = oi_atm_era5(P,mjd)


%- Get year and doy
%
year = mjd2date( mjd );
doy  = mjd2doy( mjd );


%- Read ERA5 data
%
zipfile = fullfile( P.era5folder, sprintf( '%d_%03.0f_12.zip', year, doy ) );
%
wfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( wfolder ) );
%
unzip( zipfile, wfolder );
%
Ae.p   = xmlLoad( fullfile( wfolder, 'p_grid.xml' ) );
Ae.z   = xmlLoad( fullfile( wfolder, 'z_field.xml' ) );
Ae.t   = xmlLoad( fullfile( wfolder, 't_field.xml' ) );
Ae.vmr = xmlLoad( fullfile( wfolder, 'vmr_field.xml' ) );


%- CIRA86 (extended to negative altitudes)
%
z86 = (0 : 2e3 : 100e3 )';
[p86,t86] = z2p_cira86( z86, 57+23/60, doy );
%
p86 = [1100e2;p86];
t86 = [t86(1);t86];
z86 = [-500;z86];
%
z86(1:2) = pt2z( p86(1:2), t86(1:2), repmat(0.005,2,1), p86(2), z86(2) ); 


%- Use Fascode as help to set gases
%
Af = oi_atm_fascode( 'mlw' );


%- Create final A
%
A.p = p86;
%
% Find weight for CIRA86 inside altitude covered by ERA5
b1  = 35e3;
b2  = Ae.z(end);
ind = find( z86 < b2 );
w   = linear_transition( b1, b2, z86(ind) );
%
% Temperature
A.t = t86;
A.t(ind) = w .* A.t(ind) + (1-w) .* interpp( Ae.p, Ae.t, A.p(ind) );
%
% Altitudes
A.z = z86;
A.z(ind) = w .* A.z(ind) + (1-w) .* interpp( Ae.p, Ae.z, A.p(ind) );
%
% H2O
A.h2o = interpp( Af.p, Af.h2o, A.p );
A.h2o(ind) = w .* A.h2o(ind) + (1-w) .* interpp( Ae.p, Ae.vmr(3,:)', A.p(ind));
%
% O3
A.o3 = interpp( Af.p, Af.o3, A.p );
A.o3(ind) = w .* A.o3(ind) + (1-w) .* interpp( Ae.p, Ae.vmr(4,:)', A.p(ind));


%- Other gases are taken directly from Fascod
%
A.n2 = interpp( Af.p, Af.n2, A.p );
A.o2 = interpp( Af.p, Af.o2, A.p );
A.co = interpp( Af.p, Af.co, A.p );



