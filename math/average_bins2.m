function out = average_bins2(data_bins,statistics,filter)
%% AVERAGE_BINS2 returns statistics from a cell array of gridded data
% 
% IN: 1) data_bins (mandatory), cell of gridded vectors of data
%     2) statistics (mandatory), cell array of statistic function
%        references
%     3) filter (optional), function reference to filter the binned data
%
% OUT: structure containg:
%      The structure elements have the names of the statistics functions
%
% EXAMPLE:
% 1) Calculate number of elements per bin, mean value for each bin:
%    out = average_bins2(data_bins, {@numel, @mean});
%
% 2) Calculate mean and standard deviation, ignore all elements smaller
%    than zero:
%    out = average_bins2(data_bins, {@mean, @std}, @(x)(x(x>=0)));
%
% Note:
% - I recommend the function binning_fast.m to set up the cell from
%   ungridded data.
%
% 2010-07-08 Oliver Lemke

if nargin == 3
    data_bins = cellfun(filter, data_bins, 'UniformOutput', false);
end

for s = statistics
    out.(func2str(s{1})) = cellfun(s{1}, data_bins);
end


