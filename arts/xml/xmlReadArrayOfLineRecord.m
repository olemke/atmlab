% Reads an ARTS cataloguefrom an XML file.
%
%    Internal function that should never be called directly.
%    Use *xmlLoad* instead.
%
% FORMAT   result = xmlReadArrayOfLineRecord(fid,attrlist,itype,ftype,binary,fid2)
%
% OUT   result     Array
% IN    fid        File descriptor of XML file
% IN    attrlist   List of tag attributes
% IN    itype      Integer type of input file
% IN    ftype      Floating point type of input file
% IN    binary     Flag. 1 = binary file, 0 = ascii
% IN    fid2       File descriptor of binary file

% 2002-09-25   Created by Oliver Lemke.

function result = xmlReadArrayOfLineRecord(fid,attrlist,itype,ftype,binary,fid2)

nelem = str2double (xmlGetAttrValue (attrlist, 'nelem'));

%=== Check that this is a ARTSCAT file and the version number is correct
%
s = xmlGetAttrValue (attrlist, 'version');

%
if ~strncmp( s, 'ARTSCAT-', 8 )
    error('An ARTS line file must start with "ARTSCAT-"');
end
%
vers = s(9:end);
%
if vers == '3'
    result = read_artscat3(fid, nelem);
elseif vers == '5'
    result = read_artscat5(fid, nelem);
else
    error( 'atmlab:xmlLoad:xmlReadArrayOfLineRecord', ...
        'The line file has not the correct version number\n (it should be 3 or 5)');
end

if length(result) ~= nelem
    error('Number of lines in catalogue (%d) doesnt match nelem attribute (%d)', length(result), nelem);
end

return



%------------------------------------------------------------------------------

function lines = read_artscat3(fid, nelem)

%=== Read lines
%

S = {};
while numel(S) < 2 && ~feof(fid)
    S = strsplit( strtrim( fgets( fid )), ' ' );
end

n = 0;

% Preallocate line record structure array
result(1:nelem) = struct(...
    'version', 3, ...
    'name', '', ...
    'f', '', ...
    'psf', '', ...
    'i0', '', ...
    't_i0', '', ...
    'elow', '', ...
    'agam', '', ...
    'sgam', '', ...
    'nair', '', ...
    'nself', '', ...
    't_gam', '', ...
    'n_aux', '', ...
    'df', '', ...
    'di0', '', ...
    'dagam', '', ...
    'dsgam', '', ...
    'dnair', '', ...
    'dnself', '', ...
    'dpsf', '', ...
    'qcode', '', ...
    'qupper', '', ...
    'qlower', '', ...
    'if', '', ...
    'ii0', '', ...
    'ilw', '', ...
    'ipsf', '', ...
    'iaux', '' ...
    );

while numel(S) > 1
    
    n = n + 1;
    
    result(n).name = S{2};
    result(n).f = sscanf( S{3}, '%f' );
    result(n).psf = sscanf( S{4}, '%f' );
    result(n).i0 = sscanf( S{5}, '%f' );
    result(n).t_i0 = sscanf( S{6}, '%f' );
    result(n).elow = sscanf( S{7}, '%f' );
    result(n).agam = sscanf( S{8}, '%f' );
    result(n).sgam = sscanf( S{9}, '%f' );
    result(n).nair = sscanf( S{10}, '%f' );
    result(n).nself = sscanf( S{11}, '%f' );
    result(n).t_gam = sscanf( S{12}, '%f' );
    result(n).n_aux = sscanf( S{13}, '%f' );
    n_aux      = result(n).n_aux;
    
    % Aux variables are handled below otherwise
    for i = 14:13+n_aux
        result(n).(sprintf('aux%d', i-13)) = sscanf( S{i}, '%f' );
    end
    
    result(n).df = sscanf( S{14+n_aux}, '%f' );
    result(n).di0 = sscanf( S{15+n_aux}, '%f' );
    result(n).dagam = sscanf( S{16+n_aux}, '%f' );
    result(n).dsgam = sscanf( S{17+n_aux}, '%f' );
    result(n).dnair = sscanf( S{18+n_aux}, '%f' );
    result(n).dnself = sscanf( S{19+n_aux}, '%f' );
    result(n).dpsf = sscanf( S{20+n_aux}, '%f' );
    if numel(S) > 20+n_aux
        result(n).qcode = sscanf( S{21+n_aux}, '%s' );
    elseif numel(S) > 21+n_aux
        result(n).qupper = sscanf( S{22+n_aux}, '%s' );
    elseif numel(S) > 22+n_aux
        result(n).qlower = sscanf( S{23+n_aux}, '%s' );
    elseif numel(S) > 23+n_aux
        result(n).if = sscanf( S{24+n_aux}, '%s' );
    elseif numel(S) > 24+n_aux
        result(n).ii0 = sscanf( S{25+n_aux}, '%s' );
    elseif numel(S) > 25+n_aux
        result(n).ilw = sscanf( S{26+n_aux}, '%s' );
    elseif numel(S) > 26+n_aux
        result(n).ipsf = sscanf( S{27+n_aux}, '%s' );
    elseif numel(S) > 27+n_aux
        result(n).iaux = sscanf( S{28+n_aux}, '%s' );
    end
    
    S = textscan( strtrim( fgets( fid )), '%s', 'delimiter', ' ' );
    S = S{1};
