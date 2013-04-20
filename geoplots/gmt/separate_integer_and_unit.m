function [inter,unit] = separate_integer_and_unit(in)
%% separate_integer_and_unit
%
% Purpose: Separate intergers from the unit from a string. 
%
% in: expects %s in the form e.g., '26i','2.34c', or even something like
% '232.324cm˚'. If it's already a scalar, then unit = ''; and inter=in;
%
% $Id$
% Salomon Eliasson

if ischar(in)
    out = regexp(in,'(?<inter>[\-,0-9,\.]+)(?<unit>.+)','names');
    inter = str2double(out.inter);
    unit  = out.unit;
elseif isscalar(in)
    inter=in;
    unit='';
end


 