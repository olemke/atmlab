% n_ice_ray72   Dielectric constant for pure ice according to Ray 1972
%
%    Provides the complex dielectric constant following the Ray 1972 paper.
%    Note that the claimed frequency range in the paper (wavelength = 2um to
%    thousands of km) is very wide. Concidering newer research, this is not
%    valid. Here, it is only implemented for wavelengths>62um. Still, validity
%    is not guaranteed. It is implemented here for testing purposes, to
%    estimate the differences to more modern models.
%
%    Frequency limit (as implemented) is:
%      f: [ 300 Hz, 4800GHz ] (1000km, 62um)
%    Temperature limit 
%      t: [ 250 K, 273.15 K ] 
%
%
% FORMAT    n = n_ice_ray72( f, t )
%        
% OUT   n   Complex refractive index
% IN    f   Frequency                     [Hz]
%       t   Temperature                   [K]

% 2016-11-30   Created by Jana Mendrok


function n = n_ice_ray72( f, t )

if t<250  |  t>273.15
  error('Valid range for temperature is 250-273.15 K'); 
end

if f<300.  |  f>4800e9
  error('Valid range for frequency is 300 Hz - 4800 GHz'); 
end

t0C = 273.15;
t = t - t0C;

c = 2.99792458e8;
%check what uni for lambda is expected.
%I assume, it's either cm or um. trying out um first.
%NOTE: lambda0(i) are explicitly given in um. also tables are given over um.
lambda = 1e6*c/f;

pi = acos(-1.)

% Debye parameters of the ice model
eps_inf = 3.168;
alpha = 0.288 + 0.0052*t + 0.00023*t^2;
sigma = 1.26 * exp(-12500.0/((t+t0C)*1.9869));
lambda_s = 9.990288e-4 * exp(13200.0/((t+t0C)*1.9869));
eps_s = 203.168 + 2.5*t + 0.15*t^2;


% Debye part
a0 = (lambda_s/lambda)^(1.-alpha);
a1 = a0*sin(alpha*pi/2.);
a2 = a0*cos(alpha*pi/2.);
a3 = a0^2;

eps_r = eps_inf + ((eps_s-eps_inf)*(1.+a1))/(1.+2*a1+a3);
eps_i = ((eps_s-eps_inf)*a2)/(1.+2*a1+a3) + (sigma*lambda)/18.8496e10;
eps = eps_r - i*eps_i

% Debye refractive index
n_D = sqrt(eps)

% coefficients for absorption band contributions
% for nr only the part for lambda >9.5um
alpha_s = 1.2225;
w0 = [1652.9, 909.09, 223.2];
beta_r = [1120820.0, 416441.0, 47031.8];
gamma_r = [46e-11, 118852.0, 126834.0];
% for ni only the part for lambda >62um
lambda0 = [44.8, 62.0];
beta_i = [0.581, 0.242];
delta = [0.055, 0.23];
gamma_i = [1.0, 1.6];

% adding absorption band contributions
% real part
if lambda<800.0
  n_r = alpha_s;
  w = 1e4/lambda;
  for ii=1:3
    n_r = n_r + (beta_r(ii)*(w0(ii)^2-w^2))/((w0(ii)-w^2)^2+gamma(ii)*w^2);
  end
  n_r = sqrt(n_r);

  if lambda>200
    w_D = (lambda-200.)/600.;
    w_r = (800.-lambda)/600.;
    n_r = n_r*w_r + real(n_D)*w_D;
  end
else
  n_r = real(n_D);
end

%imag part
n_i = imag(n_D)
for ii=1:2
  n_i = n_i + beta_i(ii)*exp(-abs(log(lambda/lambda0(ii))/delta(ii))^gamma(ii))
end

% resulting complex refractive index
n = n_r - i*n_i
