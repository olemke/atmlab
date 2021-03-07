% Creates *backend_channel_response*
%
%   The response set follows the data in *O*, particularly O.freq
%
% FORMAT G = oi22_channel_response(O)
%
% OUT   G   Channel response as a ArrayOfGriddedField1
% IN    O   Observation data structure

% 2021-02-07 Patrick Eriksson


function G = oi22_channel_response(O)

% RPG FFT polyphase filterbank
% Model based on figure Peter sent, taken from spectrometer data sheet
if length(O.freq) == 9001  &  (diff(O.freq(1:2)) - 12.2e3) < 500
  %
  ff = 1e3 : 0.2e3 : 18e3;
  r  = gauss( ff, fwhm2si(9e3), ff(1) );
  ff = [-ff(end:-1:1) ff];
  r  = [r(end:-1:1) r];

% Pure Gaussain 
elseif 0
  %
  ff = -20e3 : 2e3 : 20e3;
  r = gauss( ff, fwhm2si(12e3), 0 );

else
  error( 'O.freq does not match any of the recognised choices.' );
end


G{1}.gridnames = { 'Frequency' };
G{1}.dataname  = 'Response';
G{1}.name      = 'Backend channel response function';
G{1}.grids     = { ff };         
G{1}.data      = r';         
