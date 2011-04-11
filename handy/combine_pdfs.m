function outfile = combine_pdfs(pdffiles, options)
% COMBINE_PDFS Combine several PDF files on one page
%
% USAGE: outfile = combine_pdfs(pdffiles, options) 
%
%e.g.file = combine_pdfs(files,struct('cols',[2 2 2 2 1],..)
%
% PURPOSE:  Merge several pdf's (one page each) into a pdf file
%
% IN:       pdffiles            cell; Each element contains the path to a
%                               file.
%                               OR
%                               string;  unix regular expression from which
%                               find <regexp> will get a list of files.
%                               e.g pdffiles = figs/*{CAlow,CAmiddle,CAhigh}*
%
%           options.            structure; contains the following options:
%         KEY:    fieldname     |type |description                  | default
%                 cols          |%d [] number of columns per row    | 2
%                 vspace        |%d    space between rows           | 1 (cm)
%                 hspace        |%d    space between columns        | 1 (cm)
%                 filename      |%s    name of outfile              | 'out'
%                 outdir        |%s    directory for output         | gmtlab('outdir')
%                 valign        |%s    vertical alignment           | c
%                               |      c = centered, b = bottom,    |
%
% OUT:      outfile             string; the fullpath to the pdffile created
%
% NOTE: The files are appended left to right and from top to bottom. This
%       function assembles the PDFs using pdfinfo and pdflatex.
%       Arguments may be:
%            1) option.cols can alternativley be a vector
%               with the number of columns for each row. In that case, the
%               sum of this vector must match the number of pdf files.
%
% 2011-04-11 Created by Oliver Lemke based on an idea by Salomon.

if ~nargin, error('atmlab:input','Needs input. Read help section'); end
if nargin == 1, options = struct; end

%% Set defaults and use them if not specified by user
default.cols          = 2;
default.vspace        = 1;
default.hspace        = 1;
default.valign        = 'm';
default.outdir        = gmtlab('outdir');

options = optargs_struct(options,default);
default.filename      = fullfile(options.outdir,'out');
options = optargs_struct(options,default);

if ischar(pdffiles)   %then use regular expression to find files
    files = exec_gmt_cmd(sprintf('ls -1 %s',pdffiles));
    pdffiles = regexp(files{1},'\n','split');
end

%make sure there are no empty cells
pdffiles = pdffiles(~cellfun('isempty',pdffiles));

if (length(options.cols) > 1 && sum(options.cols) ~= length(pdffiles))
    error ('atmlab:input', 'The number of plots (%d) doesn''t match the sum of columns (%d)', ...
        length(pdffiles), sum(options.cols));
end

plotrows = get_plot_dimensions(pdffiles,options);

put_figs_together_with_latex(plotrows,options);

outfile   = compile_and_crop(options);


function plot_sizes = get_plot_dimensions(pdffiles, options)
%% get_plot_dimensions (in points)

regx = 'Page size: +(?<width>\d.+).x.(?<height>\d.+) pts';
col = 1; row = 1;
for i = 1:length(pdffiles)
    info  = exec_gmt_cmd(sprintf('pdfinfo %s',pdffiles{i}),gmtlab('verbosity'));
    tmp =  structfun(@str2double,regexp(info{1},regx,'names'),'uniformoutput',0);
    plot_sizes{row}(col) = struct( ...
        'height', tmp.height / 72 * 2.54, ...
        'width', tmp.width / 72 * 2.54, ... %convert from pt to cm
        'file', pdffiles{i}); %#ok<AGROW>
    
    if row > length(options.cols)
        curcols = options.cols(end);
    else
        curcols = options.cols(row);
    end

    col = col + 1;
    if (col > curcols)
        col = 1;
        row = row + 1;
    end
end

function file = put_figs_together_with_latex(plotrows,options)
%% put_figs_together_with_latex
%

file = [options.filename,'.tex'];
fid = fopen(file,'w');
fprintf(fid,'\\documentclass[a4paper,10pt]{report}');

%% determine page width
nrows = 1;
for P = plotrows
    %% Fill up the row
    rowwidth(nrows) = sum([P{:}.width]) + options.hspace * (length(P{:})-1); %#ok<AGROW>
    rowheight(nrows) = max([P{:}.height]); %#ok<AGROW>
    nrows = nrows+1;
end

margin=0.1;
fprintf(fid,'\\usepackage[margin=%.2fcm, paperwidth=%.2fcm, paperheight=%.2fcm]{geometry}\n', ...
    margin, ...
    max(rowwidth) + 2*margin + 0.3, ...
    sum(rowheight) + 2*margin + (options.vspace + 0.1) * (length(rowheight)-1));
fprintf(fid,'\\pagestyle{empty}\n'); %no page numbering
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\setlength{\\parindent}{0in}');
fprintf(fid,'\\begin{document}\n');
fprintf(fid,'\\centering\n');
row = 1;
for P = plotrows
    %% Fill up the row
    col=1;
    for iplot = P{:}
        
        fprintf(fid,'\\begin{minipage}[%s]{%.2fcm}', options.valign, iplot.width);
        fprintf(fid,'%s',sprintf('\\includegraphics{%s}',iplot.file));
        fprintf(fid,'%s', sprintf('\\end{minipage}'));
        
        if (col ~= length(P{:}))
            fprintf(fid,'%s',sprintf('\\hspace{%.2fcm}',options.hspace));
        end
        col = col+1;
    end
    if (row ~= length(rowheight))
        %fprintf(fid, '\\\\\n');
        fprintf(fid, '\\vspace{%.2fcm}\\\\', options.vspace);
    end
    row = row+1;
end
fprintf(fid,'%s\n','\end{document}');
fclose(fid);

function outfile   = compile_and_crop(options)
%% compile_and_crop
%
command{1} = sprintf('pdflatex -interaction batchmode -output-directory %s %s.tex', ...
                     options.outdir,options.filename);
command{2} = sprintf('rm -f %s.{log,aux,tex}',options.filename);

exec_gmt_cmd(command,gmtlab('verbosity'));

outfile = [options.filename '.pdf'];