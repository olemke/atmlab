% ASSP2G   Asymmetry parameter of ARTS single scattering data
%
%   For a normalised phase function (p), g equals the 4pi integral of
%   p*cos(th), where th is the scattering angle. For pure isotropic
%   scattering g = 0, while pure forward scattering has g=1.
%
%   Warning, this function does not handle the extreme cases of
%   delta-function type of forward or backward scattering lobes. A g of
%   zero is returned for these cases.
%
% FORMAT   g = assp2g(S)
%
% OUT   g   Asymmetry parameter, one value for each frequency and
%           temperature in S. 
% IN    S   Single scattering data in ARTS format.

% 2014-02-10   Maryam Jamali 
% 2015-10-19   Restructured, Patrick Eriksson
% 2020-03-13   Fixed problem that occurs if S.za_grid is not a column.

function g = assp2g(S)
  
  
% Check input  
if length(S) > 1
  error( 'Only single element *S* is handled (i.e. length(S) must be 1).' );
end
if ~strcmp( S.ptype, 'totally_random' )
  %
  error( 'So far just totally random orientation is handled.' );
end
if S.za_grid(1) ~= 0
  error( 'First value of S.za_grid must be 0.' );
end
if S.za_grid(end) ~= 180
  error( 'Last value of S.za_grid must be 180.' );
end
  

g = zeros( length(S.f_grid), length(S.T_grid) );
za_grid = vec2col(S.za_grid);
% ARTS uses pure phase matrix values, and not a normalised phase function,
% and we need to include a normalisation 

azi_w = abs( sind(za_grid) );   % Azimuthal weighting
cterm = cosd(za_grid);          % Avoid recalculate cos term

for j = 1 : length(S.f_grid) 
  for k = 1 : length(S.T_grid)  
      
    p    = squeeze( S.pha_mat_data(j,k,:,1,1,1,1) );
    p = vec2col(p);

    % All pi factors disappear as they are part of both integrals
    %
    normfac = trapz( za_grid, p.*azi_w );
    %
    if normfac == 0  % If zero, this means that p==0 and should indicate very
      g(j,k) = 0;    % small particles that have g=0.
    else
      g(j,k) = trapz( za_grid, cterm.*p.*azi_w ) / normfac;
    end
  end
end
