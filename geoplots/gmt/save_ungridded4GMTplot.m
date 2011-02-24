function in = save_ungridded4GMTplot(in,field)
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
% 4/12-2009 created by Salomon Eliasson

% if I don't want to plot data
if isfield(in,'nodata')&&in.nodata
    return
end
if isnan(in.outdir)
    outdir = '.';
else outdir = in.outdir;
end
in.ungriddedfile = [outdir,'/',in.filename '.nc'];

save_nc_gmt_input (in.ungriddedfile, in.(field), in.lat, in.lon);
