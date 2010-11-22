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
%    Note: If you wish to load the whole netcdf file into a structure use
%          struct = loadncfile (filename), instead.
%
% FORMAT   [ret, attr] = loadncvar( filename, varname )
%        
% OUT   ret        Loaded variable.
% OUT   attr       Global attributes.
% IN    filename   Name of NetCDF file.
%       varname    Name of variable.

% 2010-02-02   Created by Oliver Lemke.
% 2010-10-11   Modified by Gerrit Holl.
% 2010-11-22   Modified by Salomon Eliasson

function [ret, attr] = loadncvar( filename, varname )
  
ncid = netcdf.open (filename, 'NOWRITE');

if (nargout>1)
  attr = getncattributes (ncid);
else
  attr = [];
end

if ischar(varname)
    varid = netcdf.inqVarID (ncid, varname);
    ret = netcdf.getVar (ncid, varid);
elseif iscell(varname)
    for v = varname
        varid = netcdf.inqVarID (ncid, v{1});
        ret.(genvarname(v{1})) = netcdf.getVar (ncid, varid);
    end
else
    error 'varname must be either of type char or cell';
end

netcdf.close (ncid);