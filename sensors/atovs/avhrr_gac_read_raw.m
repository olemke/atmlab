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
record_size = 4608;

[def_head, def_line] = avhrr_define_gac_l1b;

fp = fopen(fn, 'r', 'b'); % b=big-endian
c = onCleanup(@()fclose(fp));

%% read header fields

data_head = cell2struct(cellfun(@(v) readfield(fp, v, def_head), fields_head, 'UniformOutput', false), fields_head, 2);

%% read data fields

if isscalar(lines) % interpret as 1,...,lines
    lines = 1:lines;
end
% pre-allocate
if ~isempty(lines)
    data_line(lines(end)) = cell2struct(cell(1, length(fields_line)), fields_line, 2);
end
i = 0;
for lineno = lines
    i = i + 1;
    data_line(i) = cell2struct(cellfun(@(v) readfield(fp, v, def_line, record_size*lineno), fields_line, 'UniformOutput', false), fields_line, 2);
end

if exist('data_line', 'var')
    varargout = {data_head, data_line};
else
    varargout = {data_head};
end

end
function val = readfield(fp, f, def, varargin)
% readfield Reads field from AVHRR GAC
%
% 
offset = optargs(varargin, {0});
fseek(fp, offset+def.(f).Start_Octet-1, 'bof');
ws = def.(f).Word_Size;
nw = def.(f).Number_of_Words;
skip = 0;
nbits = num2str(ws*8);
switch def.(f).Data_Type
    case 'i'
        type = ['int' nbits '=>int' nbits];
        sz = nw;
    case 'u'
        type = ['uint' nbits '=>uint' nbits];
        sz = nw;
    case 'c'
        type = 'uint8=>char';
        sz = uint16(ws)*nw;
    otherwise
        error('atmlab:avhrr_gac_read_raw', ...
            'Field %s has unknown data type: %s', ...
            f, def.(f).Data_Type);
end
val = fread(fp, sz, type, skip);
end
