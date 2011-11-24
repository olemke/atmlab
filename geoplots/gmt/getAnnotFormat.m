function annot_format = getAnnotFormat(quantity)
%% getAnnotFormat
% Guess a reasonable annotation format for gmtlab based on the provided quantity.
% in.tick_annotation_format overrides this function. 
%
% IN     quantity          (scalar or a vector)
% OUT    annot_format      string to be used in e.g. fprintf
%
% EXAMPLE  >> getAnnotFormat(0.00358)
%          
%          ans =
%
%          '%.3f'
%               
% Created by Salomon Eliasson

assert(nargin==1,['gmtlab:' mfilename ':badInput'],...
    'USAGE: annot_format = getAnnotFormat(quantity)')

if quantity == 0
    annot_format = '%.0f';
elseif floor(log10(quantity))>0
    annot_format = sprintf('%%%i.0f',min(floor(log10(quantity))));
else
    annot_format = sprintf('%%.%if',abs(min(floor(log10(quantity)))));
end