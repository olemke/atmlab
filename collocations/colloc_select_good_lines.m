function good = colloc_select_good_lines(unisec, line)

% colloc_select_good_lines Select 'good' scanlines
%
% WARNING! Function in alpha, subject to change!
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
%   good = colloc_select_good_lines(unisec, line)
%
% IN
%
%   unisec  array   contains starting times for granule for each row
%   line    array   contains row-number/scanline for each granule
%
% OUT
%
%   good    logical array  true/false
%
% Note: this function is normally not called directly, but by passing the
% handle to collocation_read
%
% WARNING! Function in alpha, subject to change!
%
% $Id$

[unisec_uni, I] = unique(unisec);
ngrans = length(unisec_uni);

good = false(size(line));
cutoffs = zeros(size(unisec_uni));
for i = 2:ngrans % leave first cutoff at 0, e.g. always select all points for first granule
    % this returns 0 if it's not found, so then this filter is a noop
    cutoffs(i) = amsu_first_scanline('noaa19', unisec_uni(i));
end

for i = 1:ngrans
    first = I(i);
    if i==ngrans
        last = length(line);
    else
        last = I(i+1)-1;
    end
    good(first:last) = line(first:last) >= cutoffs(i);
end