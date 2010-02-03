%   Returns Mie-extinction cross-sections.
%   The function is an interface to mie.m.
%
% FORMAT  [y_ext,y_sca,y_abs]=mie_ext(m,lambda,r)
%
% OUT     y_ext     Mie extinction cross-section [m2]
%         y_sca     Mie scattering cross-section [m2]
%         y_abs     Mie absorption cross-section [m2]
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         r          particle radius [m] (vector)   
%
%
% History: 2010-02-02 Created by Bengt Rydberg

function [y_ext,y_sca,y_abs]=mie_ext(m,lambda,r)



rqre_alltypes(r,{@isnumeric,@isvector})

rqre_alltypes(lambda,{@isnumeric,@isscalar})

rqre_alltypes(m,{@isnumeric,@isscalar})

if any( imag( m ) ) < 0
  error( 'Imaginary part of the refractive index is expected to be positive.' );
end
  

x=2*pi/lambda*r;

%loop over particle sizes
for i=1:length(x)
  
    result = mie(m, x(i));
    y_ext(i)=result(1)*pi*r(i)^2;
    y_sca(i)=result(2)*pi*r(i)^2;
    y_abs(i)=result(3)*pi*r(i)^2;

end
