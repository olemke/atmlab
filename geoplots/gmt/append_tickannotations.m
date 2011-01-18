function file = append_tickannotations(file,annotations)
%% append_tickannotations
%
% Purpose: function that makes it easy to change the legend annotations	to
% whatever you	want.
%
% IN: 1) file: '%s', the color table file in which to add the annotations.
%     2) annotations: cell, '%s' must have the same number of elements as there
%     are levels.
% 
% OUT: file '%s'
%
% $Author$
% $Date$

% READ OLD FILE
fid = fopen(file);
out=textscan(fid,'%s','whitespace','\n');
fclose(fid);

% CHECK INPUT
if ~( sum(~cellfun('isempty', regexp(out{1},'^[0-9]'))) == length(annotations)) 
    error('atmlab:input','Number of annotations must match number of ticks')
end

fid = fopen(file,'w'); x = 1;
for i = 1:length(out{1})
    if ~isempty(regexp(out{1}{i},'^[0-9]', 'once'))
        fprintf(fid,'%s',sprintf('%s ; %s\n',out{1}{i},annotations{x}));
        x=x+1;
    else
        fprintf(fid,'%s\n',out{1}{i});
    end
end
fclose(fid);