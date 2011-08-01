% LOADNCFILE2   Loads a NetCDF file into a structure.
%
%    The function enables direct loading of a whole NetCDF file into
%    a structure. It uses the new high-level NetCDF API provided by Matlab
%    2011a and later.
%
%    WARNING: Non-global attributes not implemented yet.
%
%    Attributes are stored in ret.global_attributes.(attname)
%
% FORMAT   ret = loadncfile2( filename )
%        
% OUT   ret        Loaded NetCDF file structure.
% IN    filename   Name of NetCDF file.

% 2010-02-10   Created by Oliver Lemke.


function ret = loadncfile2( filename )
  
nci = ncinfo (filename);

for i = {nci.Attributes.Name}
   ret.global_attributes.(genvarname(i{1})) = ...
       ncreadatt (filename, '/', i{1});
end

for i = {nci.Variables.Name}
   svarname = genvarname(i{1});
   ret.(svarname) = ncread (filename, i{1});
end
