% BOOONG   Plays a gong-type sound
%
%    Loads and plays the sound found in gong.mat (a file part of Matlab).
%
%    See also beep
%
% FORMAT gong([pitch])
%
% OPT   pitch  Frequency scaling of original sound. Default is 3.  

function gong(pitch)

load gong.mat;

if nargin
  sound( y, pitch*Fs);
else
  sound( y, 3*Fs );
end