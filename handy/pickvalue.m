% PICKVALUE   Simple selection among a set of values.
%
%    This function simply returns the (i+1):th input argument. 
%
%    For example, pickvalue( 3, 'a','b','r','t' ) returns 'r'.
%
% FORMAT a = pickvalue(i,...)
%
% OUT   a     Seclected value
%       i     Index of value to pick
%       ...   Value to select between.

% 2015-02-23 Patrick Eriksson

function a = pickvalue(i,varargin)
  
a = varargin{i};