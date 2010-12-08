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

if isfield(in,'tick_annotations') && isempty(in.tick_annotations) 
    %need equal size boxes for custom annotations
    psscale = sprintf('%s -Bs::/:%s:',psscale,in.unit);
elseif isfield(in,'tick_annotations') && ~isempty(in.tick_annotations) 
    psscale = sprintf('%s -L -B::/:%s:',psscale,in.unit);
elseif ~isempty(in.tickspacing)
    % tickspacing (annotation every xth contour), unit (dispay with legend)
    psscale = sprintf('%s -B%i::/:%s:',psscale,in.tickspacing,in.unit);
else 
    psscale = sprintf('%s -B::/:%s:',psscale,in.unit);
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

if isfield(in,'shift_tick_annotations')
    psscale = sprintf('%s --ANNOT_OFFSET_PRIMARY=%di',psscale,in.shift_tick_annotations);
end

if isfield(in,'annot_font_size_primary')
    psscale = sprintf('%s --ANNOT_FONT_SIZE_PRIMARY=%d',psscale,in.annot_font_size_primary);
end

if isfield(in,'tick_length')
    psscale = sprintf('%s --TICK_LENGTH=%dc',psscale,in.tick_length);
end
if isfield(in,'tick_annotation_format')
    psscale = sprintf('%s --D_FORMAT=%s',psscale,in.tick_annotation_format);
else
    psscale = sprintf('%s --D_FORMAT=%%.0lf',psscale);
end

command = sprintf('%s >> %s.ps',psscale,file);