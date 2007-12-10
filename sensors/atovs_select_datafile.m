% FUNCTION:atovs_select_datafile
%
% FORMAT:  DataSelectedFiles = ...
% atovs_select_datafile(dir_data, satellite, instrument_tip, year,...
% month, day, time);
%----------------------------------------------------------------
%
% Description:
% This script makes a selection of the data files for noaa satellites
%
% The criteria are:
% 1. satellite platform: e.g., noaa15, noaa16, etc.
% 2. instrument: e.g., amsua, amsub, hirs,....
% 3. year: e.g., 2000
% 4. month: e.g., 6 means Jun.
% 5. day:   e.g., 7
% 6: time of record. One can give a specific time or a interval.

% The scripts creates first a name of a existing index file listing the files
% which exists in each directory for one specific satellite,
% instrument and year.
% For example: a file called 'noaa15_hirs_2003.index' will lists
% all the data files which exists for the satellite=15 (i.e. noaa15),
% instrument=1 (i.e. HIRS), and year =2001.
% After all the files for the specific satellite, instrument and
% year are read from index file the selection is done for the
% specified months, days and time periods
%
%===========================================================
% Input:
%===========================================================
% - dir_data: directory where the data is found
%
% - satellite: could be 14, (i.e. noaa14), 15 (i.e. noaa15),
%              16 (noaa15) and 17 (noa17)
%
% - instrument:set to 1 means HIRS (see bellow)
%              HIRS=1,        MSU=2,    SSU=3,    AMSU-A=4,
%              AMSU-B=5, AVHRR=6', 'SSMI=7,        VTPR1=8,
%              VTPR2=9,  TMI=10,   SSMIS=11, AIRS=12' ,  'HSB=13,
%              MODIS=14, ATSR=15,  MHS=16,   IASI=17,  MVIRI=18',
%              'SEVIRI=19,     GOES-imager=20
%              GOES-sounder=21', 'GMS imager=22  FY2-VISSR=23
%              FY1-mvisr=24';
%
% - year:      e.g. 2001, 2002, 2003
%
% - months:    e.g 1=Jan, 2=Feb, etc. One3 can give more month
%              e.g. [10, 12} selects the dta for Oct. and Dec.
%
% - day:       the date , one can give more dates e.g. [10, 11,..]
%              This can also be set to 'all' which means that all the
%              days from a specific month are selected
%
% time:        period of time for which the measurements are selected:{t_start, t_end}
%              e.g. {'0000', '0200'}(first two digits are for hour and last
%              ones are for minutes), means the measurements between 0:00 and
%              2:00.  The selected starting time should be smaller than
%              ending time.It is between 0000 and 2400. If the ending time
%              is taken 2500 then it means that data is selected until 100
%              seconmd day (24+1)
% setting month ='all', and/or,  day = 'all' and/or time='all'  takes all the months and/or all days
% and/or all time day period
%
% If no input is specified then this should be given interactive
%============================================================
% Output:
%============================================================
% - DataSelectedFiles : It contains a structure array with the
%                       selected names of files.
%
% If no output is specified then the data is written in files:
% a file for each satellite, instrument,year, month, day and full
% selected time period
%
% 18.05.2004 by Carmen Verdes
%--------------------------------------------------------------------------
function DataSelectedFiles =...
    atovs_select_datafile_2(dir_data, satellite, instrument_tip, year, month, day, time);
