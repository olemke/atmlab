function M = colloc_process_data_cpr_mhs(~, M_c, sat1, ~, data1, sat2, date2, data2)

% colloc_process_data_cpr_mhs Gather collocation data to store for CPR+MHS
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data: in this case, brightness temperatures.
%
% Because this m-file has the same format as other colloc_process_data_* files
% (so that the caller doesn't need to know what is being collocated), some of
% the arguments are ignored.
%
% FORMAT
%
%   M = process_data_cpr_mhs(collocations, date1, data1, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  (ignored) as returned by collocate
%   M_c             Nxp matrix  As returned by process_cpr_mhs
%   sat1            string      name of 1st satellite
%   date1           1x5 vector  (ignored) starting time of 1st satellite
%   data1           structure   As returned by read_cpr
%   sat2            string      name of 2nd satellite
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As returned by read_mhs
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$

% prepare
c = colloc_config('cols_cpr_mhs');
n = size(M_c, 1);
M = nan*zeros(n, c.data.NCOLS);

% row and column numbers
r1 = M_c(:, c.overlap.C_I);
r2 = M_c(:, c.overlap.B_I);
c2 = M_c(:, c.overlap.B_C);

%% cloudsat data
M(:, c.data.ROIWP) = data1.RO_ice_water_path(r1);
M(:, c.data.dROIWP) = data1.RO_ice_water_path_uncertainty(r1);
M(:, c.data.IOROIWP) = data1.IO_RO_ice_water_path(r1);
M(:, c.data.dIOROIWP) = data1.IO_RO_ice_water_path_uncertainty(r1);

%% AMSUB/MHS data

% index for direct addressing
i2 = sub2ind(size(data2.lat), r2, c2);

% reshape so that I can use direct addressing for brightness temperatures
tb = reshape(shiftdim(data2.tb, 1), [numel(data2.lat) 5]);

M(:, c.data.MHS) = tb(i2, :);

%% AMSUA, HIRS
% those require reading additional files

amsua_file = find_datafile_by_date(date2, sat2, 'amsua');
read_amsua = colloc_config('read_amsua');
% TODO/FIXME: optimise this, I already read amsua for the earlier processing
amsua_data = read_amsua(amsua_file); 

hirs_file = find_datafile_by_date(date2, sat2, 'hirs');
read_hirs = colloc_config('read_hirs');
hirs_data = read_hirs(hirs_file); % TODO/FIXME: to be optimised as for amsua

% AMSU_A
ai = sub2ind(size(amsua_data.lat), M_c(:, c.overlap.A_I), M_c(:, c.overlap.A_C));
tb = reshape(shiftdim(amsua_data.tb, 1), [numel(amsua_data.lat) 15]);
M(:, c.data.AMSU_A) = tb(ai, :);

% HIRS
hi = sub2ind(size(hirs_data.lat), M_c(:, c.overlap.H_I), M_c(:, c.overlap.H_C));
tb = reshape(shiftdim(hirs_data.tb, 1), [numel(hirs_data.lat) 20]);
M(:, c.data.HIRS) = tb(hi, :);

%% MSPPS


% Apply scalefactor.
% From
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c9/sec96-3.htm
% divide by the scalefactor to get kg/m^2
% we want g/m^2 so we multiply by 1000/scalefactor
try
    mspps_file = find_datafile_by_date(date2, sat2, 'mspps');
    scalefactor = 1000/double(cell2mat(hdfread(mspps_file, 'IWP_SCAL')));
    MSPPS_IWP_raw = hdfread(mspps_file, 'IWP');
    MSPPS_IWP = ((MSPPS_IWP_raw<0) + (MSPPS_IWP_raw>0)*scalefactor) .* double(MSPPS_IWP_raw);
    M(:, c.data.MSPPS_IWP) = MSPPS_IWP(i2);
catch ME
    switch (ME.identifier)
        case {'MATLAB:HDF:invalidFile', 'atmlab:find_datafile_by_date'}
            logtext(colloc_config('stderr'), ...
                'WARNING: Unable to process mspps: %s\n', ME.message);
        otherwise
            ME.rethrow();
    end
end


