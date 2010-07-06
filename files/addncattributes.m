% ADDNCATTRIBUTES   Add global attributes to a NetCDF file.
%
%    Adds the given global attributes to a NetCDF file.
%
%    e.g.: addncattributes(ncid, {{'attr1', 'value1'}, {'attr2', 2}})
%
% FORMAT   addncattributes(ncid, attributes)
%        
% IN    ncid        Name of NetCDF file.
% IN    attributes  Cell array of name/value pair cells.

% 2010-07-06   Created by Oliver Lemke.

function addncattributes (ncid, attributes)

for i = attributes
    if (length(i{:}) ~= 2)
        error ('Attributes have to given as name/value pairs');
    end
    
    value = i{:}(2);
    netcdf.putAtt (ncid, netcdf.getConstant('GLOBAL'), ...
                   char(i{:}(1)), value{:});
end

