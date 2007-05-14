% TROPOPAUSE   Determines the tropopause height 
%
%    The WMO definition of the tropopause: "The lowest level at which the lapse
%    rate decreases to 2 °C/km or less, provided that the average lapse rate
%    between this level and all higher levels within 2 km does not exceed 
%    2 °C/km."
%
%    This function tries to determine this altitude. 
%
%    The columns of *Z* and *T* are taken as profiles for different
%    locations. The optional arguments include an option to deviate from
%    the WMO limit of 2 K/km. A higher value could give more stable results
%    (for profiles with coarse altitude resolution?).
%
% FORMAT   z = tropopause(Z,T[,zmin,zmax,lrlim])
%        
% OUT   z       Row vector with tropopause heights.
% IN    Z       Altitude vectors.
%       T       Temperature profiles.
% OPT   zmin    Lowest possible altitude for tropopause. Default is 6 km.
%       zmax    Highest possible altitude for tropopause. Deafult is 20 km.
%       lrmlim  Lapre rate limit, in K/km. Default is 2 K/km, following WMO.

% 2007-03-01   Created by Patrick Eriksson


function z = tropopause(Z,T,zmin,zmax,lrlim)

  
%--- Default values
%
zmin_DEFAULT  = 6e3;
zmax_DEFAULT  = 20e3;
lrlim_DEFAULT = 2;
%
set_defaults;
  
 
if ~ismatrix(Z) | ~ismatrix(T)
  error( 'Both *Z* and *T* must be a matrix.' );  
end

if any( size(Z) ~= size(T) )
  error( 'Mismatch in size between *Z* and *T*.' );
end


np = size( Z, 2 );

z = repmat( NaN, 1, np );

for ip = 1:np

  for i = vec2row( find( Z(:,ip) >= zmin  &  Z(:,ip) < zmax ) )
    
    lr = 1e3*( T(i,ip) - T(i+1,ip) ) / ( Z(i+1,ip) - Z(i,ip) );
    
    if lr <= lrlim

      z0 = min( [ ( Z(i+1,ip) + Z(i,ip) ) / 2 zmax ] );
      t0 = ( T(i+1,ip) + T(i,ip) ) / 2;

      ind = find( Z(:,ip) > z0  &  Z(:,ip) <= z0+2e3 );

      if isempty(ind)  |  all(1e3*(t0-T(ind,ip))./(Z(ind,ip)-z0) < lrlim )
        z(ip) = z0;      
        break;
      end
    end
  end
end
