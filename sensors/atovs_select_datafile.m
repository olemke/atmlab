% FUNCTION:atovs_select_datafile
%
% FORMAT:  [DataSelectedFiles, day_meas] =
% atovs_select_datafile(dir_data, satellite, instrument_tip, year,
% month, day, time);
%----------------------------------------------------------------
%
% Description:
% This script makes a selection of the data files for noaa satellites
% The criteria are:
% 1. satellite platform: e.g., noaa15, noaa16, etc.
% 2. instrument: e.g., amsua, amsub, hirs,....
% 3. year: e.g., 2000
% 4. month: e.g., 6 means Jun.
% 5. day:   e.g., 7
% 6: time of record. One can give a specific time or a interval.
% Input: - directory where the data is found
%        - satellite, instrument, year, month, day, time. 
%          If no input is specified then this should be given interactive
%         setting day = 'all' and/or time='all' takes all the days
%         and/or time from a specific month 
% Output:- DataSelectedFiles 
%          It contains a structure array with the selected names of files.
%        - If no output is specified then the data is written in files:
%          a file for each satellite, instrument,
%          year, month, day and full selected time period
%          -day_meas: index for the day (=-1 if the data started to be
%          recorded the previous day, =1 otherwise.
% 
%
% 18.05.2004 by Carmen Verdes
%------------------------
function [DataSelectedFiles, day_meas] = atovs_select_datafile(dir_data, satellite, instrument_tip, year, month, day, time);
%-------------------------------
% Check the input
%
% give interactive the  input parameters if no input is specified'
if nargin<=1;
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
        '      time= [230, 300] means data taken between 2:30 and 3:00', ...
        '      time= [200 300; 800 1200 ]  means data taken between 2:00-3:00 and 8:00-12:00'));
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

