function filename = png2pdf(filename,opt)
%% png2pdf
%
%
% Salomon.Eliasson@smhi.se

if nargin ==1
    opt=struct();
end

default.density = 50;
default.quality = 100;
default.outdir  = '.';
opt = optargs_struct(opt,default);

% first crop away edges
try
    crop(filename)
catch ME
    disp(ME)
    disp('Continuing uncroppped')
end



[a,b]=fileparts(filename);

exec_system_cmd(sprintf('convert -density %i -quality %i %s/%s.png %s/%s.pdf',...
    opt.density,opt.quality,a,b,opt.outdir,b));

filename = sprintf('%s/%s.pdf',opt.outdir,b);