function angles_out_degrees = angular2D(func, angles_in_degrees, varargin)

% angular2D Perform statistics on angular data
%
% This function can be used as a wrapper to perform some statistics (mean,
% interpolation, etc.) in angle space. It converts angles to complex
% representation, performs the statistics, and converts the result back.
% Note that this naive approach works for mean or linear interpolation,
% but fails for higher-order moments such as the variance or the standard
% deviation. For more advanced analysis of circular data, use the
% <a href="http://www.mathworks.com/matlabcentral/fileexchange/10676">circular statistics toolbox</a>.
%
% If the output is undefined (for example, the mean of an isotropic
% distribution of angles) the result is set to nan.
%
% FORMAT
%
%   angles_out_degrees = angular2D(func, angles_in_degrees, ...)
%
% IN
%
%   func                function handle     function to apply to angles
%   angles_in_degrees   matrix              angular data
%   ...                 all other arguments passed to func unaltered
%
% OUT
%
%   angles_out_degrees  matrix              result converted back to degrees
%
% $Id$

angles_in_rad = (pi/180) * angles_in_degrees;
angles_in_compl = exp(1i*angles_in_rad);
angles_out_compl = func(angles_in_compl, varargin{:});
angles_out_rad = angle(angles_out_compl);
angles_out_degrees = (180/pi) * angles_out_rad;
angles_out_degrees(abs(angles_out_compl)<1e-10) = nan;
