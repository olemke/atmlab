% FRESNEL_MUELLER   Mueller matrix for specular reflection
%
%    This function calculates the Fresnel reflection coefficient and
%    compiles the corresponding Mueller matrix.
%
%    The Fresnel coefficients are calculated by fresnel.m, and see that
%    function for further information.
%
%    The structure of the Muller matrix follows the implementation in ARTS
%    (found in surface.cc). This part os documented in the ARTS theory
%    document. 
%    
% FORMAT   M = fresnel(n1,n2,theta1,stokes_dim)
%        
% OUT   M           Mueller matrix.
%       
% IN    n1          Refractive index for medium of incoming radiation.
%       n2          Refractive index for reflecting medium.
%       theta1      Angle between surface normal and incoming radiation.
%       stokes_dim  Stokes dimension, 1, 2 , 3 or 4.

% 2014-11-18   Created by Patrick Eriksson.

function M = fresnel_mueller(n1,n2,theta1,stokes_dim)
%
if atmlab( 'STRICT_ASSERT' )
  rqre_nargin( 4, nargin );
  rqre_datatype( stokes_dim, @iswhole );
  rqre_in_range( stokes_dim, 1, 4 );
  % Other variables are checked in fresnel.m
end

% V and H amplitude complex reflection values
[Rv,Rh] = fresnel( n1, n2, theta1 );

% Corresponding power values
rv    = power( abs(Rv), 2 );
rh    = power( abs(Rh), 2 );
rmean = ( rv + rh ) / 2;

% Init M
M      = zeros( stokes_dim,stokes_dim );

% Fill M
%
M(1,1) = rmean;
%
if( stokes_dim > 1 )
  
  rdiff = ( rv - rh ) / 2;

  M(2,1) = rdiff;
  M(1,2) = rdiff;
  M(2,2) = rmean;

  if( stokes_dim > 2 )

    a = Rh * conj(Rv);
    b = Rv * conj(Rh);
    c = ( a + b ) / 2.0;  

    M(3,3) = c;
      
    if( stokes_dim > 3 )

      M(3,4) = imag( a - b ) / 2.0;
      M(4,3) = -M(3,4);
      M(4,4) = c;
    
    end
  end
end

  