% function: atovs_griddata
% format atovs_griddata(tmp_dir, data_dir_l1b, data_dir_l1c, list_name, fov, fileout);
%
% Description: averange the data for a number of file specified in
% list_name, and grids in on in a step of 1.5deg in latitude and longitude
% the data ( a array of matrix, one for each channel) is written into a 'mat' file 'fileout+grided'
%
% Input: tmp_dir - directory for the temporal data
%        data_dir_l1b - directory where the l1b data is found
%        data_dir_l1c - directory where the l1c data is found, or should be written in if it does not exists yet
%        list_name - a list containing the name of the data files
%        fov - selected viewing angle
%        fileout -  basic name for the file where the final data should be written
% Output: structure for gridded data : lat, lon, mean, standard
%         deviation, and no. of pixels for each box

%--------------------------------------------------------------------------
function data_grided=atovs_griddata_mashrab34(tmp_dir,data_dir_1b , data_dir_1c, list_name,fov, fileout)
%-------------------------------------------------------------------------

% create the lat and lon uniform grid in steps if 1.5 deg, the same
% as in ECMWF data.
lon_grid= -180:1.5: 180-0.75;
lat_grid=  -90:1.5:90;

% create the lat and lon boxes
for i =1:length(lat_grid)
    m_lon(i,:)=lon_grid;
end
for i =1:length(lon_grid)
    m_lat(:,i)=lat_grid';
end


% create a temporary directory to write into the  convert data from l1b to
% l1c
if ~exist(tmp_dir,'dir')
    system(['mkdir ', tmp_dir]);
end

% delete the file listing the wrong data if this already exists; 
if exist([list_name, '_wrong_data'], 'file')
    system(['rm ',  list_name, '_wrong_data']);
end

% get and read the names for the data files included in list
fid =fopen(list_name, 'r');
i=0;
j=0;
while ~feof(fid);
   j=j+1; % keeps the total number of files
    dummy_str  = [fgets(fid)];
    s= strread(dummy_str, '%s', 'delimiter', '/'); % separate the names;
    n =length(s);
    dummy= (s{n-3}(length(s{n-3})-3:length(s{n-3}))); 
    years_2         = (s{n}(14:15)); % the last two digits of the
                                     % year
    if  ~strcmp(dummy(length(dummy)-1: length(dummy)), (years_2))
      % just a trick to ignore the files which are in a wrong
       disp(['file no. ', num2str(j),' in wrong directory !!']);
    else 
       i=i+1;
      data_files{i}    = dummy_str;				     
    years(i) =str2num(s{n-3}(length(s{n-3})-3:length(s{n-3}))); %year
    month(i)= str2num(s{n-2}); % month
    days(i)=str2num(s{n-1}); % day						    
    days_nr(i)      = str2num(s{n}(16:18));   % day of record
    t_start_h(i)    = str2num(s{n}(21:22));   % starting hour
    t_start_m(i)     = str2num(s{n}(23:24));  % minutes
    t_end_h(i)      = str2num(s{n}(27:28)) ;  % ending hour
    t_end_m(i)      = str2num(s{n}(29:30));   % minutes
    end
end
disp(['Total number of right files: ', num2str(j)]);

disp(['Number of right files: ', num2str(length(data_files))]);

% sort the files after the starting time
for i =1:length(data_files)
    sort_time(i) =datenum(years(i), month(i), days(i), t_start_h(i), 	t_start_m(i), 0);
end
[sort_time, I] =sort(sort_time);
data_files=data_files(I);
years =years(I);
month=month(I);
days=days(I);
days_nr =days_nr(I);
t_start_h = t_start_h(I);
t_start_m = t_start_m(I) ;
t_end_h = t_end_h(I);
t_end_m = t_end_m(I) ;


% some characteristics for each noaa instrument
if findstr(char(s{n}), 'HIR') % for HIRS instrument
    N=56; % no. of scan lines
    nr_channel=20; % no. of chanels
elseif findstr(char(s{n}), 'AMA') % for AMSU A instrument
    N=32; % no. of scan lines
    nr_channel=15;
elseif findstr(char(s{n}), 'AMB') % for AMSU B instrument
    N=90; % no. of scan lines
    nr_channel=5;
