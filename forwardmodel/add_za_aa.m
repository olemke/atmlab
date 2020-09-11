% ADD_ZA_AA   Adds zenith and azimuth angles
%
%   Adds (dza,daa) to (za0,aa0), assuming that a unit changes in za and aa
%   are equal where (dza,daa)=(0,0). 
%
% FORMAT   [za,aa] = add_za_aa( za0, aa0, dza, daa )
%
% OUT  za     End zenith angle(s).
%      aa     End azimuth angle(s).
% IN   za0    Start zenith angle. A scalar value.
%      aa0    Start azimuth angle. A scalar value.
%      dza    Change in zenith angle. Can be a vector or matrix.
%      daa    Change in azimuth angle. Can be a vector or matrix.

% 2018-12-17 Patrick Eriksson

function [za,aa] = add_za_aa( za0, aa0, dza, daa )

    
% Check sizes
%    
si = size( dza );
%    
assert( istensor0(za0) );
assert( istensor0(aa0) );
assert( all( size(daa) == si ) );

% Flatten dza and daa to rows
%
dza = dza(:)';
daa = daa(:)';

% Unit vector towards aa0 at za=90
%
[x,y,z] = zaaa2cart( 90, aa0 );
  
% Find vector around which rotation shall be performed to maintain aa
%  
% The vector is given by vrot = cross( [0 0 1], [x;y;z] );
% but it turns out that the result of this operation is just:
%
vrot = [-y,x,0];

% Unit vectors towards (dza,daa) around (90,aa0)
%
[x,y,z] = zaaa2cart( 90+dza, aa0 + daa );

% Apply rotation
%
u = rotationmat3D( (za0-90)*pi/180, vrot ) * [x;y;z];

% Calculate za and aa for rotated u
%
[za,aa] = cart2zaaa( u(1,:), u(2,:), u(3,:) );

% Reshape to original size
%
za = reshape( za, si );
aa = reshape( aa, si );

