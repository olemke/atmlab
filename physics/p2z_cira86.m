% P2Z_CIRA86      Converts pressure to altitude and temperature
%
%                Converts pressure to altitude and temperature assuming cira86
%                climataology. Linear interpolation between log(pressure),
%                latitude, and day of year is performed.
%
% FORMAT   [Z,T] = p2z_cira86( P , LAT , DOY )
%        
% IN    P   pressure in pascal.
%           P can be a scalar or vector
%       LAT latitude
%           LAT can be a scalar or vector
%           defined from [-90 to 90]
%       DOY day of year 
%           DOY can be a scalar or vector
% OUT
%       Z   Altitude in meter, for all combinations of P, LAT, DOY 
%           Size is [np,nlat,ndoy]
%       T   Temperature in kelvin, for all combinations of Z, LAT, DOY 
%           Size is [nz,nlat,ndoy]

% 2007-11-01   Created by Bengt Rydberg

function [z,t]=p2z_cira86(p,lat,doy)

if any(doy)>367 | any(doy<0)
   error('doy is out of range')
end
if ~isempty(find(lat<-90)) | ~isempty(find(lat>90))
   error('latitude range is -90 to 90')
end


cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.z.xml' );

G = gfin_artsxml( clmtlgy_define, [], cira86 );

z = clmtlgy_interp( clmtlgy_define, G, p, lat, 0, doy );

if length(doy) > 1
  z = reshape( z, [size(z,1), size(z,2), size(z,4)] );
end

if nargout > 1
  cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.t.xml' );
  G = gfin_artsxml( clmtlgy_define, [], cira86 );
  t = clmtlgy_interp( clmtlgy_define, G, p, lat, 0, doy );
  if length(doy) > 1
    t = reshape( t, [size(t,1), size(t,2), size(t,4)] );
  end
end  