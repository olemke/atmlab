% Z2P_CIRA86      Converts altitude to pressure and temperature
%
%                Converts altitude to pressure and temperature assuming cira86
%                climataology. Linear interpolation between
%                log(pressure), altitude, latitude, and day of year is performed.
%
% FORMAT   [P,T] = z2p_cira86( Z , LAT , DOY )
%        
% IN    Z   altitude in meters.
%           Z can be a scalar or vector
%       LAT latitude
%           LAT can be a scalar or vector
%           defined from [-90 to 90]
%       DOY day of year 
%           DOY can be a scalar or vector
% OUT
%       P   Pressure in pascal, for all combinations of Z, LAT, DOY 
%           Size is [nz,nlat,ndoy]
%       T   Temperature in kelvin, for all combinations of Z, LAT, DOY 
%           Size is [nz,nlat,ndoy]

% 2007-11-01   Created by Bengt Rydberg

function [p,t]=z2p_cira86(z,lat,doy)
 
if any(doy)>367 | any(doy<0)
   error('doy is out of range')
end
if ~isempty(find(lat<-90)) | ~isempty(find(lat>90))
   error('latitude range is -90 to 90')
end


cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.z.xml' );
G    = gfin_artsxml( clmtlgy_define, [], cira86 );
Z    = clmtlgy_interp( clmtlgy_define, G, G.GRID1, lat, 0, doy );
p    = zeros( length(z), size(Z,2), size(Z,4) );
logp = log( G.GRID1 );

if nargout > 1
  cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.t.xml' );
  G    = gfin_artsxml( clmtlgy_define, [], cira86 );
  T    = clmtlgy_interp( clmtlgy_define, G, G.GRID1, lat, 0, doy );
  t    = zeros( length(z), size(Z,2), size(Z,4) );
end

for ilat = 1 : size(Z,2)
  for idoy = 1 : size(Z,4)
    if nargout == 1
      p(:,ilat,idoy) = exp( interp1( Z(:,ilat,1,idoy), logp, z ) );  
    else
      pnew           = interp1( Z(:,ilat,1,idoy), logp, z );  
      t(:,ilat,idoy) = interp1( logp, T(:,ilat,1,idoy), pnew );  
      p(:,ilat,idoy) = exp( pnew );  
    end
  end
end



