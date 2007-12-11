% function atovs_plot_gmt(filein, fileout, channel, quantity);
% maps noaa data using the gmt script
% you need gmt_map.sh script!!!!!!!! 
% input: filein:   name of the mat file containing the data structure
%                  to be plotted (data.lon, data.lat, data.tb,
%                  data.pixel, data.std)
%        fileout:  basic name for the ps file
%        channel:  channel to be plotted
%        quantity: this can be 'tb' (for brightness temperature),
%                 'std' (standard deviation), 'pixel' (no. of pixel
%                 in each box)
% output: a map
function atovs_plot_gmt(filein, fileout, channel, quantity);


lab=['ch', num2str(channel),'**', upper( quantity)]; % create label for colorbar
load(filein, '-mat'); % load the data file
str_dummy=['A(:,:) = data_grided.', quantity, '(:,:,',num2str(channel),');'];
eval(str_dummy);

% get the maximum and minimul (used for the scale)
Tmax=floor(max(max(A))); Tmin=ceil(min(min(A(find(A))))); 

% create a Netcdf file requested by gmt script
fileout=[fileout, '-channel:', num2str(channel), '-', quantity];
grdwrite(A, [-180, 178.5, -90, 90], fileout);

% run the gmt script
str_dummy = ['system(','''','gmt_map.sh' , ' ', num2str( Tmin-.5) , ' ',num2str(Tmax+.5), ...
        ' ', fileout,' ', fileout, '.ps ', lab '''', ');' ];
eval(str_dummy);

% delete the netcdf file
system(['rm ', fileout]);