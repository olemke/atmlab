function outfile = combine_pdfs(pdffiles, options)
% COMBINE_PDFS Combine several PDF files on one page
%
% USAGE: outfile = combine_pdfs(pdffiles, options)
%
% E.g. file = combine_pdfs(files,struct('cols',[2 2 2 2 1],...))
%
% By default, pdf files are created in gmtlab('outdir')
%
% PURPOSE:  Merge several pdf's (one page each) into a pdf file
%
% EXTERNAL DEPENDENCIES: pdfinfo, pdflatex.
%
% IN:   pdffiles            cell: Each element contains the path to a
%                                 file.
%                           OR
%                           string: 'dir(<string>)' will get a list of files,
%                                   globbing is allowed:
%                             e.g pdffiles = figs/*{CAlow,CAmiddle,CAhigh}*
%
%       options.            structure; contains the following options:
%   KEY:fieldname     |type |description                 | default
%       cols          |%d [] number of columns per row   | 2
%       filename      |%s    name of output file         | 'out.pdf'
%       outdir        |%s    directory for output        | gmtlab('outdir')
%       vspace        |%f    space between rows          | 1 (cm)
%       hspace        |%f    space between columns       | 1 (cm)
%       valign        |%s    vertical alignment          | m
%                     |      m = middle, b = bottom      |
%       scale         |[%d,%d; etc] scale individual figures
%                      [filenumber,scale]                | 1
%       display       | tries to open pdf file           | false
%                     | if your viewer is not listed it  |
%                     | will not try to display anything |
%
% OUT:      outfile             string; the fullpath to the pdffile created
%
% NOTE: The files are appended left to right and from top to bottom.
%       Arguments may be:
%            1) option.cols can alternatively be a vector
%               with the number of columns for each row. In that case, the
%               sum of this vector must match the number of pdf files.

% 2011-04-11 Created by Oliver Lemke based on an idea by Salomon.

if ~nargin, error('atmlab:combine_pdfs','Needs input. See help.'); end
if nargin == 1, options = struct; end

%% Set defaults and use them if not specified by user
default.cols     = 2;
default.vspace   = 1;
default.hspace   = 1;
default.valign   = 'm';
default.filename = 'out.pdf';
default.outdir   = gmtlab('outdir');
default.secret_latex_spacing_tweak = 0.5;
default.display  = false;

options = optargs_struct(options, default);

%% Convert outdir to fullpath
options.outdir = path_replace_tilde(options.outdir);
if (isempty(options.outdir) || options.outdir(1) ~= filesep())
    options.outdir = fullfile(pwd(), options.outdir);
end

%% Sanity checks
assert(options.vspace >= 0, 'atmlab:combine_pdfs', 'Vertical spacing must be >= 0');
assert(options.hspace >= 0, 'atmlab:combine_pdfs', 'Horizontal spacing must be >= 0');
assert(length(options.valign) == 1 && any('mbt' == options.valign), ...
    'atmlab:combine_pdfs', 'Vertical alignment must be either ''m'' or ''b''');
assert(isdir(options.outdir), 'atmlab:combine_pdfs', ...
    '%s does not exist', options.outdir);


%% If we got a regexp, use ls to get the file list
if ischar(pdffiles), files = dir(pdffiles); pdffiles = {files.name}; end

%% Make sure filenames are in a row vector and non-empty
pdffiles = pdffiles(:)';
pdffiles = pdffiles(~cellfun('isempty',pdffiles));
pdffiles = path_replace_tilde(pdffiles);
assert(~isempty(pdffiles), 'atmlab:combine_pdfs', 'List of input pdf files is empty');

%% We trust that the user can count! Not really, better double check here
if (length(options.cols) ~= 1 && sum(options.cols) ~= length(pdffiles))
    error ('atmlab:combine_pdfs', ...
        'Number of plots (%d) doesn''t match sum of columns (%d)', ...
        length(pdffiles), sum(options.cols));
end

%% If cols is only one number, replicate it to match the number files
if (length(options.cols) == 1)
    options.cols = repmat(options.cols, ceil(length(pdffiles)/options.cols), 1);
end

%% Setup is complete, let's get cracking
layout = create_layout_from_pdffiles(pdffiles, options);

create_pdf_from_layout_with_latex(layout, options);

outfile = fullfile(options.outdir, options.filename);

%% Display output
% This only works for the following pre-programmed options
if options.display
    if ismac
        exec_system_cmd(sprintf('open %s',outfile));
    elseif isunix
        [~,b1]=system('which evince');
        [~,b2]=system('which okular');
        if ~isempty(b1)
            exec_system_cmd(sprintf('evince %s &',outfile));
        elseif ~isempty(b2)
            exec_system_cmd(sprintf('okular %s &',outfile));
        end
    end
end

end


%% Only subfunctions allowed after this point!!!

function layout = create_layout_from_pdffiles(pdffiles, options)

% Create a fancy regexp that gives us width and height from pdfinfo output
regx = 'Page size: +(?<width>\d.+).x.(?<height>\d.+) pts';

col = 1; row = 1;filenum=1;
for P = pdffiles
    info  = exec_system_cmd(sprintf('pdfinfo ''%s''', P{1}), gmtlab('verbosity'));
    
    % Great, pdfinfo uses BigPoints as a unit. Let's throw in some fancy
    % numbers and hope we end up with centimeters after that (DPI*INCH).
    % This might break for some PDFs, better keep your fingers crossed.
    psize =  structfun(@(x) str2double(x)/72*2.54, ...
        regexp(info{1},regx, 'names'), ...
        'uniformoutput', 0);
    
    % --------------
    % Apply scaling
    % --------------
    if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
        sc = options.scale(options.scale(:,1)==filenum,2);
    else
        sc = 1;
    end
    layout.plotsbyrow{row}(col) = struct('height', psize.height*sc, ...
        'width', psize.width*sc, ...
        'file', P{1});
    
    col = col + 1;
    if (col > options.cols(row) ...
            || length([layout.plotsbyrow{:}]) == length(pdffiles))
        col = 1;
        R = layout.plotsbyrow(row);
        layout.rowwidth(row) = sum([R{:}.width]) ...
            + options.hspace*(length(R{:})-1) ...
            + options.secret_latex_spacing_tweak*length(R{:});
        layout.rowheight(row) = max([R{:}.height]);
        row = row + 1;
    end
    filenum = filenum+1;
end

end


function file = create_pdf_from_layout_with_latex(layout, options)

tmpfolder = create_tmpfolder();

%% Hook up a cleanup callback.
% In case we screw up the LaTeX run, we don't want to leave any
% evidence behind.
c = onCleanup(@() delete_tmpfolder(tmpfolder));

%% Assemble our pretty tex file
file = fullfile(tmpfolder, 'out.tex');
fid = fopen(file,'w');
fprintf(fid,'\\documentclass[a4paper,10pt]{report}\n');

margin=0.1;
fprintf(fid,['\\usepackage[margin=%.2fcm,paperwidth=%.2fcm,' ...
    'paperheight=%.2fcm]{geometry}\n'], ...
    margin, ...
    max(layout.rowwidth) + 2*margin, ...
    sum(layout.rowheight) + 2*margin ...
    + options.vspace*(length(layout.rowheight)-1) ...
    + options.secret_latex_spacing_tweak*length(layout.rowheight));
fprintf(fid,'\\pagestyle{empty}\n');
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\setlength{\\parindent}{0in}\n');
fprintf(fid,'\\begin{document}\n');
% if ~isempty(options.title) % not ready for this
%     % centering, huge hardcoded
%     fprintf(fid,'\\begin{center}\n');
%     fprintf(fid,'{\\Huge %s}\n',strrep(options.title,'_','\_'));
%     fprintf(fid,'\\end{center}\n');
% end
fprintf(fid,'\\centering\n');

row = 1; filenum = 1;
for R = layout.plotsbyrow
    col=1;
    for P = R{:}
        fprintf(fid,'\\begin{minipage}[%s]{%.2fcm}\n', options.valign, P.width);
        tmpplotname=sprintf('plot%d.pdf', filenum);
        mvplotcmd{filenum}=sprintf('cp ''%s'' ''%s/%s''', P.file, tmpfolder, tmpplotname); %#ok
        if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
            strscale = num2str(options.scale(options.scale(:,1)==filenum,2));
        else
            strscale = '1';
        end
        fprintf(fid,'\\includegraphics[scale=%s]{%s}\n', strscale,tmpplotname);
        fprintf(fid,'\\end{minipage}\n');
        if (col ~= length(R{:}))
            fprintf(fid,'\\hspace{%.2fcm}\n', options.hspace);
        end
        col = col+1;
        filenum=filenum+1;
    end
    if (row ~= length(layout.rowheight))
        fprintf(fid, '\\vspace{%.2fcm}\\\\\n', options.vspace);
    end
    row = row+1;
end
fprintf(fid,'\\end{document}\n');
fclose(fid);

%% Hand the TeX file over to pdflatex
exec_system_cmd(mvplotcmd, gmtlab('verbosity'));
exec_system_cmd(sprintf('cd %s && pdflatex -interaction batchmode out.tex', ...
    tmpfolder), ...
    gmtlab('verbosity'));

exec_system_cmd(sprintf('cd %s && mv -f out.pdf ''%s''', ...
    tmpfolder, ...
    fullfile(options.outdir, options.filename)), ...
    gmtlab('verbosity'));

end
