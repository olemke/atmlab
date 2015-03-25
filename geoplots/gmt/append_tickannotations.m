function file = append_tickannotations(file,annotations)
%% APPEND_TICKANNOTATIONS change legend annotations to whatever you want.
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
% Created by Salomon Eliasson
% $Id$

% READ OLD FILE
fid = fopen(file);
s = 0; i =1;
out = cell(1,10);
while s ~= -1
    s=fgetl(fid);
    out{i}=s;
    i = i+1;
end
fclose(fid);
out = out(1:i-2);

fid = fopen(file,'w'); x = 1;
for i = 1:length(out)
    if ~isempty(regexp(out{i},'^[-+]?[0-9]*\.?[0-9]+', 'once'))
        fprintf(fid,'%s',sprintf('%s ; %s\n',out{i},annotations{x}));
        x=x+1;
    else
        fprintf(fid,'%s\n',out{i});
    end
end
fclose(fid);