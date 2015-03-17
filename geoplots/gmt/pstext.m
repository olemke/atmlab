function command = pstext(file,in,placement)
% PSTEXT Make text to overlay GMT plot
% (x, y, size, angle, fontno, justify, text) see help gmt_plot
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         placement %s      string command about where to pu the map
%         (common to all commands)
%
% OUT     command str     string command for systemcall of pstext
%
% Created by Salomon Eliasson
% $Id$

lat     = {in.lat};
lon     = {in.lon};
fontsize   = {in.fontsize};
angle   = {in.angle};
fontnum = {in.fontnum};
justify = {in.justify};
txt     = {in.text};
color   = {in.color};
% Create an intermediate file that contains the required input per
% row/entry

commonOpt = sprintf('-R -J -K -O %s >> %s.ps',placement,file);

command = {};

for i = 1:length(txt)
    txtfile = ['pstextfile' num2str(i)];
    fid=fopen(txtfile,'w'); cleanup = onCleanup(@() fclose(fid));
    
    % Create an intermediate file that contains the required input per
    fprintf(fid,'%g %g %g %g %g %g %s',...
        lon{i},lat{i},fontsize{i},angle{i},fontnum{i},justify{i},txt{i});
    
    
    clr = color{i};
    command{i} = sprintf('pstext %s -G%g/%g/%g %s',txtfile,clr(1),clr(2),clr(3),commonOpt);
    clear cleanup
end
