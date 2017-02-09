function outfile = combine_pdfs(pdffiles, options)
% COMBINE_PDFS Combine several PDF (or eps) files on one page
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
%
% OPT
%       % HOW TO READ VARIABLE DESCRIPTION OF OPTIONAL VARIABLES:
%         KEY:  in.variable   in: = expect input type, ex: = Explanation/Example, de: = Default value/behavior
%         NOTE: If "def" is missing for a variable it means the variable is not used by default
%
%         types: %s=character or string
%                %f=numeric/logical
%                {}=cell
%
%       Structure where the following fields are considered options:
%
%       options.cols
%            in:  %d
%            ex:  Number of columns per row. option.cols can also be a vector
%                 containing the number of columns that should be on each each row.
%                 In that case, the sum of this vector must match the number of pdf files.
%            def: 2
%       options.display
%            in:  %f
%            ex:  tries to open pdf file with 'gnome-open' or 'kde-open'
%                 if you are on a linux and 'open' if called from Mac
%            def: true
%       options.filename
%            in:  %s
%            ex:  name of output file
%            def: 'out.pdf'
%       options.fontsize
%            in:  %s
%            ex:  E.g., '4cm' or '40pt'
%            def: 1/22 * rowwidth (but only relevent if title is given)
%       options.hspace
%            in:   %f
%            ex:   space between columns in cm
%            def:  1
%            note: Providing a vector mean that you want different hspace between plot for each row
%       options.outdir
%            in:  %s
%            ex:  directory for output
%            def: gmtlab('outdir')
%       options.pages
%            in:  %f
%            ex:  number of pages
%            def: 1
%       options.pdfviewer
%            in:  %s
%            ex:  Your pdf-viewing program of choice
%            def: Mac: 'open'
%                 Linux: 'gnome-open' or if that does work,
%                        'kde-open'. If neither exists, nothing is displayed
%       options.pdfcrop
%            in:  %f
%            ex:  Do a pdfcrop when finished putting everything together
%            def: false
%
%       options.rightPadding
%            in:  %f
%            ex:  padding to the right of a row in cm. Note: Needs one value per row.
%                 e.g., for 4 rows something like options.rightPadding=[1.7,1.7,0,0]
%            def: 1
%       options.rowsPerPage
%            This is good if you have many plots that are not suitable for just
%            one page
%
%            in:  %d
%            ex:  Number of rows per page. option.rowsPerPage can also be a vector
%                 containing the number of rows on each page.
%                In that case, the sum of this vector must match the total
%                number of rows (=n files / sum(in.cols)).
%            def: all the rows on one page
%       options.samesize
%            in:   %f
%            ex:   Whether or not to force the figures to have the same size on the page
%            def:  false
%            note: This can be useful to make sure your plots are nicely aligned
%                  on the page,s especially if you have plots that are nearly the
%                  same size
%       options.scale
%            in:  [%d,%d; etc]
%            ex:  scale individual figures. [filenumber,scale]
%            def: 1
%       options.title
%            in:  %s
%            ex:  title to be displayed above the combined pdfs
%            def: <none>
%       options.valign
%            in:  %s
%            ex:  vertical alignment. 'm' = middle, 'b' = bottom, 't'=top
%            def: 'm'
%       options.vspace
%            in:  %f
%            ex:  space between rows in cm
%            def: 1
%       options.outputformat
%            in: %s
%            ex: 'dvi' or 'pdf'. 'dvi is useful if you plots are in eps and 
%                you are having problems with transparency
%            def: 'pdf
%             
%          
% OUT:      outfile = The fullpath to the created pdf-file
%
% NOTE: The files are appended left to right and from top to bottom. This
% function does not handle bitmaps like png since it relys on pdfinfo to
% retrieve the size of the figures


% 2013-04-10 Oliver Lemke and Salomon Eliasson.
% $Id$

if ~nargin, error(['atmlab:' mfilename],'Needs input. See help.'); end
if nargin == 1, options = struct; end

%% Set defaults and use them if not specified by user
default.cols        = min(length(pdffiles),2);
default.display    = true;
if isfield(options,'title') && ~isempty(options.title)
    default.filename = sanitise(options.title);
else
    default.filename = 'out';
end
default.hspace      = 1;
default.outdir     = gmtlab('outdir');
default.pages      = 1;
default.pdfcrop    = false;
default.pdfviewer  = '';
default.samesize   = false;
default.secret_latex_spacing_tweak = 0.5;
default.title      = '';
default.valign      = 'm';
default.vspace      = 1;
default.outputformat='pdf';

