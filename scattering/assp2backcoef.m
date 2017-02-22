% ASSP2BACKCOEF   Extracts backscattering coefficient from ARTS SSP data
%
%   The function returns the radar backscattering coeffcient. This is the
%   phase function times 4pi, following the standard definition in the radar
%   community. 
%
% FORMAT   b = assp2backcoef(S)
%
% OUT   b   Backscattering coefficients, one value for each frequency and
%           temperature in S. [m2]
% IN    S   Single scattering data in ARTS format.

% 2015-10-19 Patrick Eriksson

function b = assp2backcoef(S)
  
  
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
  

b = 4*pi * S.pha_mat_data(:,:,end,1,1,1,1);
