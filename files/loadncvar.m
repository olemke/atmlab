% LOADNCVAR   Loads a specific variable(s) from a NetCDF file
%
%    The function enables direct loading of a named variable from a NetCDF
%    file. varname can be either a string to load one variable or a cell
%    array of several variable names.
%
%    When multiple varnames are given the return value is a structure
%    containing the loaded variables.
%
%    lat = loadncvar( 'mydata.nc', 'lat');
%    grid = loadncvar( 'mydata.nc', { 'lat', 'lon' } );
%    
%
% FORMAT   ret = loadncvar( filename, varname )
%        
% OUT   ret        Loaded variable.
% IN    filename   Name of NetCDF file.
%       varname    Name of variable.

% 2010-02-02   Created by Oliver Lemke.


function ret = loadncvar( filename, varname )
  
ncid = netcdf.open (filename, 'NOWRITE');

if ischar(varname)
    varid = netcdf.inqVarId (ncid, varname);
    ret = netcdf.getVar (ncid, varid);
elseif iscell(varname)
    for v = varname
        varid = netcdf.inqVarId (ncid, char(v));
        ret.(genvarname(char(v))) = netcdf.getVar (ncid, varid);
    end
else
    error 'varname must be either of type char or cell';
end

netcdf.close (ncid);