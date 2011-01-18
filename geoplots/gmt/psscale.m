function command = psscale(file,in)
%% psscale
%
% purpose:
%       Appends options to a short script to be later called with all GMT scripts
%
% $Author$
% $Date$

psscale = sprintf('psscale');

if isfield(in,'tick_annotations') && ~isempty(in.tick_annotations) || ...
        isfield(in,'equalboxwidth') && in.equalboxwidth || ...
        any(isfield(in,{'legendbox_spacing','tickcentering'}))
    
    psscale = sprintf('%s -L',psscale);
    
    if isfield(in,'legendbox_spacing')
        % tickspacing (annotation every xth contour), unit (dispay with legend)
        psscale = sprintf('%s%.2f',psscale,in.legendbox_spacing);
    end
    if isfield(in,'tickcentering')
        psscale = sprintf('%si',psscale);
    end
end
    
if isfield(in,'tickspacing')
    psscale = sprintf('%s -B%.0f:"%s":/:"%s":',psscale,in.tickspacing,in.xunit,in.unit);
else
    psscale = sprintf('%s -B:"%s":/:"%s":',psscale,in.xunit,in.unit);
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
    switch in.sidebar
        case 1
            str = '-Eb';
        case 2
            str = '-Ef';
        case 3
            str = '-E';
        otherwise
            error('atmlab:input','error in determining sidebar')
    end
    psscale = sprintf('%s %s',psscale,str);
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