function data = colloc_read_collocation_cpr_poes(file)

% colloc_read_collocation_cpr_poes Read CPR/MHS collocation for collocating
%
% IN
%
%   file        string      path to collocations file
%
% out
%
%   data        structure   data with time, lat, lon
%
% This will actually read the meandata file, as MHS-pixels are of interest.
%
% $Id$

% find corresponding meandata-file as well
p = strfind(file, 'collocations');
p = p(end)+12;
meandatafile = [file(1:p) 'meandata' file(p:end)];

M_c = load(file);
M_m = load(meandatafile);
c = colloc_config('cols_cpr_poes');

rows = M_m.data_averaged(:, c.meandata.FIRST);
data.lat = M_c.collocations(rows, c.overlap.B_LAT);
data.lon = M_c.collocations(rows, c.overlap.B_LONG);
[~, ~, ~, h, mi, s] = unixsecs2date(M_c.collocations(rows, c.overlap.B_TIME));
data.time = compensate_wraparound(3600*h + 60*mi + s);
data.file = file;

% (old implementation)
% % store rows of unique MHS pixels so that I can later if I know AVHRR pixel
% % i collocates with unique-MHS pixel j, what row this corresponds with in
% % the original collocation  data. This means that the values for
% % 'collocations' are in itself not useful, but need to be fed into
% % data.rows in order to get the rows in the cloudsat collocation file
% % WARNING: unique returns the index to the /last/ one and should, because
% % find_avhrrmean_for_cscolmean depends on this!
% [M.collocations, data.rows] = unique(M.collocations(:, [c.overlap.B_TIME c.overlap.B_I c.overlap.B_C c.overlap.B_LAT c.overlap.B_LONG]), 'rows');
% [~, ~, ~, h, mi, s] = unixsecs2date(M.collocations(:, 1));
% data.lat = M.collocations(:, 4);
% data.lon = M.collocations(:, 5);
% data.time = compensate_wraparound(3600*h + 60*mi + s);
% data.file = file;