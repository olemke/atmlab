% SIMPLECLOUD_GET   Returns ice and water content at a single position.
%
%    Returns the content of ice, liquid water and rain for the given
%    geographical position and the defined cloud scenario (described 
%    by SIMPLECLOUD_INIT).
%    
%    Latitude and longitude must be given for 3D cases.
%
%    This function is not "vectorized", to faciliate porting to
%    to C or FORTRAN. This function is then slow.
%     
% FORMAT   [iwc,lwc,rain] = simplecloud_get(C,z[,lat,lon])
%
% OUT      iwc    Ice water content [g/m3]
%          lwc    Liquid water content [g/m3]
%          rain   Rain rate [mm/h]    
% IN       C      Settings from SIMPLECLOUD_INIT.
%          z      Altitude [m]
%          lat    Latitude [-90,90]
%          lon    Longitude [-180,180]

% HISTORY: 2003-03-07  Created by Patrick Eriksson


function [iwc,lwc,rain] = simplecloud_get(C,z,lat,lon)


if C.dim == 3  &  nargin < 4
  error('Latitude and longitude must be given for 3D.');
end

iwc  = 0;
lwc  = 0;
rain = 0;


%=== Vertical dimension
%
if C.do_iwc
  nz = size( C.iwc, 1 );
  if z > C.iwc(1,1) & z < C.iwc(nz,1)
    iwc = interp1( C.iwc(:,1), C.iwc(:,2), z );
  end
end
%
if C.do_lwc
  nz = size( C.lwc, 1 );
  if z > C.lwc(1,1)  &  z < C.lwc(nz,1)
    lwc = interp1( C.lwc(:,1), C.lwc(:,2), z );
  end
end
%
if C.do_rain
  nz = size( C.rain, 1 );
  if z < C.rain(nz,1)
    if z <= C.rain(1,1)
      rain = C.rain(1,2);
    else
      rain = interp1( C.rain(:,1), C.rain(:,2), z );
    end
  end
end



%=== Horisontal dimension
%
if C.dim == 3

  llat = 111e3 * abs( C.lat - lat );   % 111e3 = 60 nautical mile
  llon = 111e3 * abs( C.lon - lon ) * cos( pi*C.lat/180);
  hw   = 0;

  if C.hshape == 1
    if llat < (C.latlength/2+C.hedge)  &  llon < (C.lonlength/2+C.hedge)
      if llat <= C.latlength/2  &  llon <= C.lonlength/2
        hw = 1;
      elseif llat <= C.latlength/2
        hw = 1 - ( llon - C.lonlength/2 ) / C.hedge;
      elseif llon <= C.lonlength/2
        hw = 1 - ( llat - C.latlength/2 ) / C.hedge;
      else
        hw = 1 - max( [ ( llat - C.latlength/2 ) / C.hedge, ...
                                        ( llon - C.lonlength/2 ) / C.hedge ] );
      end
    end
  else
    hw = exp( -( (2*llat/C.latlength)^2 + (2*llon/C.lonlength)^2 ) );
  end

  iwc  = iwc * hw;
  lwc  = lwc * hw;
  rain = rain * hw;
  
end