options = optargs_struct(options, default);

%%
% Path

% Convert outdir to fullpath
options.outdir = path_replace_tilde(options.outdir);
if (isempty(options.outdir) || options.outdir(1) ~= filesep())
    options.outdir = fullfile(pwd(), options.outdir);
end
% If we got a regexp, use ls to get the file list
if ischar(pdffiles)
    direct = fileparts(pdffiles);
    files = dir(pdffiles);
    tmp = cell(1,length(files));
    for i = 1:length(files)
        tmp{i} = [direct,'/',files(i).name];
        
    end
    pdffiles = tmp;
end

% Make sure filenames are in a row vector and non-empty
pdffiles = pdffiles(:)';
pdffiles = pdffiles(~cellfun('isempty',pdffiles));
pdffiles = path_replace_tilde(pdffiles);
assert(~isempty(pdffiles), 'atmlab:combine_pdfs', 'List of input pdf files is empty');

%%
% Columns and rows

% First check if a vector of columns is given but it doesn't match the number of pdffiles
assert(sum(options.cols)<=length(pdffiles),...
    ['atmlab:',mfilename,':badInput'],'number of columns is more than the number of files')


% columns
options.cols = make_fit(options.cols,pdffiles);

% rows

if options.pages > length(options.cols)
    warning(['atmlab:',mfilename,':badInput'],'options.pages forced to %i (= length(options.cols) )',length(options.cols))
    options.pages = length(options.cols);
end

rows = ceil(length(options.cols)/options.pages);

if isfield(options,'pages')
    if atmlab('VERBOSITY') && isfield(options,'rowsPerPage')
        warning(['atmlab:',mfilename,':badInput'],'options.pages forces the number of rows')
    end
    options.rowsPerPage = rows;
else
    default.rowsPerPage = rows; % Default is one page for all the plots
end
options = optargs_struct(options, default); clear default;
options.rowsPerPage = make_fit(options.rowsPerPage,options.cols);
if options.rowsPerPage>4
    warning(['atmlab:',mfilename,':badInput'],...
        ['There will be more than 4 rows of plots on this page. '...
        'If the page is too long latex will crash. Consider limiting '...
        'the number of rows per page using options.rowsPerPage. e.g. options.rowsPerPage = [3, 2, etc]'])
end
% Pages
options.pages = length(options.rowsPerPage);

if isscalar(options.hspace)
    options.hspace = repmat(options.hspace,1,sum(options.rowsPerPage));
end

if options.pdfcrop && options.pages>1
    warning(['atmlab:',mfilename,':badInput'],...
        ['Cannot use pdfcrop if the output pdf has more than 1 page. '...
        'Setting pdfcrop to false\n'])
    options.pdfcrop=false;
end

%% Assertions
% Sanity checks
assert(length(options.valign) == 1 && any('mbt' == options.valign), ...
    'atmlab:combine_pdfs', 'Vertical alignment must be either ''m'' or ''b''');
assert(isdir(options.outdir), 'atmlab:combine_pdfs', ...
    '%s does not exist', options.outdir);

%% Setup is complete, let's get cracking
layout = create_layout_from_pdffiles(pdffiles, options);
if isempty(layout)
    outfile='';
    logtext(1,'File not created\n')
    return
end 

outfile = create_pdf_from_layout_with_latex(layout, options);

%% Display output
% This only works for the following pre-programmed options
if options.display && isempty(options.pdfviewer)
    if ismac
        exec_system_cmd(sprintf('open %s',outfile));
    elseif isunix
        [~,b1]=system('which gnome-open');
        [~,b2]=system('which kde-open');
        if ~isempty(b1)
            exec_system_cmd(sprintf('gnome-open %s &',outfile));
        elseif ~isempty(b2)
            exec_system_cmd(sprintf('kde-open %s &',outfile));
        end
    end
elseif options.display
    exec_system_cmd(sprintf('%s %s >/dev/null &',options.pdfviewer,outfile));
end

end


function layout = create_layout_from_pdffiles(pdffiles, options)

% regexp that gives us width and height from pdfinfo output
regx = 'Page size: +(?<width>\d.+).x.(?<height>\d.+) pts';

