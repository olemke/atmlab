function S = common_read_patmosx(file, varargin)

% common_read_patmosx Read Patmos-x data in the common format (see README)
%
% This file reads data from a PATMOS-x file (actually 2 files) and rearranges the fields to
% the common format.
%
%
% IN
%
%   file    string      Path to gzipped file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = common_read_patmosx(file, varargin)
%
% $Id: common_read_patmosx.m 7583 2012-02-10 06:59:11Z seliasson $

core_fields = {'latitude','longitude','scan_line_time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% read both ascending and descending files
S1 = gunzip_and_read_patmosx(file,all_fields);
S1.latitude = repmat(S1.latitude',[1,length(S1.longitude)]);
S1.longitude = repmat(S1.longitude,[size(S1.latitude,1),1]);

if regexp(file,'_asc_')
    file2 = strrep(file,'asc','des');
else
    file2 = strrep(file,'des','asc');
end

S2 = gunzip_and_read_patmosx(file2,all_fields);
S2.latitude = repmat(S2.latitude',[1,length(S2.longitude)]);
S2.longitude = repmat(S2.longitude,[size(S2.latitude,1),1]);


S = concatinateDatafields(S1,S2);
clear Sasc Sdec
% rename some fields

% construct time axis with same dimensions
S.time = S.scan_line_time*3600; % is in hours

S.lon = double(S.longitude(:));
S.lat = double(S.latitude(:));
S.version = 'version 5 (hardcoded)'; % will be written to NetCDF.
S = rmfield(S,core_fields);

% get rid of negative time!
index = S.time>0;
for F = fieldnames(S)'
    if ~isequal(size(index),size(S.(F{1}))), continue; end
    S.(F{1}) = S.(F{1})(index);
end
% add filename

S.path = file;

% get epoch. 
% 
info = find_info_from_granule('patmosx', file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));


%%%%%%%%%%%%%
% SUBFUNCTION

function S = gunzip_and_read_patmosx(file,all_fields)


% make TEMPDIR & cleanup after I'm done.
tmpdir = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));

[unused,tmpfile] = fileparts(file);
filename = fullfile(tmpdir,tmpfile);
[unused,test] = exec_system_cmd(sprintf('gunzip -c %s > %s',file,filename),1,true);

if logical(test)
    error(['atmlab:' mfilename ':file'],'error gunzipping\n%s',file)
end

% read the data
S  = read_clavrx_hdf(filename,all_fields);

function S = concatinateDatafields(Sasc,Sdec)
%% concatinateDatafields
% 
%
% For each field make sure they are concatinated and then sorted by time (if applicable)
%

% FLATTEN the data
sz = size(Sasc.scan_line_time);
for F = fieldnames(Sasc)'
    if isequal(size(Sasc.(F{1})),sz)
        S.(F{1}) = [Sasc.(F{1})(:);Sdec.(F{1})(:)];
    end
end

% SORT the data in ascending time
[S.scan_line_time,index] = sort(S.scan_line_time);
for F = fieldnames(Sasc)'
    if isequal(size(Sasc.(F{1})),sz) && ~strcmp(F{1},'scan_line_time')
        S.(F{1}) = [Sasc.(F{1})(:);Sdec.(F{1})(:)];
    end
end