function command = psscale(file,in)
%% psscale
%
% purpose:
%       appends options to a  short script and calls the GMT
%       command psscale appending options.
%
%
% $Author$
% $Date$

psscale = sprintf('psscale');

% tickspacing (annotation every xth contour), unit (dispay with legend)
if isempty(in.tickspacing)
    psscale = sprintf('%s -B::/:%s:',psscale,in.unit);
else psscale = sprintf('%s -B%i::/:%s:',psscale,in.tickspacing,in.unit);
end

if isfield(in,'cptfile')
    psscale = sprintf('%s -C%s',psscale,in.cptfile);
else
    error 'needs in.cptfile'
end

if isfield(in,'legendsize')
    psscale = sprintf('%s -D%s',psscale,in.legendsize);
end

if in.sidebar %i.e the triangles bellow the min and above the max values
    psscale = sprintf('%s -E',psscale);
end

% selects Overlay plot mode and assume more pscode will be appended later
psscale = sprintf('%s -O -K',psscale);

if isfield(in,'shift_tick')
    psscale = sprintf('%s --ANNOT_OFFSET_PRIMARY=%di',psscale,in.shift_tick);
end
if isfield(in,'tick_format')
    psscale = sprintf('%s --D_FORMAT=%s',psscale,in.tick_format);
end

command = sprintf('%s >> %s.ps',psscale,file);