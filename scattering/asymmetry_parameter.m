% ASYMMETRY_PARAMETER   The asymmetry parameter of ARTS single scattering data
%
%   Calculates the asymmetry parameter for single scattering data following
%   the ARTS format. 
%  
%   The data must be for the ptype 'macroscopically_isotropic'. The lengthn
%   of S must be one. 
%
% FORMAT   g = asymmetry_parameter(S)
%
% OUT      g   Asymmetry parameters  [-], with dimension: 
%              (length of f_grid , length of t_grid)
% IN       S   ARTS single scattering data (only one element allowed)
%
% History: 2014-02-10  Created by Maryam Jamali & Patrick Eriksson


function g = asymmetry_parameter(S)

if length(S) > 1
  error( 'Only single element *S* are ahandled (i.e. length(S) must be 1).' );
end
if ~strcmp( S.ptype, 'macroscopically_isotropic' )
  error( [ 'This function can only be used with ', ...
           '''macroscopically_isotropic'' particles' ] );
end

g = zeros( length(S.f_grid), length(S.T_grid) );

za  = S.za_grid;
aaw = abs( sind(za) );

for j = 1 : length(S.f_grid) 
  for k = 1 : length(S.T_grid)  
      
    p    = squeeze( S.pha_mat_data(j,k,:,1,1,1,1) );
    
    % All pi factors disappear as they are part of both integrals
    %
    normfac = trapz( za, p.*aaw );
    %
    if normfac == 0  % If zero, this means that p==0 hat should indicate very
      g(j,k) = 0;    % small particles that have g=0.
    else
      g(j,k) = trapz( za, cosd(za).*p.*aaw ) / normfac;
    end
  end
end
