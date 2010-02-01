function command = pslocations(in)

% purpose:
%       Adds location markers to a GMT plot.
%

% 10/12-2009 Oliver Lemke & Salomon Eliasson

k = 1;
command = cell(2*length(in.locations),1);
for loc = in.locations
    psloc = sprintf('echo "%f %f" | psxy ', loc.lon, loc.lat);
    
    %lat lon bounds
    if isfield(in.plot,'region')
        psloc = sprintf('%s -R%s',psloc,in.plot.region);
    else
        error 'needs in.region'
    end
    
    %projection type
    if isfield(in.plot,'proj')
        psloc = sprintf('%s -J%s',psloc,in.plot.proj);
    else
        error 'needs in.proj'
    end
    
    shape = 'c0.08i';
    if isfield(loc,'shape') && ~isempty(loc.shape)
        shape = loc.shape;
    end
    psloc = sprintf('%s -S%s',psloc,shape);
    
    color = 'white';
    if isfield(loc,'color') && ~isempty(loc.color)
        color = loc.color;
    end
    psloc = sprintf('%s -G%s -Wthinner',psloc,color);
    
    % selects Overlay plot mode
    if ~isempty(dir(sprintf('%s.ps',in.filename)))
        psloc = sprintf('%s -O',psloc);
    end
    
    % assuming more pscode will be appended later
    psloc = sprintf('%s -K',psloc);
    
    ut = sprintf('%s.ps',in.filename);
    command(k) = {sprintf('%s >> %s',psloc,ut)}; k=k+1;
    
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
        
        pstxt = sprintf('%s -R%s',pstxt,in.plot.region);
        pstxt = sprintf('%s -J%s',pstxt,in.plot.proj);
        
        if isfield(loc,'textcolor') && ~isempty(loc.textcolor)
            color = loc.textcolor;
        end
        pstxt = sprintf('%s -Sthin -G%s',pstxt,color);
        
        % selects Overlay plot mode
        if ~isempty(dir(sprintf('%s.ps',in.filename)))
            pstxt = sprintf('%s -O',pstxt);
        end
        % assuming more pscode will be appended later
        pstxt = sprintf('%s -K',pstxt);
        
        ut = sprintf('%s.ps',in.filename);
        command(k) = {sprintf('%s >> %s',pstxt,ut)}; k = k+1;
    end
end
command = command(1:k-1);