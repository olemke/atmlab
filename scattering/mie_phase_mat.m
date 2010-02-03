%   Returns Mie phase matrix.
%
%
% FORMAT  [y]=mie_phase_mat(m,lambda,theta,r)
%
% OUT     y          Mie phase matrix size(r,theta,4,4)
%                    (y(1,:,1,1) is related to the phase function)
%                    (1/2*int_{0}^{pi}y(1,:,1,1)sin(theta)dtheta=y_sca/(4*pi)
%                    where y_sca is the scattering cross-section)
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         theta      scattering angle [radians], (vector)
%         r          particle radius [m] (vector)   
%
%
% History: 2010-02-02 Created by Bengt Rydberg

function [y]=mie_phase_mat(m,lambda,theta,r)



rqre_alltypes(r,{@isnumeric,@isvector})

rqre_alltypes(lambda,{@isnumeric,@isscalar})

rqre_alltypes(m,{@isnumeric,@isscalar})

rqre_alltypes(theta,{@isnumeric,@isvector})


if any( imag( m ) ) < 0
  error( 'Imaginary part of the refractive index is expected to be positive.' );
end
  
k=2*pi/lambda;
x=k*r;

y=zeros(length(r),length(theta),4,4);


%loop over particle sizes
for i=1:length(x)
  
    %loop over scattering angle
    for l=1:length(theta)
        u = cos(theta(l));
        S = mie_S12(m,x(i),u);
        S11 = 1/2 * ( abs(S(1))^2 + abs(S(2))^2 )/k^2;
        S12 = 1/2 * ( abs(S(2))^2 - abs(S(1))^2 )/k^2;
        S33 = 1/2 * ( S(2)*conj(S(1)) + S(1)*conj(S(2)))/k^2;
        S34 =  -1/2 *imag(-S(2)*conj(S(1)) + S(1)*conj(S(2))) /k^2;
        y(i,l,1,1)=S11;
        y(i,l,2,2)=S11;
        y(i,l,3,3)=S33;
        y(i,l,4,4)=S33;
        y(i,l,1,2)=S12;
        y(i,l,2,1)=S12;
        y(i,l,2,1)=S12;
        y(i,l,3,4)=S34;
        y(i,l,4,3)=-S34;
    end

end
