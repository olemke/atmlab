% SIMPLECLOUD_FIELD   Extracts a full field for defined cloud scenario.
%
%    A function to create full fields for a defined simple cloud scenario.
%
%    The output follows the ARTS definitions. The dimension order is
%    [z,lat,lon]. 
%     
% FORMAT   [I,L,R] = simplecloud_field(C,z[,lat,lon]) 
%
% OUT      I     IWC field [g/m³].
%          L     LWC field [g/m³].
%          R     Rain rate field [mm/h].
% IN       C     Settings from SIMPLECLOUD_INIT.
%          lat   Latitude grid.
%          lon   Longitude grid.

% HISTORY: 2003-03-09  Created by Patrick Eriksson


function [I,L,R] = simplecloud_field(C,z,lat,lon) 


if C.dim == 1
  %
  nz = length(z);
  I  = zeros( nz, 1 );
  L  = zeros( nz, 1 );
  R  = zeros( nz, 1 );
  %
  for i = 1 : nz
    [I(i),L(i),R(i)] = simplecloud_get( C, z(i) );
  end

else
  %
  nz   = length(z);
  nlat = length(lat);
  nlon = length(lon);
  I  = zeros( nz, nlat, nlon );
  L  = zeros( nz, nlat, nlon );
  R  = zeros( nz, nlat, nlon );
  %
  for i = 1 : nz
    for j = 1 : nlat
      for k = 1 : nlon
        [I(i,j,k),L(i,j,k),R(i,j,k)] = ...
                                    simplecloud_get( C, z(i), lat(j), lon(k) );
      end
    end
  end

end
