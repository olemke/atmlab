% DIFF_ZA_AA   Takes the difference of zenith and azimuth angles
%
%   Takes the difference between a set of angles (za,aa) and a reference
%   direction (za0,aa0). That is, this function is the "inverse" of
%   *add_za_aa*.
%
% FORMAT   [dza,daa] = add_za_aa( za0, aa0, za, aa )
%
% OUT  dza    Derived difference(s) in zenith angle.
%      daa    Derived difference(s) in azimuth angle.
% IN   za0    Reference zenith angle. A scalar.
%      aa0    Reference azimuth angle. A scalar value.
%      za     Other zenith angle(s). Can be a vector or matrix.
%      aa     Other azimuth angle(s). Can be a vector or matrix.


function [dza,daa] = diff_za_aa( za0, aa0, za, aa )

    
% Check sizes
%    
si = size( za );
%    
assert( istensor0(za0) );
assert( istensor0(aa0) );
assert( all( size(aa) == si ) );

% Not all cases can be handled
%
if za0==0 | za0==180
  error( 'The case of *za0* = 0 or 180 is not handled.' );
end

% Flatten za and aa to rows
%
za = za(:)';
aa = aa(:)';

% Unit vector towards (za0,aa0)
%
[x,y,z] = zaaa2cart( za0, aa0 );

% Find vector around which rotation shall be performed to maintain aa
%  
% The vector is given by vrot = cross( [0 0 1], [x;y;z] );
% but it turns out that the result of this operation is just:
%
vrot = [-y,x,0];

% Unit vectors towards (za,aa)
%
[x,y,z] = zaaa2cart( za, aa );

% Apply rotation from (za,aa) towards (90,aa0)
%
u = rotationmat3D( -(za0-90)*pi/180, vrot ) * [x;y;z];

% Calculate za and aa for rotated u
%
[za,aa] = cart2zaaa( u(1,:), u(2,:), u(3,:) );

% Calculate dza and daa
%
dza = za - 90;
daa = aa - aa0;

% Reshape to original size
%
dza = reshape( dza, si );
daa = reshape( daa, si );

return


function [x,y,z] = zaaa2cart(za,aa)
  z = cosd( za );
  x = sind( za );
  y = sind( aa ) .* x;
  x = cosd( aa ) .* x;
return


function [za,aa] = cart2zaaa(x,y,z)
%  r = sqrt( x*x + y*y + z*z );
%  za = acosd( z ./ r );
  za = acosd( z );  
  aa = atan2d( y, x );
return