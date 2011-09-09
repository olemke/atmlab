function out = binned_statistics(data_bins, statistics, filter, replace)
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
%       replace      replace empty cells with <replace> (optional argument, default=don't)
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
% modified by Salomon Eliasson
% 2010-07-08 Oliver Lemke

if exist('filter','var')
    assert(isfunction_handle(filter),'atmlab:BadInput','filter must be a function handle')
    data_bins = cellfun(filter, data_bins, 'UniformOutput', false);
end

w = warning('off','MATLAB:divideByZero');
for s = statistics
    out.(func2str(s{1})) = cellfun(s{1}, data_bins, 'UniformOutput', false);
end
warning(w);

% Replace empty cells with something (e.g. NaN)
if exist('replace','var')
    for F = fieldnames(out)'
        test =  cellfun('isempty',out.(F{1}));
        if any(test(:))
            test =  out.(F{1})(~cellfun('isempty',out.(F{1})));
            if ~strcmp(class(replace),class(test{1}))
                fprintf('Replacing "[]" with "%.0f" instead of "%f" since class(replace):%s ~= class(data_bins):%s\n',...
                    ones(1,class(out.(F{1}){1}))*replace,replace,class(replace),class(test{1}));
                replace = ones(1,class(out.(F{1}){1}))*replace;
            end
            out.(F{1})(cellfun('isempty',out.(F{1})))={replace};
        end
    end
end