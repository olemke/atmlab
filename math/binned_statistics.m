function out = binned_statistics(data_bins, statistics, filter)
%% BINNED_STATISTICS Calculate statistics for a cell array of binned data.
%
% This functions calculates statistics for binned data. data_bins has to
% be a cell array where each cell contains an array of values.
% Each function given in the statistics parameter is called for each
% cell of data_bins. Optionally, a filter function can be passed which is
% applied to the binned data.
%
% FORMAT   out = binned_statistics(data_bins, statistics, filter)
%
% OUT   out          Structure containing the results for each applied
%                    statistics function.
% IN    data_bins    Cell of gridded vectors of data.
%       statistics   Cell array of statistic function references.
%       filter       Function to filter the binned data.
%
%
% EXAMPLES
% * Calculate number of elements per bin, mean value for each bin:
%   out = binned_statistics(data_bins, {@numel, @mean});
%
% * Calculate mean and standard deviation, ignore all elements smaller
%   than zero by passing the filter criteria as an anonymous function:
%   out = binned_statistics(data_bins, {@mean, @std}, @(x)(x(x>=0)));
%
% NOTE
% * It's recommended to use binning_fast.m to set up the cell array from
%   ungridded data.
%
% 2010-07-08 Oliver Lemke

if nargin == 3
    data_bins = cellfun(filter, data_bins, 'UniformOutput', false);
end

for s = statistics
    out.(func2str(s{1})) = cellfun(s{1}, data_bins);
end
