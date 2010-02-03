%   Returns Mie-backscattering cross-sections to be used
%   for e.g. a monostatic radar. The function is an interface
%   to mie.m
% 
%
% FORMAT  y=mie_back(m,lambda,r)
%
% OUT     y          Mie backscattering cross-section per particle [m2]
%                    (e.g. to be used for a monostatic radar)
% 
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         r          particle radius [m] (vector)   
%
%
% History: 2010-02-02 Created by Bengt Rydberg

function [y]=mie_back(m,lambda,r)



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
    y(i)=result(4)*pi*r(i)^2;

end

