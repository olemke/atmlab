% n_ice_ray72   Dielectric constant for pure ice according to Ray 1972
%
%    Provides the complex dielectric constant following the Ray 1972 paper.
%    Note that the claimed frequency range in the paper (wavelength = 2um to
%    thousands of km) is very wide. Concidering newer research, this is not
%    valid. Here, it is only implemented for testing purposes and at
%    wavelengths>62um. 
%
%    Some assumptions and slight modifications were necessary to the original
%    equations in order to make calculated numbers fit the plots in the paper
%    (which were used as the reference). Specifically, Ray does not specify the
%    units for lambda to be used. Testing showed [mm] to be appropriate for the
%    Debye part; in the absorption band addition [um] are used in consistency
%    with the tables in the paper. Furthermore, log10 instead og log is used
%    in the absorption band contribution to imaginary part.
%
%    NOTE:
%    Comparison to other, more recent mdels proves this model to be largely
%    outdated. It provides far too low imaginary refractive index at mm- and
%    submm-wave frequencies (two orders of magnitude at 300GHz, even larger
%    differences at higher frequencies) and places the Debye minimum at far
%    too high frequencies (at about 300Ghz instead of 3GHz), causing an
%    imaginary part overestimation at cm-wave frequencies and below.
%
%    Frequency limit (as implemented) is:
%      f: [ 10 Hz, 4800GHz ] (~1e9cm, 62um)
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

if length(t)>1
  error('Oops, only one temperature point allowed so far.')
end

if ~isempty( find(t<250  |  t>273.15) )
  error('Valid range for temperature is 250-273.15 K'); 
end

if ~isempty( find(f<10.  |  f>4800e9) )
  error('Valid range for frequency is 10 Hz - 4800 GHz'); 
end

t0C = 273.15;
tC = t - t0C;

c = 2.99792458e8;
%comparison with plots suggests that lambda is in [mm]
lambda = 1e3*c./f;

pi2 = acos(-1.)/2.;

% Debye parameters of the ice model
eps_inf = 3.168;
alpha = 0.288 + 0.0052*tC + 0.00023*tC^2;
sigma = 1.26 * exp(-12500.0/(t*1.9869));
lambda_s = 9.990288e-4 * exp(13200.0/(t*1.9869));
eps_s = 203.168 + 2.5*tC + 0.15*tC^2;


% Debye part
a0 = (lambda_s./lambda).^(1.-alpha);
a1 = a0*sin(alpha*pi2);
a2 = a0*cos(alpha*pi2);
a3 = a0.^2;

eps_r = eps_inf + ((eps_s-eps_inf)*(1.0+a1))./(1.0+2*a1+a3);
eps_i = ((eps_s-eps_inf)*a2)./(1.0+2*a1+a3) + (sigma*lambda)/18.8496e10;
eps = eps_r + i*eps_i;

% Debye refractive index
n_D = sqrt(eps);

% coefficients for absorption band contributions
% for n_r only the part for lambda >9.5um
alpha_s = 1.2225;
w0 = [1652.9, 909.09, 223.2];
beta_r = [1120820.0, 416441.0, 47031.8];
gamma_r = [46e-11, 118852.0, 126834.0];
% for n_i only the part for lambda >62um
lambda0 = [44.8, 62.0];
beta_i = [0.581, 0.242];
delta_i = [0.055, 0.23];
gamma_i = [1.0, 1.6];

% adding absorption band contributions
n_r = real(n_D);

%NOTE: lambda0 are explicitly given in um and tabulated ranges are given in
%[um], hence we convert and use it in [um] here as well.
lambda = lambda*1e3; %changing lambda into [um]

% real part
ihit = find( lambda<800. & lambda>200.);
if ~isempty( ihit )
  l200 = 200.;
  n_rl200 = alpha_s;
  w200 = 1e4/l200;
  for ii=1:3
    dw = w0(ii)^2-w200^2;
    n_rl200 = n_rl200 + (beta_r(ii)*dw)/(dw^2+gamma_r(ii)*w200^2);
  end
  n_rl200 = sqrt(n_rl200);
end

for jj=1:length(n_r)
  %fprintf('size #%i: l=%12.3e', jj, lambda(jj))
  if lambda(jj)<800.
    if lambda(jj)<200.
      n_rl = alpha_s;
      w = 1e4./lambda(jj);
      for ii=1:3
        dw = w0(ii)^2-w^2;
        n_rl = n_rl + (beta_r(ii)*dw)/(dw^2+gamma_r(ii)*w^2);
      end
      n_rl = sqrt(n_rl);
    else
      w_D = (lambda(jj)-200.)./600.;
      w_rl200 = (800.-lambda(jj))./600.;
      n_rl =  n_r(jj)*w_D + n_rl200*w_rl200;
    end
    n_r(jj) = n_rl;
  end
end

%imag part
n_i = imag(n_D);
for ii=1:2
  n_i = n_i + beta_i(ii)*exp(-abs(log10(lambda/lambda0(ii))/delta_i(ii)).^gamma_i(ii));
end

% resulting complex refractive index
n = n_r + i*n_i;
