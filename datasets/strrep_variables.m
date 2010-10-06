function s_out = strrep_variables(s, satname, datevec)

% strrep_variables Replace 'magic' variables
%
% Replace the 'magic' variables:
%
% $YEAR4
% $YEAR2
% $MONTH
% $DAY
% $DOY
% $SAT  or  $SAT1 and $SAT2
%
% FORMAT
%
%   s_out = strrep_variables(s, satname, datevec)
%
% IN
%
%   s       string  where magic is replaced
%   satname string* name of satellite
%   datevec vector  date-vector [year month day]
%
% OUT
%
%   s_out   string  with magic replaced
%
% $Id$

year = num2str(datevec(1), '%04d');
month = num2str(datevec(2), '%02d');
day = num2str(datevec(3), '%02d');
year02 = year(3:4);
doy = num2str(round(dayofyear(datevec(1), datevec(2), datevec(3))), '%03d');

to_replace = {'$YEAR4', year, '$MONTH', month, '$DAY', day, ...
    '$YEAR2', year02, '$DOY', doy};

if iscellstr(satname)
    to_replace = [to_replace {'$SAT1', satname{1}, '$SAT2', satname{2}}];
else
    to_replace = [to_replace {'$SAT', satname}];
end

s_out = strrep_multi(s, to_replace{:});