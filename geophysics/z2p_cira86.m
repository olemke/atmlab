% Z2P_CIRA86    Converts altitude to pressure and temperature
%
%    Converts altitude to pressure and temperature assuming cira86
%    climataology. Linear interpolation between log(pressure),
%    latitude, and day of year is performed.
%
% FORMAT   [P,T] = p2z_cira86( Z , LAT , DOY )
%        
% OUT   P     Pressure in pascal, for all combinations of Z, LAT, DOY 
%             Size is [np,nlat,ndoy]
%       T     Temperature in kelvin, for all combinations of Z, LAT, DOY 
%             Size is [nz,nlat,ndoy]
% IN    Z     Altitude in meter. Can be a scalar or column vector
%       LAT   Latitude. Can be a scalar or column vector [-90 to 90].
%       DOY   Day of year. Can be a scalar or column vector

% 2007-11-01   Created by Bengt Rydberg

function [p,t]=z2p_cira86(z,lat,doy)
                                                                   %&%
rqre_datatype( z, @istensor1 );                                    %&%
rqre_datatype( lat, @istensor1 );                                  %&%
rqre_datatype( doy, @istensor1 );                                  %&%
if any(doy)>367 || any(doy<1)                                      %&%
  error(['atmlab:' mfilename],'doy range is [1,367]')              %&%
end                                                                %&%
if any(lat)>90 || any(lat<-90)                                     %&%
   error(['atmlab:' mfilename],'latitude range is -90 to 90')      %&%
end                                                                %&%

% Create a a mjd matching the given doy (ie. the inverse of mjd2doy)
mjd = date2mjd( 2000, 1, 1, 0, 0, 0 ) + doy - 1;

cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.z.xml' );

G    = gf_artsxml( cira86, 'CIRA86', 'z_field' );
G    = atmdata_regrid( G, { G.GRID1, lat, 0, mjd } );
Z    = G.DATA;
p    = zeros( length(z), size(Z,2), size(Z,4) );
logp = log( G.GRID1 );


if nargout > 1
  cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.t.xml' );
  G = gf_artsxml( cira86, 'CIRA86', 't_field' );
  G = atmdata_regrid( G, { G.GRID1, lat, 0, mjd } );
  T = G.DATA;
  t = zeros( length(z), size(T,2), size(T,4) );
end

for ilat = 1 : size(Z,2)
  for imjd = 1 : size(Z,4)
    if nargout < 2
      p(:,ilat,imjd) = exp( interp1( Z(:,ilat,1,imjd), logp, z ) );  
    else
      pnew           = interp1( Z(:,ilat,1,imjd), logp, z );  
      t(:,ilat,imjd) = interp1( logp, T(:,ilat,1,imjd), pnew );  
      p(:,ilat,imjd) = exp( pnew );  
    end
  end
end

