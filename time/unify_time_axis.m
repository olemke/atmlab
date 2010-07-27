function [t1, t2] = unify_time_axis(t1, t2)

% unify_time_axis Let time-axis have common epoch
%
% If two time vectors express time in 'seconds since start of day',
% and both start at different days, their values are by 86400 seconds off
% even if the actual times may be very close to each other.
% This m-file compensates for that effect.
% Assumes times are in seconds and already compensated for wraparound
% (see compensate_wraparound).
%
% Use with care, the implementation is naive (to any dataset at least 50000
% seconds before the other it adds 86400).
%
% FORMAT
%
%   [t1, t2] = unify_time_axis(t1, t2)
%
% IN
%
%   t1  vector  time vector for dataset 1
%   t2  vector  time vector for dataset 2
%
% OUT
%
%   t1  vector  time vector for dataset 1
%   t2  vector  time vector for dataset 2
%
% $Id$

if isempty(t1) || isempty(t2)
    return
end

S1 = t1(1);
S2 = t2(1);

if S1 - S2 > 50000; % t1 starts day before t2
    t2 = t2 + 86400;
elseif S2 - S1 > 50000; % t2 starts day before t1
    t1 = t1 + 86400;
end