%-------------------------------
% Check the input
%
% give interactive the  input parameters if no input is specified'
if nargin<=1;
    out_text(3, str2mat('Directory where the data is found'));
    dir_data = input('Data directory: ');

    out_text(3, str2mat('Which satellite do you want', 'noaa15 = 15, noaa16 = 16, noaa17 = 17'));
    satellite = input('Satellite: ');

    out_text(3,str2mat('Which instrument type do you want for this satellite?' ,...
        'HIRS=1,        MSU=2,    SSU=3,    AMSU-A=4, AMSU-B=5, AVHRR=6',...
        'SSMI=7,        VTPR1=8,  VTPR2=9,  TMI=10,   SSMIS=11, AIRS=12' ,...
        'HSB=13,        MODIS=14, ATSR=15,  MHS=16,   IASI=17,  MVIRI=18',...
        'SEVIRI=19,     GOES-imager=20      GOES-sounder=21',...
        'GMS imager=22  FY2-VISSR=23        FY1-mvisr=24'));
    instrument_tip = input('Instrument: ');

    out_text(3,str2mat('Which year?', '1998, 1999, 2000, 2001, 2003'));
    year = input('Year: ');

    out_text(3,str2mat('Which month?', 'Jan=1 Feb=2 Mar=3 Apr=4 May=5 Jun=6 Jul=7 Aug=8',...
        'Sep=9 Oct=10  Nov 11 Dec =12 ', ...
        'You can give it as a vector, e.g. .[1, 5] means data for Jan, Mai'));
    month = input('Month: ');

    out_text(3,str2mat('Which day?', 'Give the date', ...
        'You can give it as a vector, e.g. .[1, 5, 8]'));
    day = input('Day: ');

    out_text(3,str2mat('Which time period do you want?', 'E.g.' ,...
        ['      time= {','''','0230','''',',', '''','0300','''','} means data taken between 2:30 and 3:00']));
    time = input('Time: ');
end

% Convert the number of instrument to the name;
Instruments = {'hirs' 'msu' 'ssu' 'amsua' 'amsub' 'avhrr' 'ssmi' 'vtpr2' 'tmi' 'ssmis' ...
    'airs', 'hsb' 'modis' 'mhs' 'iasi' 'mviri' 'seviri' 'GOES-imager' 'GOES-sounder' ...
    'gms-imager' 'fy2-vissr' 'fy1-mvisr'};
instrument_tip = Instruments(instrument_tip);

% create some strings for the name of output file (when no input is
% given and list of selected files is written into a file)
name_year='';
name_month='';
name_day ='';
for iy= 1:length(year)
    name_year =[name_year, num2str(year(iy)), '-'];
end
for im= 1:length(month)
    name_month =[name_month, num2str(month(im)), '-'];
end
for id= 1:length(day)
    name_day =[name_day, num2str(day(id)), '-'];
end

if  strcmp(time, 'all')
    name_time  = ['-T:', time];
else
    name_file = ['-T:', time{1}, 'to', time{2}];
end
% get the name of the index file, in the data directory
% a index file exists for each specific year,
% instrument and satellite
index_name = [dir_data,'noaa',num2str(satellite), '_', ...
    char(instrument_tip),'_',num2str(year), '.index'];
% open the file
fid =fopen(index_name, 'r');



% get the dates: month, day, year, no. of day, starting
% and ending time for each file included in the index file
i=0;
while ~feof(fid);
    i=i+1;
    data_files{i}    = [fgets(fid)];
    s= strread(data_files{i}, '%s', 'delimiter', '/'); ...
        % separate the names;
    n=length(s);
    years(i) =str2num(s{n-3}(length(s{n-3})-3:length(s{n-3}))); %year
    months(i)= str2num(s{n-2}); % month
    days(i)=str2num(s{n-1}); % day
    days_nr(i)      = str2num(s{n}(16:18));   % day of record
    t_start_h(i)    = str2num(s{n}(21:22));   % starting hour
    t_start_m(i)     = str2num(s{n}(23:24));  % and minutes
    t_end_h(i)      = str2num(s{n}(27:28)) ;  % ending hour
    t_end_m(i)      = str2num(s{n}(29:30));   %  and minute

    % consider the case when the measurements continues after
    % the midnight
    if t_start_h(i)>t_end_h(i)
        t_end_h(i)=t_end_h(i)+24;
    end
end

fclose(fid);

% convert the starting and ending time to jul. time
t_start_jul = datenum(years, 0, days_nr,   t_start_h,  t_start_m, 0);
t_end_jul  = datenum(years, 0, days_nr,   t_end_h,  t_end_m, 0);

% case when all the month from one year are taken
if strcmp(month, 'all');
    month=1:12;
end


if strcmp(time, 'all');
    time_h(1)=0;
    time_m(1)=0;
    time_h(2)=24;
    time_m(2)=0;
else
    time_h(1)=str2num(time{1}(1:2));
    time_m(1)=str2num(time{1}(3:4));
    time_h(2)=str2num(time{2}(1:2));
    time_m(2)=str2num(time{2}(3:4));
end

% considering the case when the selected data should start in one day in
% continue after the midnight
% previous day, e.g. 2300 and finish second day
if time_h(1)>time_h(2)
    out_text(1, 'ERROR: the start time should be smaller than the end time!');
    return;
end
I=[];
for im=1:length(month)

    % take all the days from specified months
    if  strcmp(day, 'all');
        days=1:datenum(year, month(im)+1,0,0,0,0)-datenum(year, month(im),0,0,0,0)
    end

    clear time;
    for id =1:length(days)
        time(1)= datenum(year, month(im), days(id), time_h(1), time_m(1),0);
        time(2)= datenum(year, month(im),days(id) ,  time_h(2),  time_m(2),0) ;
        % check if selected time is inside of a
        % measurement interval time
        I_dummy=find(t_start_jul<time(1)&t_end_jul>time(2));
        if I_dummy
            for j=1:length(I_dummy)
                I_=find(I_dummy(j)==I);
            end
            if isempty(I_)
                I= [I, I_dummy]; clear I_dummy; clear I_
            end
        end
        % check if selected end time inside of a
        % measurement interval time
        I_dummy=find(t_start_jul<time(1)&t_end_jul<time(2)&t_end_jul>time(1));
        if I_dummy
            for j=1:length(I_dummy)
                I_=find(I_dummy(j)==I);
            end
            if isempty(I_)
                I= [I, I_dummy]; clear I_dummy;clear I_
            end
        end
        % check if the full selected time period is
        % inside the interval time of one measurement
        I_dummy=find(t_start_jul>=time(1)&t_end_jul<=time(2));
        if I_dummy
            for j=1:length(I_dummy)
                I_=find(I_dummy(j)==I);
            end
            if isempty(I_)
                I= [I, I_dummy]; clear I_dummy; clear I_;
            end
        end

        % check if selected starting time inside of a
        % measurement interval time
        I_dummy=find(t_start_jul>time(1)&t_start_jul<time(2)&t_end_jul>time(2));

        if I_dummy
            for j=1:length(I_dummy)
                I_=find(I_dummy(j)==I);
            end
            if isempty(I_)
                I= [I, I_dummy]; clear I_dummy; clear I_
            end
        end

    end

end
DataSelectedFiles=data_files(I);

% subfunction;
% if there is no output then write the data into files
% a file for each satellite, instrument, year, month,
% day and full selected time period.
if nargout==0
    name_file = ['List-','noaa2', num2str(satellite), '_', char(instrument_tip)]
    name_file = [name_file, '-Y:', name_year];
    name_file=[name_file, '-M:', name_month];
    name_file=[name_file, '-D:', name_day, name_time];
    fid=fopen(name_file, 'a');
    for i=1:length(DataSelectedFiles);
        fprintf(fid, '%s\n',[deblank(char(DataSelectedFiles(i)))]);
    end
    fclose(fid);
    clear  DataSelectedFiles;

end

function out_text(level,  s )
% this is very similar to out.m from ami but it ignores the report
% file status
% out.m does not want to work (?)
ncols = 70;

if ischar(s)

    for i = 1:size(s,1)

        fprintf('| ');

        %Indention
        for j = 1:(level-1)
            fprintf('  ');
        end

        fprintf('%s',s(i,:));

        for j = 1:(ncols-length(s)-(level-1)*2-3)
            fprintf(' ');
        end

        fprintf('|\n');

    end


else

    %=== Start line
    if s > 0
        fprintf('\n/');
        for j = 1:(ncols-2)
            fprintf('-')
        end
        fprintf('\\\n');

        %=== Brake line
    elseif s == 0
        fprintf('|');
        for j = 1:(ncols-2)
            fprintf('-');
        end
        fprintf('|\n')

        %=== End line
    else
        fprintf('\\');
        for j = 1:(ncols-2)
            fprintf('-');
        end
        fprintf('/\n');
    end

end
