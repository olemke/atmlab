function dates = daterange(date1, date2)

% daterange Returns a matrix of valid dates within the daterange
%
% FORMAT
%
%   dates = daterange(date1, date2)
%
% IN
%
%   date1   1x3 array   Starting date
%   date2   1x3 array   Ending date
%
% OUT
%
%   dates   Nx3 matrix  All dates in the range
%
% $Id$

dn1 = datenum(date1);
dn2 = datenum(date2);

dates = datevec(dn1:dn2);
dates = dates(:, 1:3); % only year/month/day part
