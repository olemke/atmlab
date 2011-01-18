function command = pslocations(file,in,command)
%% pslocations
%
% purpose:
%       Adds location markers to a GMT plot.
%
%
% 10/12-2009 Oliver Lemke & Salomon Eliasson

for loc = in.locations
    psloc = sprintf('echo "%f %f" | psxy ', loc.lon, loc.lat);
    psloc = sprintf('%s -R -J',psloc);
    
    shape = 'c0.08i';
    if isfield(loc,'shape')
        shape = loc.shape;
    end
    
    psloc = sprintf('%s -S%s',psloc,shape);
    
    color = 'white';
    if isfield(loc,'color') && ~isempty(loc.color)
        color = loc.color;
    end
    psloc = sprintf('%s -G%s -Wthinner',psloc,color);
    
    % selects Overlay plot mode and assume more pscode will be appended later
    psloc = sprintf('%s -O -K',psloc);
    if ~isempty(shape)
        command{end+1} = sprintf('%s >> %s.ps',psloc,file);
    end
    if isfield(loc,'name') && ~isempty(loc.name)
        tsize=15;
        if isfield(loc,'textsize') && ~isempty(loc.textsize)
            tsize = loc.textsize;
        end
        talign='LT';
        if isfield(loc,'textalign') && ~isempty(loc.textalign)
            talign = loc.textalign;
        end
        pstxt = sprintf('echo "%f %f %d 0 1 %s %s" | pstext ', ...
            loc.lon, loc.lat, tsize, talign, loc.name);
        
        % Offset text from data point
        pstxt = sprintf('%s -Dj0.05i/0.05i',pstxt);
        
        pstxt = sprintf('%s -R -J',pstxt);
        
        if isfield(loc,'textcolor') && ~isempty(loc.textcolor)
            color = loc.textcolor;
        end
        pstxt = sprintf('%s -G%s',pstxt,color);
        
        % selects Overlay plot mode and assume more pscode will be appended later
        pstxt = sprintf('%s -O -K',pstxt);
        
        command{end+1} = sprintf('%s >> %s.ps',pstxt,file);
    end
end