function varargout = avhrr_gac_read_raw(fn, varargin)

% avhrr_gac_read_raw Read raw (uncalibrated, unprocessed) AVHRR GAC
%
% Read uncalibrated, unprocessed AVHRR GAC data.
%
% WARNING! Work in progress, still in alpha! Subject to change!
%
% For valid field names, call <a href="matlab:help avhrr_define_gac_l1b">avhrr_define_gac_l1b</a>
%
% FORMAT
%
%   [data_head, data_line] = avhrr_gac_read_raw(filename, fields_head, fields_line, lines)
%
% IN
%
%   filename    string      Path to file to read data from
%   fields_head cell-string Fields from header to return
%   fields_line cell-string Fields from each line to return
%   lines       array       Lines to return (-1=all, 0=none)
%
% OUT
%
%   data_head   struct      With the required fields
%   data_line   TBD (struct with arrays? array of structures? struct array?)
%
% EXAMPLE
%
% >> data_head = avhrr_gac_read_raw('/local/gerrit/tmp/NSS.GHRR.NN.D08221.S1247.E1434.B1658586.GC', ...
%                   {'avh_h_siteid', 'avh_h_startdatayr', 'avh_h_dataname', 'avh_h_satid'})
% 
% data_head = 
% 
%         avh_h_siteid: [3x1 char]
%    avh_h_startdatayr: 2008
%       avh_h_dataname: [42x1 char]
%          avh_h_satid: 7
%
% $Id$

[fields_head, fields_line, lines] = optargs(varargin, {struct, struct, 0});

[def_head, def_line] = avhrr_define_gac_l1b;
data_head = struct;
data_line = struct;

fp = fopen(fn, 'r', 'b'); % big-endian
c = onCleanup(@()fclose(fp));

%% read header fields

for field = fields_head
    f = field{1};
    fseek(fp, def_head.(f).Start_Octet-1, 'bof');
    ws = def_head.(f).Word_Size;
    nw = def_head.(f).Number_of_Words;
    switch def_head.(f).Data_Type
        case 'i'
            type = ['int' num2str(ws*8)];
            sz = nw;
        case 'u'
            type = ['uint' num2str(ws*8)];
            sz = nw;
        case 'c'
            type = 'uint8=>char';
            sz = ws*nw;
        otherwise
            error('atmlab:avhrr_gac_read_raw', ...
            'Field %s has unknown data type: %s', ...
            f, def_head.(f).Data_Type);
    end

    data_head.(f) = fread(fp, sz, type);
end

varargout = {data_head};
