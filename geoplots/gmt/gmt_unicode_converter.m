function out = gmt_unicode_converter(string)
% GMT_UNICODE_CONVERTER % Converts string to something that GMT can read
%
% IN   string             Some string to be used in a gmt command call
% OUT  out                The same string in supported utf 
%
% e.g. kg/m²
%
% Created by Salomon Eliasson
% $Id$

out = sprintf('$(echo "%s" |iconv -f utf-8 -t iso-8859-1)',string) ;