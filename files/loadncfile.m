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
% IN    filename   Name of NetCDF file. (can be gzipped)

% 2012-04-10   Updated by Salomon
% 2010-02-10   Created by Oliver Lemke.

function ret = loadncfile( filename )

% UNCOMPRESS first if gzipped
if strcmp(filename(end-2:end),'.gz')
	tmpdir = create_tmpfolder;
	gfile = gunzip(filename,tmpdir);
	filename = gfile{1};
	c= onCleanup(@() rmdir(tmpdir,'s'));
end
  
ncid = netcdf.open (filename, 'NOWRITE');

cleanupObject = onCleanup(@() netcdf.close (ncid));

[~,nvars,ngatts] = netcdf.inq(ncid);

for i = 0:ngatts-1
   attname = netcdf.inqAttName (ncid, -1, i);
   ret.global_attributes.(genvarname(attname)) = ...
       netcdf.getAtt (ncid, -1, attname);
end

for i = 0:nvars-1
   [varname, ~, ~, natts] = netcdf.inqVar (ncid, i);
   svarname = genvarname(varname);
   ret.(svarname) = nc_read_varid(ncid,i);
   for j = 0:natts-1
       attname = netcdf.inqAttName (ncid, i, j);
       ret.attributes.(svarname).(genvarname(attname)) = ...
           netcdf.getAtt (ncid, i, attname);
   end 
end

if (which('netcdf.inqGrps'))
	grpids = netcdf.inqGrps (ncid);
	for gid = grpids
    	ret = catstruct(ret, read_group(ncid, gid));
	end
else
    warning('atmlab:loadncfile:groupsunsupported', ...
        'This Matlab version does not support NetCDF groups.');
end

end

function grp = read_group(~, gid)

varids = netcdf.inqVarIDs(gid);
grpname = genvarname(netcdf.inqGrpName(gid));
for i = varids
    [varname, ~, ~, natts] = netcdf.inqVar (gid, i);
    svarname = genvarname(varname);
    grp.(grpname).(svarname) = netcdf.getVar (gid, i);
    for j = 0:natts-1
        attname = netcdf.inqAttName (gid, i, j);
        grp.(grpname).attributes.(svarname).(genvarname(attname)) = ...
            netcdf.getAtt (gid, i, attname);
    end
end

end