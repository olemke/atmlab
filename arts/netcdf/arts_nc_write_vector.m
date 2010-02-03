% ARTS_NC_WRITE_VECTOR   Write Vector to ARTS NetCDF file.
%
%    Writes a Vector to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_vector(filename)
%        
% IN    filename Name of NetCDF file.
% IN    v        Vector variable.

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_vector (filename, v)

ncid = netcdf.create (filename, 'NC_CLOBBER');

ndim = netcdf.defDim (ncid, 'nelem', length(v));

varid = netcdf.defVar (ncid, 'Vector', 'double', ndim);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, v);

netcdf.close (ncid);
