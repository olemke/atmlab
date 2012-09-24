function splitax(h, N, varargin)

% splitax Split axes h in N vertical subplots
%
% Cuts x-axis in N equally sized parts and plots data from axes h in N
% subplots below each other. Will create a new figure.
%
% FORMAT
%
%   splitax(ax, N[, opts])
%
% IN
%
%   ax      handle to axes to be copied
%   N       number of subplots to split it in
%   opts    structure with options:
%       legend      copy legend, defaulte false
%
%

% $Id$

extra = optargs(varargin, {struct()});
opts = optargs_struct(extra, ...
    struct('legend', -1));

fig = figure();
newax = zeros(1, N);
oldlim = get(h, 'XLim');
oldrange = oldlim(2) - oldlim(1);

if opts.legend
    Ntot = N+1;
else
    Ntot = N;
end

for i = 1:N
    newax(i) = subplot(Ntot, 1, i);
    % copy all children of 'h' to new subplot
    copyobj(get(h, 'Children'), newax(i));
    % set xlim correctly
    set(newax(i), 'xlim', [oldlim(1) + (i-1)*oldrange/N, ...
                           oldlim(2) - (N-i)*oldrange/N]);
    % copy labels
    %xlabel(get(get(h, 'XLabel'), 'String'));
    ylabel(get(get(h, 'YLabel'), 'String'));
    ylim(get(h, 'YLim'));
end

if (opts.legend)
    leg = findobj('Tag', 'legend', 'Parent', get(h, 'Parent'));
    if isempty(leg)
        error(['atmlab:' mfilename ':nolegend'], ...
            ['Legend was requested to be copied ' ...
            'but no legend was found in ' ...
            'parent figure!']);
    end
    copyobj(leg, fig);
    newleg = findobj('Tag', 'legend', 'Parent', fig);
    % make invisible new subplot to check where to place legend
    sp = subplot(Ntot, 1, Ntot);
    set(sp, 'Visible', 'off');
    spNpos = get(sp, 'Position');
    legpos = get(newleg, 'Position');
    legpos(1) = spNpos(1);
    legpos(2) = 0;
    set(newleg, 'Position', legpos);
end

xlabel(get(get(h, 'XLabel'), 'String'));

ht = suptitle(get(get(h, 'Title'), 'String'));
htax = get(ht, 'Parent');
xlabel(htax, get(get(h, 'XLabel'), 'String'));
ylabel(htax, get(get(h, 'YLabel'), 'String'));

end
