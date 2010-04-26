% ARTS_NC_WRITE_MATRIX   Write Matrix to ARTS NetCDF file.
%
%    Writes a Matrix to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_matrix(filename,v)
%        
% IN    filename Name of NetCDF file.
% IN    v        Matrix variable.

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_matrix (filename, v)

ncid = netcdf.create (filename, 'NC_CLOBBER');

s = size(v);
rdim = netcdf.defDim (ncid, 'nrows', s(1));
cdim = netcdf.defDim (ncid, 'ncols', s(2));

varid = netcdf.defVar (ncid, 'Matrix', 'double', [cdim rdim]);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, v');

netcdf.close (ncid);
