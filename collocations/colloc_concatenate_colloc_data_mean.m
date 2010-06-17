function [overlap_cat, data_cat, meandata_cat] = ...
    colloc_concatenate_colloc_data_mean(overlap, overlap_new, data, data_new, ...
    meandata, meandata_new)

% colloc_concatenate_colloc_data_mean Concatenate collocation structures
%
% Concatenate collocation structures: a structure where each field is a
% matrix, and those are concatenated vertically by field.
% Meandata is a special case.
% Meandata, as processed by process_meandata_*, contains columns (the first
% two) referring to the first and the last line in the collocation matrix
% that is being averaged over. For example, each row in the
% meandata_cpr_mhs describes between what two rows all the CloudSat pixels
% in the corresponding collocation matrix are described. Since this works
% by row-numbers, when the collocation tables and the corresponding
% meandata tables are concatenated, those row numbers need to be corrected.
%
% FORMAT
%
%    [overlap_cat, data_cat, meandata_cat] = ...
%       colloc_concatenate_colloc_data_mean(overlap, overlap_new, data, ...
%           data_new, meandata_new)
%
% IN
%
%   overlap         structure
%   overlap_new     structure
%   data            structure
%   data_new        structure
%   meandata        structure
%   meandata_new    structure
%
% OUT
%
%   overlap_cat     structure
%   data_cat        structure
%   meandata_cat    structure
%
% $Id$

overlap_cat = overlap;
data_cat = data;
meandata_cat = meandata;

fields = fieldnames(overlap); % fields that exist in NEW one will be used
for n = 1:length(fields) % loop through all fields
    sat = fields{n};
    
    overlap_cat.(sat) = [overlap_cat.(sat); overlap_new.(sat)];
    data_cat.(sat) = [data_cat.(sat); data_new.(sat)];
    
    %% correct meandata FIRST/LAST columns
    % the first two columns of meandata should always be FIRST and LAST;
    % those refer to line numbers in the overlap matrices. From
    % collocate_granule, this is per granule. When concatenating
    % granules, those numbers need to be corrected.
    if any(meandata_new.(sat)) % that have anything this iteration
        n_before = size(overlap.(sat), 1);

        meandata_new.(sat)(:, 1:2) = meandata_new.(sat)(:, 1:2) + n_before;
        % and proceed with cat'ing
        meandata_cat.(sat) = [meandata_cat.(sat); meandata_new.(sat)];
    end
end
