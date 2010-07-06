% GETNCATTRIBUTES   Get global attributes from a NetCDF file.
%
%    Gets all global attributes from a NetCDF file.
%
% FORMAT   attr = getncattributes(ncid)
%        
% IN    ncid        ID of NetCDF file.

% 2010-07-06   Created by Oliver Lemke.

function attr = getncattributes (ncid)

[nd, nv, ngatts, ui] = netcdf.inq (ncid);
if (ngatts)
    attr = cell (1, ngatts);
    for i = 1:ngatts
        attname = netcdf.inqAttName (ncid, netcdf.getConstant('GLOBAL'), i-1);
        attvalue = netcdf.getAtt (ncid, netcdf.getConstant('GLOBAL'), attname);
        attr{i} = {attname, attvalue};
    end
else
    attr = [];
end
