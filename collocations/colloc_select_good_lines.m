function good = colloc_select_good_lines(unisec, line, sat, sensor)

% colloc_select_good_lines Select 'good' scanlines
%
% This collocation-selector, to be used with collocation_read
% returns true for each row where the scanline does not occur
% in the swath before. For the first granule in the data,
% it returns true for every scanline.
%
% Assumes first row belongs to first swath.
%
% FORMAT
%
%   good = colloc_select_good_lines(unisec, line, sat, sensor)
%
% IN
%
%   unisec  array   contains starting times for granule for each row
%   line    array   contains row-number/scanline for each granule
%   sat     string  satellite
%   sensor  string  satellite
%
% OUT
%
%   good    logical array  true/false
%
% Note: this function is normally not called directly, but called by
% collocation_read.
%
% $Id$

[unisec_uni, I] = unique(unisec, 'first');
ngrans = length(unisec_uni);

good = false(size(line));
cutoffs = zeros(size(unisec_uni));
for i = 1:ngrans
    cutoffs(i) = granule_first_line(sat, sensor, unisec_uni(i));
end

% make a poor estimate for those where it's unknown (average of rest)
cutoffs(cutoffs==-1) = round(mean(cutoffs(cutoffs~=-1)));

for i = 1:ngrans
    first = I(i);
    if i==ngrans
        last = length(line);
    else
        last = I(i+1)-1;
    end
    good(first:last) = line(first:last) >= cutoffs(i);
end