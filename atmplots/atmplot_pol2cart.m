% ATMPLOT_POL2CART   Plots a line given in polar coordinates.
%
%     The given points are plotted to current axes. No hold commando is 
%     applied. Plot symbol, and additional plot arguments, can be selected
%     by adding arguments after *lat*.
%
%     A scalar as input for either radius or latitude means that that value
%     shall be applied for all points. If both the radii and latitudes are
%     given as vectors, the both vectors must have the same size.
%
%     To draw a heart:
%        atmplot_pol2cart( linspace(0,9,91), 90:2:270, 'r-' );
%        hold on
%        atmplot_pol2cart( linspace(0,9,91), 90:-2:-90, 'r-' );
%
% FORMAT   atmplot_pol2cart( r, lat [, varargin ] )
%        
% IN    r          A single radius or a vector of radii.
%       lat        A single latitude, or a vector of latitides.
% OPT   varargin   Arguments that are passed to the *plot* commando.

% 2002-12-22   Created by Patrick Eriksson.


function atmplot_pol2cart( r, lat, varargin )


%= Input
%
min_nargin( 2, nargin );


DEG2RAD = constants( 'DEG2RAD' );


[x,y] = pol2cart( DEG2RAD * lat, r );


plot( x, y, varargin{:} );

