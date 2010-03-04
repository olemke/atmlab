function se = save_ungridded4GMTplot(se,field)
%
% Purpose: To create an ascii file containing (lon,lat,value)
%          This function is called if the data is not gridded!
%
% Recommended:
%          se.filename: specify a file name with se.filename. a default file name is
%                   generated in the absence of this
%
% Indata: A structure containing:
%         vectors of lat,lon,data. all the same length
%
% Outdata: se.ungriddedfile: the full path of the generated.ungriddedfile
%
% 4/12-2009 Salomon Eliasson

% if I don't want to plot data
if isfield(se,'nodata')&&se.nodata
    return
end

se.ungriddedfile = [se.outdir,'/',se.filename '.nc'];

save_nc_gmt_input (se.ungriddedfile, se.(field), se.lat, se.lon);