% -------
% get the height and width information from each pdffile
%
psize(length(pdffiles)) = struct('width','','height','');
for i = 1:length(pdffiles)
    if strcmpi(pdffiles{i}(end-3:end),{'.png'})
        logtext(1,'Cannot handle .png. Quitting...\n')
        layout='';
        return
    end 
    if strcmpi(pdffiles{i}(end-3:end),{'.eps'})
        % make a tempory file and then delete it (if you want to ultimately
        % create a .dvi), otherwise we need epstopdf since pdflatex cannot
        % handle .eps (internally uses epstopdf anyhow)
        exec_system_cmd(sprintf('cp ''%s'' epstmp.eps', pdffiles{i}), 0);
        exec_system_cmd('epstopdf epstmp.eps',0);
        info  = exec_system_cmd('pdfinfo epstmp.pdf', 0);
        if strcmp(options.outputformat,'pdf')
            tmpfile = sprintf('%s.pdf',pdffiles{i}(1:end-4));
            exec_system_cmd(sprintf('cp epstmp.pdf %s.pdf',tmpfile));
            pdffiles{i} = tmpfile;
        else
            exec_system_cmd('rm epstmp.{eps,pdf}', 0);
        end
    else
        info  = exec_system_cmd(sprintf('pdfinfo ''%s''', pdffiles{i}), 0);
    end
    % pdfinfo uses BigPoints as a unit. Converting to cm.
    psize(i) =  structfun(@(x) str2double(x)/72*2.54, ...
        regexp(info{1},regx, 'names'), ...
        'uniformoutput', 0);
end

col = 1;
row = 1;
filenum=1;
for i = 1:length(pdffiles)

    % apply scale to with if given 
    if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
        sc = options.scale(options.scale(:,1)==filenum,2);
    else sc = 1;
    end
    
    % get the width from psize or get the maximum width from psize and apply to
    % all 
    if options.samesize
        width=max([psize.width]);
    else width=psize(i).width;
    end
    
    % On this row and this column element, set the height and width associated
    % with the file at hand
    layout.plotsbyrow{row}(col) = struct('width', width*sc, ...
        'height', psize(i).height*sc, ...
        'file', pdffiles{i});

    % now go to the next column
    col = col + 1;
    
    % but if the next column is on the NEXT row (or the last file is processed), find the row dimensions
    if col > options.cols(row)
        R = layout.plotsbyrow(row);
        
        % width
        layout.rowwidth(row) = sum([R{:}.width]) ...
            + options.hspace(row)*(length(R{:})-1) ...
            + options.secret_latex_spacing_tweak*length(R{:});
        
        % height
        layout.rowheight(row) = max([R{:}.height]);
        % -------
        
        % reset columns and increment the row number
        col = 1;
        row = row + 1;
    end
 
    if filenum == length(pdffiles)
        return
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

%% Assemble the laTeX file
file = fullfile(tmpfolder, 'out.tex');
fid = fopen(file,'w');
Cob = onCleanup(@(x) fclose(fid));

fprintf(fid,'\\documentclass[a4paper,10pt]{report}\n');

margin=0.1; %cm
if ~isempty(options.title)
    options = optargs_struct(options,struct('fontsize',sprintf('%gcm',1/20 * max(layout.rowwidth)))); % cm
    tmp=regexp(options.fontsize,'(?<fz>\d+\.?\d*)(?<unit>.+)','names');
    fz=str2double(tmp.fz);
    unit=tmp.unit;
else
    fz=0;
end

% find a good height
k = 1;height=zeros(1,options.pages);
for i = 1:options.pages
    
    height(i) = sum(layout.rowheight(k:k+options.rowsPerPage(i)-1)) ...
        + 2*margin + 2*fz ...
        + options.vspace*options.rowsPerPage(i);
    
    k = k+options.rowsPerPage(i);

end
height = max(height);

fprintf(fid, '\n%s\n%s\n%s\n\n','%%%%%%%%','% Header','%%%%%%%%');
fprintf(fid,['\\usepackage[margin=%gcm,paperwidth=%gcm,' ...
    'paperheight=%gcm]{geometry}\n'], ...
    margin, ...
    max(layout.rowwidth) + 2*margin, ...
    height);

fprintf(fid,'\\pagestyle{empty}\n');
fprintf(fid,'\\usepackage{graphicx}\n');
fprintf(fid,'\\usepackage{anyfontsize}\n');
fprintf(fid,'\\setlength{\\parindent}{0in}\n');
fprintf(fid,'\n\n');
fprintf(fid,'\\begin{document}\n\n');
fprintf(fid,'\\centering\n\n');
if ~isempty(options.title)
    if ~any(ismember(unit,{'cm','mm','pt'})), error(['atmlab:' mfilename],'Don''t know fontsize unit "%s"',unit),end
    fprintf(fid,'\\begin{minipage}[%s]{%gcm}\n', options.valign, max(layout.rowwidth));
    fprintf(fid,'\\begin{center}\n');
    fprintf(fid,'{\\fontsize{%g%s}{%g%s}\\selectfont \\sffamily %s}\n',...
        fz,unit,1.2*fz,unit,strrep(options.title,'_','\_'));
    fprintf(fid,'\\end{center}\n');
    fprintf(fid,'\\end{minipage}\n');
    fprintf(fid, '\\vspace{%gcm}\\\\\n\n', options.vspace);
