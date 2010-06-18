function [colno, names] = colloc_colname2no(sensor1, sensor2, colnames)

% colloc_colno2name Convert column names to column numbers
%
% For the user, data columns are most easily referred to as names,
% particularly when multiple channels are requested: {'ROIWP', 'MHS', 3:5}.
% This m-file converts those names to numbers that can be used to actually
% extract those columns from the collocation files.
%
% FORMAT
%
%   [colno names] = colloc_colname2no(sensor1, sensor2, colnames)
%
% IN
%
%   sensor1     string
%   sensor2     string
%   colnames    string cellarray
%
% OUT
%
%   colno       vector
%   names       structure
%
% $Id$

cols = colloc_config(['cols_' sensor1 '_' sensor2]);
colno = cell(size(colnames));

% in the 'data' part, there might be multi-channel instruments such
% that the cell looks like {'MHS', [3 4 5], 'ROIWP'}, in that case,
% colno will have different dimensions than cols_in, so we need
% different counters too.

m = 0; % counts the total number of output columns assigned
for i = 1:size(colnames, 2) % counts the different cell arrays in colnames or colno
    ncols = length(colnames{i});
    j = 1; % counts index in each of the cols_in cell array
    k = 1; % counts index of each of the colno vectors
    while j <= ncols
        colname = colnames{i}{j};
        no = structsearch(cols, colname);
        if isscalar(no) % single-channel
            colno{i}(k) = no;
            names.(colname) = m+1;
            j = j + 1;
            k = k + 1;
            m = m + 1;         
        else % multi-channel instrument
            if j+1 <= ncols && isnumeric(colnames{i}{j+1}) % selected channels
                chans = colnames{i}{j+1};
                j = j + 2; % skip the next element (it refers to the channels)
            else % all channels
                chans = true(size(no));
                j = j + 1;
            end
            nchans = length(chans);
            colno{i}(k:k+nchans-1) = no(chans);
            names.(colname) = m+1:m+nchans;
            k = k + nchans;
            m = m + nchans;
        end
    end
end
end