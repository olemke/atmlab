% LOADNCFILE   Loads a NetCDF file into a structure.
%
%    The function enables direct loading of a whole NetCDF file into
%    a structure.
%
%    Global attributes are stored in ret.global_attributes.(attname)
%    Variable attributes are stored in ret.attributes.(varname).(attname)
%    Variables are stored in ret.(varname)
%
% FORMAT   ret = loadncfile( filename )
%        
% OUT   ret        Loaded NetCDF file structure.
% IN    filename   Name of NetCDF file.

% 2010-02-10   Created by Oliver Lemke.


function ret = loadncfile( filename )
  
ncid = netcdf.open (filename, 'NOWRITE');

[scrap,nvars,ngatts] = netcdf.inq(ncid);

for i = 0:ngatts-1
   attname = netcdf.inqAttName (ncid, -1, i);
   ret.global_attributes.(genvarname(attname)) = ...
       netcdf.getAtt (ncid, -1, attname);
end

for i = 0:nvars-1
   [varname, scrap, scrap, natts] = netcdf.inqVar (ncid, i);
   svarname = genvarname(varname);
   ret.(svarname) = netcdf.getVar (ncid, i);
   for j = 0:natts-1
       attname = netcdf.inqAttName (ncid, i, j);
       ret.attributes.(svarname).(genvarname(attname)) = ...
           netcdf.getAtt (ncid, i, attname);
   end 
end

grpids = netcdf.inqGrps (ncid);
for gid = grpids
    ret = catstruct(ret, read_group(ncid, gid));
end

netcdf.close (ncid);


function grp = read_group(ncid, gid)

varids = netcdf.inqVarIDs(gid);
grpname = genvarname(netcdf.inqGrpName(gid));
for i = varids
   [varname, scrap, scrap, natts] = netcdf.inqVar (gid, i);
   svarname = genvarname(varname);
   grp.(grpname).(svarname) = netcdf.getVar (gid, i);
   for j = 0:natts-1
       attname = netcdf.inqAttName (gid, i, j);
       grp.(grpname).attributes.(svarname).(genvarname(attname)) = ...
           netcdf.getAtt (gid, i, attname);
   end 
end