end

row = 1; filenum = 1; page = 1;
for R = layout.plotsbyrow
    col=1;
    for P = R{:}
        fprintf(fid,'\\begin{minipage}[%s]{%gcm}\n', options.valign, P.width);
        tmpplotname=sprintf('plot%d.%s',filenum,P.file(end-2:end));
        %mvplotcmd{filenum}=sprintf('cp ''%s'' ''%s/%s''', P.file, tmpfolder, tmpplotname); %#ok
        mvplotcmd{filenum}=sprintf('cp %s %s/%s', P.file, tmpfolder, tmpplotname); %#ok
        if isfield(options,'scale') && ~isempty(options.scale(options.scale(:,1)==filenum,2))
            strscale = num2str(options.scale(options.scale(:,1)==filenum,2));
        else
            strscale = '1';
        end
        fprintf(fid,'\\includegraphics[scale=%s]{%s}\n', strscale,tmpplotname);
        fprintf(fid,'\\end{minipage}\n');
        if (col ~= length(R{:}))
            fprintf(fid,'\\hspace{%gcm}\n', options.hspace(row));
        elseif isfield(options,'rightPadding')
            fprintf(fid,'\\hspace{%gcm}\n', options.rightPadding(row));
        end
        col = col+1;
        filenum=filenum+1;
    end
    if (row ~= length(layout.rowheight))
        fprintf(fid, '\\vspace{%gcm}\\\\\n\n', options.vspace);
    end
    
    if page > options.pages
        break
    end
    
    % page break? allways putting a pagebreak at the end
    if row == options.rowsPerPage(page)
        fprintf(fid,'\\newpage\n');
        page = page+1;
        row = 1;
    else
        row = row+1;
    end
end
fprintf(fid,'\n');
fprintf(fid,'\\end{document}\n');

%% Hand the TeX file over to pdflatex
if strcmp(options.outputformat,'dvi')
    compiler = 'latex';
else
    compiler = 'pdflatex';
end
exec_system_cmd(mvplotcmd, atmlab('VERBOSITY'));
exec_system_cmd(sprintf('cd %s && %s -interaction nonstopmode out.tex', ...
    tmpfolder,compiler), ...
    atmlab('VERBOSITY'));

file = fullfile(options.outdir, options.filename);
% allow spaces
file = strrep(file,' ','\ ');

exec_system_cmd(sprintf('cd %s && mv -f out.%s %s', ...
    tmpfolder, options.outputformat,file), ...
    atmlab('VERBOSITY'));

if strcmp(options.outputformat,'pdf')
    if options.pdfcrop
        f_ind = strfind(file,'.pdf');
        if ~isempty(f_ind)
            file = file(1:f_ind-1);
        end
        [message,test]=exec_system_cmd(sprintf('pdfcrop %s',file),atmlab('VERBOSITY'));
        if logical(test)
            error(['atmlab' mfilename],'There was a problem with pdfcrop: %s',message{1})
        end
        exec_system_cmd(sprintf('mv %s-crop.pdf %s.pdf',file,file),atmlab('VERBOSITY'));
        file = [file,'.pdf'];
    end
end

end

function var = make_fit(var,ref)
%
% This is something I do in exactly the same way for several different variables

% Make scalar entry into a vector if it isn't already
if isscalar(var)
    inscalar = var;
    tmp = zeros(1,length(ref));
    i=1;
    
    remaining = length(ref); 
    while remaining > 0
        if (remaining-inscalar) >= 0
            % there are more files remaining than the scalar input
            tmp(i) = inscalar;
            remaining = remaining-inscalar;
            i = i+1;
        elseif (remaining-inscalar)==0
            % an exact fit
            tmp(i) = inscalar;
            var = tmp(1:i);
            return
        else
            % There are less files remaining than the scalar input
            tmp(i) = mod(remaining,inscalar);
            remaining = remaining-mod(remaining,inscalar);
            i = i+1;
        end
        if remaining==length(ref)
            % nothing was done. E.g for rows if all the pdffiles fit on one page
            return
        end
    end
    var = tmp(1:i-1);
end

end
