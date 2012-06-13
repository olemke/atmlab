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

assert(iscell(statistics),['atmlab:' mfilename ':badInput'],'function handles must be in a cell')
if exist('filter','var') && ~isempty(filter)
    assert(isfunction_handle(filter),'atmlab:BadInput','filter must be a function handle')
    data_bins = cellfun(filter, data_bins, 'UniformOutput', false);
end

w = warning('off','MATLAB:divideByZero');
for i = 1:length(statistics)
    try
        A.(func2str(statistics{i}))=0;
        statname= func2str(statistics{i});
    catch ME
        if strcmp(ME.identifier,'MATLAB:AddField:InvalidFieldName')
            statname = sprintf('statistic%.0f',i);
        else
            ME.rethrow();
        end
    end
    out.(statname) = cellfun(statistics{i}, data_bins, 'UniformOutput', false);
end
warning(w);

%% - Replace empty cells with something (e.g. NaN). put the data array must have the same class as "replace"
%
if exist('replace','var')
    for F = fieldnames(out)'
        % putting back [] if the input was empty to begin with would be desirable, since e.g. nansum([])=0,
        % 
        test =  cellfun('isempty',data_bins) | cellfun('isempty',out.(F{1}));
        if any(test(:))
            
            if ~strcmp(class(replace),class(data_bins{1,1}))
                warning(['atmlab:' mfilename ':dataClass'],...
                    ['replace  value "%f" is not the same class as data_bins\n',...
                    'E.g. this means you cannot call cell2mat without an error'],replace)
            end
            % this still won't work for [0xn] cells
            out.(F{1}){test}=replace;
        end
    end
end
