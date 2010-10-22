%+ E2SPECHUM: Converts the water vapor pressure to a specific humidity
%
%  Converts water vapor pressure over a plane surface
%  according to equation 3.57(a) and (b) and 3.59 on page 80 of Atmospheric Science
%  An Introductory Survey. John M. Wallace & Peter V. hobbs 2nd Edition
%  The formulas:
% 
%  e = (w * p) / ( w + eps)
%  w = mv / md
%  q = w / ( 1 + w )
%
%  where:
%  eps = 0.622
%
%  OUT	   q = specific humidity [kg/kg].
%  IN      e = partial vapor pressure of water and total Pressure in [Pa]
%  Both input variables can be matrices or 1 is a matrix and the other a
%+ scalar.

% 2010-08-18 Created by Marston Johnston

function [q] = e2spechum(e,P)

rqre_element_math(e,P);

eps = 0.622;

q = (eps * e) ./ (P-(1-eps) * e);

