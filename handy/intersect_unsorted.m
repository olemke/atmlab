function C = intersect_unsorted(A, B)
% intersect_unsorted intersect two cell arrays, don't sort
%
% Like Matlab's 'intersect', but does not sort the results.
% Designed and tested for cell arrays of strings with no duplicates.
% Should be much slower than Matlab's.
% Result will keep order of first cell array of strings input.
%
% FORMAT
%
%   C = intersect(A, B)
%
% IN
%
%   A   cell array of strings
%   B   cell array of strings
%
% OUT
%
%   C   cell arary of strings containing only those elements of A occuring
%       in B
%
% $Id$

n_A = length(A);
n_B = length(B);
if n_A*n_B==0
    C = {};
    return
end

k = 0;
for i = 1:n_A
    for j = 1:n_B
        if strcmp(A{i}, B{j})
            k = k + 1;
            C{k} = A{i}; %#ok<AGROW> % cell array permitted to grow
        end
    end
end
end
