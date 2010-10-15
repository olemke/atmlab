function out = isditto(arg1,arg2)
%% ISDITTO Modern version of issame
%
% Purpose: To check if two matrixes are the same
% Usage: logical_val = isditto(arg1,arg2)
%
% In: 2 scalars/matrixes to be compared
% Out: true or false
%
% $Id$

if ~isequal(size(arg1),size(arg1))
    out = false;
    return
end

out = all(arg1(:) == arg2(:));
