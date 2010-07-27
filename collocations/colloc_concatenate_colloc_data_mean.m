function [overlap_cat, data_cat, meandata_cat] = ...
    colloc_concatenate_colloc_data_mean(...
    overlap_old, overlap_new, ...
    data_old, data_new, ...
    meandata_old, meandata_new, unicol)

% colloc_concatenate_colloc_data_mean Concatenate collocation structures
%
% Concatenate collocation structures: a structure where each field is a
% matrix, and those are concatenated vertically by field. It will remove
% double entries based on the 'unicol' argument; if there is any repetition
% for the values of the columns in unicol, they will be removed from
% structures to be added before doing so (the original ones will be left
% as-is).
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
%       colloc_concatenate_colloc_data_mean(...
%           overlap_old, overlap_new, ...
%           data_old, data_new, ...
%           meandata_old, meandata_new, unicol)
%
% IN
%
%   overlap_old     structure
%   overlap_new     structure
%   data_old        structure
%   data_new        structure
%   meandata_old    structure
%   meandata_new    structure
%   unicol          array       Column numbers to determine unique row. Can
%                               only be from overlap (not data or
%                               meandata).
%
% OUT
%
%   overlap_cat     structure
%   data_cat        structure
%   meandata_cat    structure
%
% $Id$

% in case nothing to be done
overlap_cat = overlap_old;
data_cat = data_old;
meandata_cat = meandata_old;
if ~exist('unicol', 'var')
    unicol = [];
end

fields = fieldnames(overlap_new); % fields that exist in NEW one will be used
for n = 1:length(fields) % loop through all fields
    sat = fields{n};
    
    if ~isfield(overlap_new, sat) || isempty(overlap_new.(sat)) % ignore
        continue
    end
    
    if ~isempty(unicol) && ~isempty(overlap_old.(sat)) % get rid of doubles
        rows = unique2(overlap_old.(sat)(:, unicol), ...
                       overlap_new.(sat)(:, unicol));
    else
        rows = true(size(overlap_new.(sat), 1), 1);
    end
    overlap_cat.(sat) = [overlap_old.(sat); overlap_new.(sat)(rows, :)];
    
    if ~isempty(data_new.(sat)) % that have anything this iteration
        data_cat.(sat) = [data_old.(sat); data_new.(sat)(rows, :)];
    end
    
    %% correct meandata FIRST/LAST columns
    % the first two columns of meandata should always be FIRST and LAST;
    % those refer to line numbers in the overlap matrices. From
    % collocate_granule, this is per granule. When concatenating
    % granules, those numbers need to be corrected.
    % Another complication arises because of removing lines.
    if any(meandata_new.(sat)) % that have anything this iteration
        n_before = size(overlap_old.(sat), 1);
        if ~all(rows)
            % from doubles, remove any rows where first or last points to a
            % deleted line / keep any rows where this is not the case
            nodups = meandata_new.(sat)(rows(meandata_new.(sat)(:, 1)), :);
            % from meandata_new_no_dups, reduce first/last columns by the
            % number of rows removed before this number
            rem_before = cumsum(~rows);
            nodups(:, 1) = nodups(:, 1) - rem_before(nodups(:, 1));
            nodups(:, 2) = nodups(:, 2) - rem_before(nodups(:, 2));
            meandata_new.(sat) = nodups;
        end

        meandata_new.(sat)(:, 1:2) = meandata_new.(sat)(:, 1:2) + n_before;
        % and proceed with cat'ing
        meandata_cat.(sat) = [meandata_cat.(sat); meandata_new.(sat)];
    end
end
