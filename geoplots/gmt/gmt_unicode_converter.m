function out = gmt_unicode_converter(string)
%% gmt_unicode_converter
%
% Converts string to something that GMT can read
%
% $Author$
% $Date$ 

out = sprintf('"$(echo "%s" |iconv -f utf-8 -t iso-8859-1)"',string) ;