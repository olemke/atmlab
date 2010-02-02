% LOADNCVAR   Loads a specific varaible from a NetCDF file
%
%    The function enables direct loading of a named variable from a NetCDF file.
%
% FORMAT   x = loadncvar( filename, varname )
%        
% OUT   ret        Loaded variable.
% IN    filename   Name of NetCDF file.
%       varname    Name of variable.

% 2010-02-02   Created by Oliver Lemke.


function ret = loadncvar( filename, varname )
  
ncid = netcdf.open (filename, 'NOWRITE');

varid = netcdf.inqVarId (ncid, varname);
ret = netcdf.getVar (ncid, varid);
netcdf.close (ncid);

