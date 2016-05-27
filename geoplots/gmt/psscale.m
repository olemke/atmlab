function command = psscale(L,filename)
% PSSCALE Appends options to GMT psscale
%
% PURPOSE: Appends options to a short script and calls the GMT
%
% IN
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id$

assert(isfield(L,'cptfile'),['gmtlab:' mfilename ':badInput'],'needs in.cptfile')

psscale = 'gmt psscale -R -J -X -Y';

if ( isfield(L,'tick_annotations') && ~isempty(L.tick_annotations) ) || ...
        ( isfield(L,'equalboxwidth') && L.equalboxwidth ) || ...
        any(isfield(L,{'box_spacing','tick_centering'}))
    
    psscale = sprintf('%s -L',psscale);
    
    if isfield(L,'box_spacing')
        % tickspacing (annotation every xth contour), unit (dispay with legend)
        psscale = sprintf('%s%g',psscale,L.box_spacing);
    end
    if isfield(L,'tick_centering')
        psscale = sprintf('%si',psscale);
    end
    noB = true;
else
    noB = false;
end

if ~islogical(L.unit)
    if isfield(L,'tick_spacing')
        psscale = sprintf('%s -B%g:"%s":/:"%s":',psscale,L.tick_spacing,L.xunit,L.unit);
    elseif ~noB && ~(strcmp(L.xunit(1:9),'$(echo ""') && strcmp(L.unit(1:9),'$(echo ""'))
        % meaning that xunit and unit should not be empty. Also the -L option does
        % not work with the -B option
        psscale = sprintf('%s -B:"%s":/:"%s":',psscale,L.xunit,L.unit);
    elseif noB && (~isempty(L.xunit) || ~isempty(L.unit))
        warning(['gmtlab:' mfilename,':incompatable'],...
            ['-L option (annotations etc) cannot be used '...
            'with the -B option (unit and xunit)\nChoosing to ignore the -B option'...
            'Thereby in.unit and in.xunit will not be displayed in the legend'])
    end
end

psscale = sprintf('%s -Dj%s',psscale,L.justify);

psscale = sprintf('%s+w%s/%s',psscale,num2str(L.length),num2str(L.width));

if isfield(L,'xoffset')
    psscale = sprintf('%s+o%s',psscale,L.xoffset);
end

if isfield(L,'yoffset')
    psscale = sprintf('%s/%s',psscale,L.yoffset);
end

if isfield(L,'orientation') && strcmp(L.orientation,'h'),
    psscale = sprintf('%s+h',psscale);
end

if isfield(L,'sidebar')
    if L.sidebar %i.e the triangles bellow the min and above the max values
        switch L.sidebar
            case 1
                str = '+eb';
            case 2
                str = '+ef';
            case 3
                str = '+e';
            otherwise
                error(['gmtlab:' mfilename ':input'],...
                    'error in determining sidebar')
        end
        psscale = sprintf('%s%s',psscale,str);
    end
end

if isfield(L,'extra_instructions')
    psscale = sprintf('%s %s',psscale,L.extra_instructions);
end

psscale = sprintf('%s -C%s',psscale,L.cptfile);

% selects Overlay plot mode and assume more pscode will be appended later
psscale = sprintf('%s -O -K',psscale);

if isfield(L,'map_annot_offset_primary')
    psscale = sprintf('%s --MAP_ANNOT_OFFSET_PRIMARY=%s',psscale,L.map_annot_offset_primary);
end

if isfield(L,'fontsize')
    psscale = sprintf('%s --FONT_ANNOT_PRIMARY=%s',psscale,num2str(L.fontsize));
end

if isfield(L,'map_tick_length_primary')
    psscale = sprintf('%s --MAP_TICK_LENGTH_PRIMARY=%s',psscale,num2str(L.map_tick_length_primary));
end

if isfield(L,'map_tick_length_secondary')
    psscale = sprintf('%s --MAP_TICK_LENGTH_SECONDARY=%s',psscale,num2str(L.map_tick_length_secondary));
end

if isfield(L,'tick_annotation_format')
    psscale = sprintf('%s --FORMAT_FLOAT_OUT=%s',psscale,L.tick_annotation_format);
end

command = sprintf('%s >> %s.ps',psscale,filename);