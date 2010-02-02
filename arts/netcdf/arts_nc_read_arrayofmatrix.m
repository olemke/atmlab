% NC_READ_ARTS_ARRAYOFMATRIX   Read ArrayOfMatrix from ARTS NetCDF file.
%
%    Reads an ArrayOfMatrix from a NetCDF file saved with Arts.
%
% FORMAT   ret = nc_read_arts_arrayofmatrix(filename)
%        
% OUT   ret      ArrayOfMatrix
%       
% IN    filename Name of NetCDF input file.

% 2010-02-01   Created by Oliver Lemke.

function ret = nc_read_arts_arrayofmatrix (filename)

ncid = netcdf.open (filename, 'NOWRITE');

varid = netcdf.inqVarId (ncid, 'Matrix_nrows');
nr = netcdf.getVar (ncid, varid);

varid = netcdf.inqVarId (ncid, 'Matrix_ncols');
nc = netcdf.getVar (ncid, varid);

varid = netcdf.inqVarId (ncid, 'ArrayOfMatrix');
m = netcdf.getVar (ncid, varid);
netcdf.close (ncid);

startelem = 1;

ret=cell(length(nr),1);
for i = 1:length(nr)
    endelem = startelem + nr(i)*nc(i) - 1;
    ret{i} = reshape (m(startelem:endelem), nc(i), nr(i))';
    startelem = endelem + 1;
end

