% EPS_WATER_ELL07 calculates complex relative permittivity
% for pure water
%
%  Function for calculating the complex relative permittivity
%  of pure water according to
%  "Permittivity of Pure Water, at Standard Atmospheric Pressure, over the
%   Frequency Range 0-25 THz and Temperature Range 0-100C
%   J. Phys. Chem. Ref. Data, Vol. 36, No. 1, 2007"
%
% FORMAT   z = eps_water_ell07(f,TK)
%
%  OUT   z   Complex relative permittivity (dielectric constant)
%
%  IN    f   Frequency [Hz]. 0 - 25 THz.
%        T   Temperature [K]. 233 - 373.15 K.
%

% Created by Bengt Rydberg 2017-01-02

function e = eps_water_ell07(f_grid, t)

if min(f_grid) < 0 | max(f_grid) > 25e12
  error('Valid range for frequency is 0 - 25 THz');
end
if min(t) < 225  |  max(t) > 373.15
  error('Valid range for temperature is 225 - 373.15K');
end


% ELL07 model parameters - table 2 in Ellison (2007)
a1 = 79.23882;
a2 = 3.815866;
a3 = 1.634967;
tc = 133.1383;
b1 = 0.004300598;
b2 = 0.01117295;
b3 = 0.006841548;
c1 = 1.382264e-13;
c2 = 3.510354e-16;
c3 = 6.30035e-15;
d1 = 652.7648;
d2 = 1249.533;
d3 = 405.5169;
p0 = 0.8379692;
p1 = -0.006118594;
p2 = -0.000012936798;
p3 = 4235901000000.0;
p4 = -14260880000.0;
p5 = 273815700.0;
p6 = -1246943.0;
p7 = 9.618642e-14;
p8 = 1.795786e-16;
p9 = -9.310017e-18;
p10 = 1.655473e-19;
p11 = 0.6165532;
p12 = 0.007238532;
p13 = -0.00009523366;
p14 = 15983170000000.0;
p15 = -74413570000.0;
p16 = 497448000.0;
p17 = 2.882476e-14;
p18 = -3.142118e-16;
p19 = 3.528051e-18;


for i = 1:length(t)
  % Temperature in celsius
  t_cels = t(i) - 273.15;
  % static permittivity
  epsilon_s = 87.9144 - 0.404399 * t_cels - 9.58726e-4 * t_cels^2 - 1.32802e-6 * t_cels^3;
  % Model parameters
  delta1 = a1 * exp(-b1 * t_cels);
  delta2 = a2 * exp(-b2 * t_cels);
  delta3 = a3 * exp(-b3 * t_cels);
  tau1 = c1 * exp(d1 / (t_cels + tc));
  tau2 = c2 * exp(d2 / (t_cels + tc));
  tau3 = c3 * exp(d3 / (t_cels + tc));
  delta4 = p0 + p1 * t_cels + p2 * t_cels^2;
  f0 = p3 + p4 * t_cels + p5 * t_cels^2 + p6 * t_cels^3;
  tau4 = p7 + p8 * t_cels + p9 * t_cels^2 + p10 * t_cels^3;
  delta5 = p11 + p12 * t_cels + p13 * t_cels^2;
  f1 = p14 + p15 * t_cels + p16 * t_cels^2;
  tau5 = p17 + p18 * t_cels + p19 * t_cels^2;
  % Loop frequency:
  for j = 1:length(f_grid)
    % real part of the complex permittivity of water (triple-debye + 2 resonances)
    w = 2 * pi * f_grid(j);
    Reeps(j, i) = epsilon_s - ...
                  (2 * pi * f_grid(j))^2 * (...
                    tau1^2 * delta1 / (1 + (2 * pi * f_grid(j) * tau1)^2) + ...
                    tau2^2 * delta2 / (1.+ (2 * pi * f_grid(j) * tau2)^2) + ...
                    tau3^2 * delta3 / (1.+ (2 * pi * f_grid(j) * tau3)^2) ...
                  ) - ...
                  (2 * pi * tau4)^2 * delta4/2 * ( ...
                    f_grid(j) * (f0 + f_grid(j)) / (1 + (2 * pi * tau4 * (f0 + f_grid(j)))^2) - ...
                    f_grid(j) * (f0 - f_grid(j)) / (1 + (2 * pi * tau4 * (f0 - f_grid(j)))^2) ...
                  ) - ...
                  (2 * pi *tau5)^2 * delta5 / 2 * ( ...
                    f_grid(j) * (f1 + f_grid(j)) / (1 + (2 * pi * tau5 * (f1 + f_grid(j)))^2) - ...
                    f_grid(j) * (f1 - f_grid(j)) / (1 + (2 * pi * tau5 * (f1 - f_grid(j)))^2) ...
                  );
    % imaginary part of the complex permittivity of water (triple-debye + 2 resonances)
    Imeps(j, i)  = 2 * pi * f_grid(j) * (...
                     tau1 * delta1 / (1 + (2 * pi * f_grid(j) * tau1)^2) + ...
                     tau2 * delta2 / (1 + (2 * pi * f_grid(j) * tau2)^2) + ...
                     tau3 * delta3 / (1 + (2 * pi * f_grid(j) * tau3)^2) ...
                   ) + ...
                   pi * f_grid(j) * tau4 * delta4 * ( ...
                     1 / (1 + (2 * pi * tau4 * (f0 + f_grid(j)))^2) + ...
                     1 / (1 + (2 * pi * tau4 * (f0 - f_grid(j)))^2) ...
                   ) + ...
                   pi * f_grid(j) * tau5 * delta5 * ( ...
                     1 / (1 + (2 * pi * tau5 * (f1 + f_grid(j)))^2) + ...
                     1 / (1 + (2 * pi * tau5 * (f1 - f_grid(j)))^2) ...
                   );
  end
end

e = complex(Reeps, Imeps);