end

lines = result;
return

function lines = read_artscat5(fid, nelem)

%=== Read lines
%
S = '';
while numel(S) < 2 && ~feof(fid)
    S = fgetl( fid );
end

% Preallocate line record structure array
result(1:nelem) = struct(...,
    'version', 5, ...
    'name', '', ...
    'f', '', ...
    'i0', '', ...
    't_i0', '', ...
    'elow', '', ...
    'a', '', ...
    'gupper', '', ...
    'glower', '', ...
    'PB_type', '', ...
    'PB_values', '', ...
    'LM_type', '', ...
    'LM_values', '', ...
    'QN', '', ...
    'PF_type', '', ...
    'PF_values', '' ...
    );

known_tags = {'PB ', 'LM ', 'PF ', 'QN '};
for n = 1:nelem
    [tokens, pos] = textscan(S, '@ %s %f %f %f %f %f %f %f');
    result(n).name = tokens{1}{1};
    result(n).f = tokens{2};
    result(n).i0 = tokens{3};
    result(n).t_i0 = tokens{4};
    result(n).elow = tokens{5};
    result(n).a = tokens{6};
    result(n).gupper = tokens{7};
    result(n).glower = tokens{8};
    S_tags = S(pos+1:end);
    values = textscan(S_tags, '%s', 'delimiter', known_tags);
    values = values{1}';
    tag_pos = 1;
    for t = 2:length(values)
        tag = S_tags(tag_pos:tag_pos+2);
        current_values = values{t};
        if strcmp(tag, 'PB ')
            type_length = 1;
            while current_values(type_length) ~= ' ' && type_length < length(current_values)
                type_length = type_length + 1;
            end
            result(n).PB_type = sscanf(current_values(1:type_length), '%s');
            result(n).PB_values = sscanf(current_values(type_length+1:end), '%f');
        elseif strcmp(tag, 'LM ')
            result(n).LM_type = sscanf(current_values(1:3), '%s');
            result(n).LM_values = sscanf(current_values(4:end), '%f');
        elseif strcmp(tag, 'PF ')
            result(n).PF_type = sscanf(current_values(1:3), '%s');
            % Ignore first number, it is just the number of elements
            pf_values = sscanf(current_values(4:end), '%f');
            result(n).PF_values = pf_values(2:end);
        elseif strcmp(tag, 'QN ')
            result(n).QN = current_values;
        else
            error('atmlab:xmlLoad:xmlReadArrayOfLineRecord', ...
                'Unknown catalog tag: %s', tag);
        end
        tag_pos = tag_pos + 3 + length(values{t});
    end
    S = fgetl( fid );
end

if ~strcmp(strtrim(S), '</ArrayOfLineRecord>')
    error('atmlab:xmlLoad:xmlReadArrayOfLineRecord', ...
        'Unexpected end of catalog. Expected </ArrayOfLineRecord> tag, got\n%s', S);
end

lines = result;
return
