function save_nc_gmt_input (filename, data, lat, lon)
%
% SAVE_NC_GMT_INPUT Write ungridded data for GMT input.
%
% Write ungridded data for GMT input to a netcdf file. Used for nearneighbor and
% others as a replacement for ascii input.
%
% IN    filename Name of NetCDF file.
% IN    data          vector variable.
% IN    lat           vector variable.
% IN    lon           vector variable.
%
% 2010-03-04   Created by Oliver Lemke

if ~isequal(numel(data),numel(lon),numel(lat))
    error('atmlab:input','This data is expected to be ungridded')
end

ncid = netcdf.create (strrep(filename,'~',getenv('HOME')), 'NC_CLOBBER');

len = netcdf.defDim (ncid, 'numel', length(data));

varid1 = netcdf.defVar (ncid, 'x', 'double', len);
varid2 = netcdf.defVar (ncid, 'y', 'double', len);
varid3 = netcdf.defVar (ncid, 'z', 'double', len);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid1, lon);
netcdf.putVar (ncid, varid2, lat);
netcdf.putVar (ncid, varid3, data);

netcdf.close (ncid);