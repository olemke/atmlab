function se = create_ascii4gmtplot(se,field)
%%   create_ascii4gmtplot
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
% Outdata: se.asciifile: the full path of the generated asciifile
%
% 4/12-2009 Salomon Eliasson

% if I don't want to plot data
if isfield(se,'nodata')&&se.nodata
    return
end

se.asciifile = [scodes('TMP_DIR'),'/',se.filename '.asc'];
[fid,message] = fopen(se.asciifile,'w');
if fid == -1
    error(message)
end
if numel(size(se.(field))) == 3
    se.(field) = squeeze(se.(field));
end

%% Write to file
for i = 1:length(se.lon)
    fprintf(fid,'%f %f %f\n',se.lon(i),se.lat(i),se.(field)(i));
end