else
    % !!! add here more if you want to use other instrument (no data for
    % others insruments is available so far
    display('Unknown instrument!  If you have a new instrument you should add it here.');
end

% some initializations
sum_tbs=zeros(length(lat_grid), length(lon_grid),nr_channel);
n_pixel=zeros(length(lat_grid), length(lon_grid),nr_channel);
n_pix=zeros(length(data_files), nr_channel);
mean_tbs=zeros(length(lat_grid),length(lon_grid));
mean_comb=zeros(length(lat_grid),length(lon_grid), nr_channel);
var_comb=zeros(length(lat_grid),length(lon_grid), nr_channel);
data_grided.tb_mean=[]; % keeps the averaged data for all channels (structure of matrices, one for each channel)
i_wrong=0; % index for wrong data files

time_pixel_end=0; %keeps the time for the last pixel recorded in a
%file

% loop over the data
for i=1:length(data_files);
    disp(['Doing file ', num2str(i), '  from ', num2str(length(data_files))]);
    %------------------------------------------------
    % convert the files from l1b to l1c
    file_dummy1b=(deblank(char(data_files{i})));
    file_dummy1c=(file_dummy1b(1:length(file_dummy1b)-3));
    name_1b=  [data_dir_1b, file_dummy1b];
    name_1c = [data_dir_1c, file_dummy1c];
    if exist(name_1c,'file'); % if the converted file already exists
        err_1c=0;
        file_out=name_1c;
    else % convert the file
        file_out=[tmp_dir, '/', 'TMPOR'];
        str_dummy= ['zamsu2l1c.sh ', name_1b, ' ', file_out];
        str_dummy=['system(','''','ssh marvin ' , str_dummy , '''', ');'];
        err_1c=eval(str_dummy);
    end
    
    if err_1c==0 % if no error occur during converting file
        % read the converted file
        [data, err] = atovs_read_data( file_out);
        if err==0&length(data.time)>0 % if no error occured during reading the l1c data file
            % moves the data for the 180 deg. longitudes in the other side
            I_lon=find(data.lon>=179.25); %
            data.lon(I_lon)= data.lon(I_lon)-360;   
            
            % take only the data for the selected fov and the simetric angle
            C1(:, :)=  data.tb(fov, :,:);
            C2(:, :)= [ data.tb(N-fov+1, :,:)];
            C = [C1,C2];
            clear data.tb;
            data.tb=C; clear C C1 C2;
            data.lat = [data.lat(fov,:), data.lat(N-fov+1,:)];
            data.lon = [data.lon(fov, :), data.lon(N-fov+1,:)];
            data.time = [data.time, data.time];
            dummy_time=datenum(years(i), month(i), days(i), 0, 0, 1e-3*(data.time));
            
            %trown away the time overlaped data
            I_time = find(dummy_time>time_pixel_end);
            data.tb= data.tb( :, I_time );
            data.lon=data.lon(:, I_time);
            data.lat=data.lat(:, I_time);
            data.time=data.time(I_time);
            time_pixel_end= max(dummy_time);
            clear dummy_time;
            data.tb=data.tb';
            
            % loop over the data to find the pixel included in each box
            for i_box=1:size(data.lat,2)
                lat_i=find(data.lat(i_box)>=lat_grid-0.75 & data.lat(i_box)<lat_grid+0.75);
                lon_i=find(data.lon(i_box)>=lon_grid-0.75 & data.lon(i_box)<lon_grid+0.75);
                
                if ( ~isempty(lat_i)& ~isempty(lon_i))
                    
                    %check if a pixel belongs to a box
                    % chech the data for each channel. This is done
                    % because for some channels a wrong data is found
                    % (default value of -9999). This values are not
                    % excluded together with the calibration
                    % values
                    for j=1:nr_channel
                        if data.tb(i_box,j)>0
                            n_pix(i, j)=n_pix(i, j)+1; 
                            n_pixel_now=1;
                            sum_ch = sum(data.tb(i_box,j)); % TB of the chosen pixel
                            var_now=var(data.tb(i_box,j)); % variance(in fact =0)
                            mean_now = sum_ch/n_pixel_now; %mean=TB in this case of the correcponding pixel
                            mean_new=  (mean_comb(lat_i, lon_i,j).* n_pixel(lat_i, lon_i,j)+sum_ch)...
                                ./(n_pixel(lat_i, lon_i,j)+n_pixel_now); % the apdated mean
                            % calculate the variance
                            if  n_pixel_now+n_pixel(lat_i, lon_i,j)>1
                                var_new = (n_pixel(lat_i, lon_i,j)*(mean_comb(lat_i, lon_i,j)- mean_new)^2+...
                                    n_pixel_now.*( mean_now- mean_new)^2 +...
                                    var_comb(lat_i, lon_i,j)*(n_pixel(lat_i, lon_i,j)-1))...
                                    /(n_pixel_now+n_pixel(lat_i, lon_i,j)-1);
                                var_comb(lat_i, lon_i,j)=var_new;
                            end
                            mean_comb(lat_i, lon_i,j)=mean_new; % update the mean
                            sum_tbs(lat_i, lon_i,j) = sum_tbs(lat_i, lon_i,j) + sum_ch;%sum the value into the box
                            n_pixel(lat_i, lon_i, j) =n_pixel(lat_i, lon_i,j)+n_pixel_now; % sum to the number of pixels
                        else
                        end
                    end
                end
            end
        end
    clear data
else
      fid=fopen([list_name, '_wrong_data'], 'a'); % write the data which could have not be read or converted
             fprintf(fid, '%s\n', deblank(data_files{i}));
      fclose(fid);
        end
end

% calculate now the mean for each box and each channel and put in into the
% structure
for i=1:nr_channel
    n_dummy(:,:) = n_pixel(:,:, i);
    data_grided.pixel{i}(:,:) =  n_dummy;
    data_grided.tb_mean{i}= reshape(mean_comb(:, :,i), size(m_lat,1)*size(m_lat,2),1);
    data_grided.std{i}= reshape(sqrt(var_comb(:, :,i)), size(m_lat,1)*size(m_lat,2),1);
    data_grided.pixel{i}= reshape(n_dummy,size(m_lat,1)*size(m_lat,2), 1) ;
end
data_grided.lon = reshape(m_lon, size(m_lon,1)*size(m_lon,2), 1);
data_grided.lat = reshape(m_lat, size(m_lat,1)*size(m_lat,2), 1);
evalsave= ['save ', fileout, '_grided.aa ', 'data_grided'];
eval(evalsave);

return
