function M = colloc_process_data_poes_poes(collocations, ~, ...
    ~, ~, data1, ~, ~, data2)

% colloc_process_data_poes_poes Gather collocation data to store for MHS+MHS
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data: in this case, brightness temperatures.
%
% FORMAT
%
%   M = colloc_process_data_poes_poes(collocations, M, ...
%       name1, date1, data1, name2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  As returned by collocate or collocate2
%   M               matrix      As returned by colloc_process_poes_poes
%                               (ignored here)
%   name1           string      name of satellite 1 (ignored here)
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule (ignored here)
%   data1           structure   Fields for brightness temperature should be
%                               present
%   name2           string      name of satellite 2 (ignored here)
%   date2           1x5 vector  As date1, but for secondary granule
%                               (ignored here)
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$

% row and column numbers
r1 = collocations(:, 1);
c1 = collocations(:, 2);
r2 = collocations(:, 3);
c2 = collocations(:, 4);

% index for direct addressing
i1 = sub2ind(size(data1.lat), r1, c1);
i2 = sub2ind(size(data2.lat), r2, c2);

% reshape so that I can use direct addressing for brightness temperatures

tb1 = reshape(shiftdim(data1.tb, 1), [5 numel(data1.lat)]);
tb2 = reshape(shiftdim(data2.tb, 1), [5 numel(data2.lat)]);

%% store info

M = [tb1(:, i1)' tb2(:, i2)'];