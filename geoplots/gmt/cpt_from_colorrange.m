function filecpt = cpt_from_colorrange(colorrange)
%% cpt_from_colorrange
%
% Purpose: Make a colortable file with desired color values and ranges, that
% will be passed in the makecpt function that uses this input to make a color
% that can be used by GMT.
%
% USAGE: e.g. file = cpt_from_colorrange(struct('colors',{{{0.25,'255/255/255'},{0.75,'0/0/0'}}},'color_model','RGB'))
%
% IN: structure.
%    colors = {{value,'color'},{value2,'color2'},etc.}; (manditory)
%    color_model = 'RGB', 'HSV'
%
% OUT: filename
%
% 2011-02-21 created by Salomon Eliasson

% COLOR MODEL
if ~isfield(colorrange,'color_model')
    model = 'RGB';
else
    model = colorrange.color_model;
end
C = colorrange.colors;

% format to print z-slice in cptfile
strtot = '%.2f\t%s\t%s\t%s\t%.2f\t%s\t%s\t%s\n';
    
filecpt = sprintf('colorrange.cpt');
fid = fopen(filecpt,'w');

% header
fprintf(fid,'%s\n','#cpt file created by: cpt_from_colorrange.m');
fprintf(fid,'%s\n',sprintf('#COLOR_MODEL = %s',model));

% make z-slices (val1 Red1 Green1 Blue1 val2 Red2 Green2 Blue2)
for ii = 1:length(C)-1
    val   = C{ii}{1}; val2 = C{ii+1}{1};
    color = gmt_splitstring(C{ii}{2},'/');
    color2 = gmt_splitstring(C{ii+1}{2},'/'); 
    fprintf(fid,strtot,...
        val, color{1}, color{2}, color{3},...
        val2,color2{1},color2{2},color2{3});
end

fclose(fid);