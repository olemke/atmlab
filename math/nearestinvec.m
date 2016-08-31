% [ind,zn] = nearestinvec(z,zi)
%
%    Find the nearest value in z to zi. Both z and zi can be of any size.
%
% FORMAT   [ind,zn] = nearestinvec(z,zi)
%
% OUT      ind  the index in vector z of closest value to zi
%          zn   the closest value in z to zi
% IN       z    search in this variable
%          zi   find closest match to this/these value(s)

% 2003-02-10   Created by Carlos Jimenez
% 2016-08-31   Extended to handle non-scalar zi, PE

function [ind,zn] = nearestinvec(z,zi);

[ind,zn] = deal( zeros( size(zi) ) );

for i = 1 : prod(size(zi))
  [ ~, ind(i) ] = min( abs( z - zi(i) ) );
  zn(i)         = z( ind(i) );
end
return





