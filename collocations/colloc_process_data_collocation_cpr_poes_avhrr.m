function M_d = colloc_process_data_collocation_cpr_poes_avhrr(~, M_c, ...
    ~, ~, ~, ...
    ~, ~, data2)

% colloc_process_data_collocation_cpr_poes_avhrr Gather collocation data 
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data.
%
% FORMAT
%
%   M_d = colloc_process_data_hirscs_poes(collocations, M_c, ...
%         name1, date1, data1, name2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  (not used here)
%   M_c             matrix      As returned by
%                               colloc_process_collocation_cpr_poes_avhrr
%   name1           string      name of satellite 1
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule
%   data1           structure   Fields for brightness temperature should be
%                               present
%   name2           string      name of satellite 2
%   date2           1x5 vector  As date1, but for secondary granule
%   data2           structure   As data1, but for secondary granule.
%
% OUT
%
%   M_d             Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$


c = colloc_constants('cols_collocation_cpr_mhs_avhrr');

% row and column numbers; use M_c, not collocations, because the latter are
% sorted and the former aren't, and this has to be in the same order
r2 = M_c(:, c.overlap.AVHRR_ROW);
c2 = M_c(:, c.overlap.AVHRR_COL);

% index for direct addressing
%i1 = sub2ind(size(data1.lat), r1, c1);
i2 = sub2ind(size(data2.lat), r2, c2);

M_d = nan*zeros(size(M_c, 1), c.data.NCOLS);
M_d(:, c.data.AVHRR([1 2 4 5])) = [...
    data2.albedoCh1(i2), ...
    data2.albedoCh2(i2), ...
    data2.brightnessTempCh4(i2), ...
    data2.brightnessTempCh5(i2)];

% there is some confusion about channel 3: even if albedoCh3A is fully
% flagged and brightnessTempCh3B contains values, those values are
% (sometimes? consistently? not sure yet) in the range [0, 100] and thus
% actually albedo's.

if max(max(data2.albedoCh3A)) > 0 % not all flagged
    M_d(:, c.data.AVHRR(3)) = data2.albedoCh3A(i2);
else
    M_d(:, c.data.AVHRR(3)) = data2.brightnessTempCh3B(i2);
end
