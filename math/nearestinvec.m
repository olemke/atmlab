% [ind,zn] = nearestinvec(z,zi)
%
%          Find the nearest value in a vector z to a given value zi
%
% FORMAT   [ind,zn] = nearestinvec(z,zi)
%
% OUT      ind  the index in vector z of closest value to zi
%          zn   the closest value in z to zi
% IN       z    the vector
%          zi   the value

% 2003-02-10   Created by Carlos Jimenez

function [ind,zn] = nearestinvec(z,zi);


%= sorting vector form smallest to largest
%
if z(1) > last(z)
  do_sort = 1;
else
  do_sort = 0; 
end

if do_sort
 z = sort(z);
end

%= finding nearest value
%
indl = find(z <= zi);
if ~isempty(indl)
  dl = zi - z(last(indl));
end
indu = find( z >= zi );
if ~isempty(indu)
  du = z(indu(1))-zi;
end
if ~isempty(indl) &  ~isempty(indu)
  if dl <= du
    ind = last(indl);
  else
    ind = indu(1);
  end
elseif ~isempty(indl)
    ind = last(indl);
elseif ~isempty(indu)
    ind = indu(1);
else
  ind = [];
end

if ~isempty(ind)
  zn  = z(ind);
else
  zn = [];
end  


if do_sort
  ind = 1 + length(z) - ind;
end

return




