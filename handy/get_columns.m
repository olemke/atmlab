function [y, y_cols] = get_columns(dat, cols, fns)
% get columns from matrix based on structure and names
%
% Select "named" columns from a matrix.  For a pair consisting of a matrix
% and a structure describing what the columns represent (such as returned
% by <a href="matlab:help
% CollocatedDataset/read">CollocatedDataset.road</a>), return a
% sub-selection of columns with an associated new describing structure.
%
% FORMAT
%
%   [y, y_cols] = get_columns(data, cols_struct, fieldnames)
%
% IN
%
%   data        Matrix containing data
%   cols        Structure describing what's in the columns
%   fieldnames  Cell array of strings with columns to retain
%
% OUT
%
%   y           New matrix, subset of 'data'
%   y_cols      Structure describing columns in 'y'
%
% $Id$

cls = cellfun(@(X) cols.(X), fns, 'UniformOutput', false);
% define cols-structure
y_cols = struct();
i = 1;
for fni = 1:length(fns)
    fn = fns{fni};
    y_cols.(fn) = i:(i+length(cols.(fn))-1);
    i = i + length(cols.(fn));
end
y = dat(:, horzcat(cls{:}));
end