% loop over:
% 1: satellite
% 2: instrument
% 3: year; 
% 4: month
% 5: day
I_final=0; % initialization
for is=1:length(satellite);
    for ii=1:length(instrument_tip);    
        for iy = 1:length(year);
            % get the name of the index file, in the data directory
            % a index file exists for each specific year,
            % instrument and satellite
            index_name = [dir_data,'noaa',num2str(satellite(is)), '_', ...
                    char(instrument_tip{ii}),'_',num2str(year(iy)), '.index'];
            % open the file     
            fid =fopen(index_name, 'r');
            
            % take just the last two digits of the year (only the last two
            % digits are in file name)
            year_dummy=num2str(year(iy));
            year_dummy =year_dummy(length(year_dummy)-1:length(year_dummy));
            year_short(iy)=str2num(year_dummy);
            clear year_dummy;
            
            % get the dates: month, day, year, no. of day, starting
            % and ending time for each file included in the index file
            i=0;
            while ~feof(fid);
                i=i+1;
                data_files{i}    = [fgets(fid)];
                s= strread(data_files{i}, '%s', 'delimiter', '/'); % separate the names;            
                months(i)        = str2num(s{2});
                days_all(i)      = str2num(s{3});
                years(i)         = str2num(s{4}(14:15));
                days_nr(i)       = str2num(s{4}(16:18));
                t_start_all(i)   = str2num(s{4}(21:25));
                t_end_all(i)     = str2num(s{4}(27:30));
            end
            fclose(fid); 
            
            % make a selection for the specific year, month and
            % day.
            I=[];
            for im = 1:length(month);
                if strcmp(day, 'all'); % the case when all the days
                                       % from a month are taken		  
                    I   = [find(year_short(iy)== years&month(im)==months)];
                else
                    for id=1:length(day); % case when only a
                                          % specific day is taken
                        I   =  find(year_short(iy)== years&month(im)== ...
                            months&day(id)==days_all);
                    end
                end
                 %               
                % if end time is after the mid-night and start
                % time before then put 24 instead 00; 
                for i=1:length(I)
                    if t_start_all(I(i))>t_end_all(I(i));
                        t_end_all(I(i))=t_end_all(I(i))+2400;
                    end
                end
                
                % find the previous days
                for i =1:length(I)
                    I_previous = find(days_nr(I(i))-1 ==days_nr);
                end
                
                % check if for one of the selected days, the measurement
                % started already in the previous day.    
                if I_previous
                    for j =1:length(I_previous)
                        if t_start_all(I_previous(j))>t_end_all(I_previous(j))
                            I =[I_previous(j),I];
                        end
                    end
                end
                
                % files selected for year, day..., and full time;
                data_files_selected = (deblank(data_files(I)));
                t_start = t_start_all(I);
                t_end   = t_end_all(I);
                days =days_all(I);
                clear I;
                if strcmp(time, 'all'); % case when all the
                                     % measurements from one day are considered
                    DataSelectedFiles = data_files_selected   ;
	       time_dummy='all';	    
                else
                    I=[];
                    time_dummy=[];
                    if size(time,2)==2
                        % loop over periods of specified times
                        for i=1:size(time,1)
                            time_dummy = [time_dummy, num2str(time(i,1)),...
                                    'to', num2str(time(i,2)), '-'];
                           % check for each measurement time 
                            for j=1:length(t_start)
                                I=[];
                                if t_start(j)<t_end(j); 
                                    if (t_start(j)<= time(i,1)&t_end(j)>=time(i,2));
                                        % check if the full
                                        % selected time period is
                                        % inside the interval time
                                        % of one measurement      
                                        I = [I, j];                                        
                                    elseif (t_start(j)>= time(i,1)&t_end(j)<=time(i,2))&(t_start(j)<t_end(j));
                                        % check if selected time interval includes
                                        % the full measurement time interval 
                                        I = [I, j];
                                     elseif (t_start(j)<= time(i,1)&t_end(j)>=time(i,1));
                                        % check if selected end starting inside of a
                                        % measurement interval time
                                        I = [I, j];
                              elseif (t_start(j)<= time(i,2)&t_end(j)>=time(i,2));
                                        % check if selected end time inside of a
                                        % measurement interval time
                                        I = [I, j];
                                       else
                                        % case of measurement interval time does
                                        % not contain the any period of selected time
                                        %out_text(1,['[', num2str(t_start(j)),', ', num2str(t_end(j)), '] does not content the selected time']);
                                    end
                                    day_meas(I)=1;
                                else
                                    % handle the case when the measurements
                                    % started in previous day should be
                                    % considered.
                                    if (t_end(j)>time(i,1)|t_end(j)>time(i,2))& (days(j)==day(id)-1);
                                        I = [I, j];
                                        out_text(1, ['time selected [', num2str(time(i,1)),', ', num2str(time(i,2)),']includes [', num2str(t_start(j)),', ', num2str(t_end(j)), '] ','(previous day)']); 
                                        day_meas(j)=-1;
                                    end
                                end
                                if ~isempty(I)
                                    I_final=I_final+1;
                                    DataSelectedFiles{I_final} = char([char(data_files_selected(I))]);
                                end
                               
                            end
                            clear I
                        end
                    end
                end
                % if there is no output then write the data into files 
                % a file for each satellite, instrument, year, month,
                % day and full selected time period. 
                if nargout==0
                    name_file = ['List-','noaa', num2str(satellite(is)), '_', char(instrument_tip{ii})];                  
                    name_file = [name_file, '-Y:', name_year];
                    name_file=[name_file, '-M:', name_month];
                    if strcmp(day, 'all')
                        name_file=[name_file, '-D:' day];                      
                        if  strcmp(time, 'all')
                            name_file  = [name_file, '-T:', time];
                        else
                            name_file = [name_file, 'time-', time_dummy];
                        end
                    else                     
                        name_file=[name_file, '-D:'   name_day, '-time-',time_dummy];
                    end
                    fid=fopen(name_file, 'a');
                    for i=1:length(DataSelectedFiles);
                        fprintf(fid, '%s\n',[deblank(char(DataSelectedFiles(i)))]);
                    end
                    fclose(fid);
                    clear  DataSelectedFiles;
                    I_final=0;
                end
            end
        end
    end
end

% subfunction;

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
