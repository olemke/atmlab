% ATMPLOT_SPH2CART   Plots a line given in spherical coordinates.
%
%     The given line/points are plotted to current axes. No hold commando is 
%     applied. Plot symbol, and additional plot arguments, can be selected
%     by adding arguments after *lat*.
%
%     A scalar as input for either radius, latitude or longitude means that 
%     that value shall be applied for all points. If radii, latitudes and
%     longitudes are given as vectors, all vectors must have the same size.
%
%     The x-axis corresponds to lat=0 and lon=0.
%     The y-axis corresponds to lat=90.
%     The z-axis corresponds to lat=0 and lon=90.
%
% FORMAT   atmplot_sph2cart( r, lat, lon, [, varargin ] )
%        
% IN    r          A single radius or a vector of radii.
%       lat        A single latitude, or a vector of latitides.
%       lon        A single longitudes, or a vector of longitudes.
% OPT   varargin   Arguments that are passed to the *plot* commando.

% 2002-12-22   Created by Patrick Eriksson.


function [x,y,z] = atmplot_sph2cart( r, lat, lon, varargin )


%= Input
%
min_nargin( 3, nargin );


DEG2RAD = constants( 'DEG2RAD' );


[x,z,y] = sph2cart( DEG2RAD * lon, DEG2RAD * lat, r );


plot3( x, y, z, varargin{:} );

