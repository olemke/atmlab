%-----------------------------------------------------------------------------
%  MIE_SCAT_DATA Creates single scattering properties for spherical 
%       particles
% 
%     The function uses the Mie code by C. Mätzler
%     
%   FORMAT  ssp = mie_scat_data(f_grid, T_grid, za_grid, aa_grid, r) 
%   
%   OUT     ssp      single scattering data
%   IN      f_grid   frequency grid [Hz], range 0.01e9 to 3000e9  
%   IN      T_grid   temperature grid [K], range 20 to 273.15
%   IN      theta    scattering angle grid [°]
%   IN      r        particle size [m]
%
%----------------------------------------------------------------------

function ssp = mie_scat_data(f_grid, T_grid, theta, r) 

if ( T_grid(1)<20 || T_grid(length(T_grid)) > 273.15)
  error('Temperature grid is out of range (20 to 273.15 K)');
end 

if (f_grid(1)<0.01e9 || f_grid(length(f_grid))>3000e9)
  error('Frequency grid is out of range (0.01e9 to 3000e9 Hz)');
end
  

% Particle type is 'p20' for spherical particles
ssp.ptype = 20;

ssp.description = ['Spherical particles, generated using atmlab and',...
		   'the Mie program from C. Mätzler, particle size', ...
		   ': ', num2str(r*1e6),' microns.']; 

ssp.f_grid = f_grid;

ssp.T_grid = T_grid;

ssp.za_grid = theta;

% Set aa grid to be empty (p20)
ssp.aa_grid = [];

% Now start Mie calculations

c = constants('SPEED_OF_LIGHT');

for i = 1:length(f_grid)
  for j = 1:length(T_grid)
    m = sqrt(epsice(f_grid(i)*1e-9,T_grid(j)));
    % Wavenumber
    k = 2*pi*f_grid(i)/c;
    % Size parameter
    x = k * r;
    
    % Calculate scattering, absorption and extinction cross-sections
    mie_out = mie(m,x);
    
    ssp.ext_mat_data(i, j, 1, 1, 1) = mie_out(1)*pi*r^2;
    ssp.abs_vec_data(i, j, 1, 1, 1) = mie_out(3)*pi*r^2;
    
    % Calculate the phase matrix
    for l = 1:length(theta)
      
      u = cos(pi/180*theta(l));
      S = mie_S12(m,x,u);
      
      S11 = 1/2 * ( abs(S(1))^2 + abs(S(2))^2 )/k^2;
      S12 = 1/2 * ( abs(S(2))^2 - abs(S(1))^2 )/k^2;
      S33 = 1/2 * ( S(2)*conj(S(1)) + S(1)*conj(S(2)))/k^2;
      S34 =  -1/2 *imag(-S(2)*conj(S(1)) + S(1)*conj(S(2))) /k^2;
      
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 1) = S11;
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 2) = S12;
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 3) = S11;
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 4) = S33;
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 5) = S34;
      ssp.pha_mat_data(i, j, l, 1, 1, 1, 6) = S33;
    
    end
  
  end
end

