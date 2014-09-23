% AMSUA_APPLY_POLARISATION   Includes AMSU-A polarisation response
%
%    The function takes an ARTS spectrum and includes the polarisation
%    response. The spectrum shall be a column vector, with Stokes elements
%    in order as used by ARTS. The WSV *stokes_dim* must be at least 3. It
%    is allowed to just include a sub-set of the channels. For example, if
%    only the two first channels are considered, set channels=1:2.
%
%    The spectra must be in brightness temperature!!!
%
%    The function can handle several spectra in one call, if *za*,
%    *stokes_dim* and *channels* are common for all spectra. The different
%    spectra are then given as columns in a matrix.
%
% FORMAT   [y,H] = amsua_apply_polarisation(y0,za,stokes_dim[,channels])
%        
% OUT   y          Measurement spectrum.
%       H          The response matrix set-up inside the function.
% IN    y0         Spectrum with Stokes elements.
%       za         Zenith angle, a value between 90 and 180.
%       stokes_dim Stokes dimensionality. Must be >= 3.
% OPT   channels   Index of channels included. Default is 1:15, 
%                  ie. all channels are included.

% 2013-06-24   Created by Patrick Eriksson.


function [y,H] = amsua_apply_polarisation(y0,za,stokes_dim,channels)
%
if nargin < 4
  channels = 1:15;
end

rqre_datatype( za, @istensor0 );
rqre_datatype( stokes_dim, @istensor0 );

if za < 90  | za >180
  error( 'The argument *za* must be in the range [90,180].' );
end
if stokes_dim < 3
  error( 'The argument *stokes_dim* must be >= 3.' );
end
if size(y0,1) ~= stokes_dim*length(channels)
  error( ['Inconsistency between length of *y* and the combination of ',...
           '*stokes_dim* and length of *channels*.' ] );
end
if min(channels) < 1 | max(channels) > 15
  error( 'The values in *channels* must be in the range [1,15].' );
end


% Rotation angle
rotangle = 180 - za;

% V or H coding for the channels, wher V=1 and H=2
%        1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
vorh = [ 1 1 1 1 2 2 1 2 2  2  2  2  2  2  1 ];
%
vorh = vorh(channels);

% V and H polarisation response vectors
Hpol = [ 1 1 0 0; 1 -1 0 0 ];
Hpol = Hpol( :, 1 : stokes_dim );


% Matrix to be field for applying rotation
R      = speye( stokes_dim );
[R(2,2),R(3,3)] = deal( cosd( 2*rotangle ) );
R(2,3)          = sind( 2*rotangle );
R(3,2)          = -R(2,3);
  

% Set up H
%
row = [];
col = [];
s   = [];
%
for i = 1 : length(channels)
  row = [ row, repmat( i, 1, stokes_dim ) ];
  col = [ col, (i-1)*stokes_dim+[1:stokes_dim] ];
  %
  s   = [ s, Hpol(vorh(i),:)*R ];
end
%
H = sparse( row, col, s, length(channels), length(y0) );
          

% Apply H
y = H * y0;