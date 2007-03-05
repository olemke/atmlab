function plotted = arts_oem_plot_x(x,jq,ji,i)
  

%- Index of x
%
ind = ji{i}{1} : ji{i}{2};


%- No action for scalar quantities
%
if length(ind)
  plotted = 0;
  return
end


%- Determine quantity type
%
pvar = 0;
xfac = 1;
%
if strcmp( jq{i}.maintag, 'Abs. species' )
  %
  pvar = 1;
  if strcmp( jq{i}.mode, 'rel' )
    unit = '-';
  elseif strcmp( jq{i}.mode, 'vmr' )
    unit = 'vmr';
  elseif strcmp( jq{i}.mode, 'nd' )
    unit = '#/m3';
  else
    error( 'Unknown unit for absorption species.' );
  end
  %
else
  error( 'Unknown retrieval quantity.' );  
end
  

%- Determine vmr unit
%
if strcmp( unit, 'vmr' )
  if max( x(ind) ) < 999e-12
    unit = 'ppt';
    xfac = 1e12;
  elseif max( x(ind) ) < 999e-9
    unit = 'ppb';
    xfac = 1e9;
  elseif max( x(ind) ) < 999e-6
    unit = 'ppm';
    xfac = 1e6;
  else
    unit = '-';
  end
end



%- Make plot
%  
dim = length( jq{i}.grids );
%
if dim == 1
  if pvar
    semilogy( xfac*x(ind), jq{i}.grids{1}/1e2 );
    set( gca, 'Ydir', 'rev' );
    xlabel( sprintf('',) );
    ylabel( 'Pressure [hPa]' );
  else
    plot( jq{i}.grids{1}, xfac*x(ind) );
  end
else
  
  if pvar
    semilogy( xfac*x(ind), jq{i}.grids{1}/1e2 );
    set( gca, 'Ydir', 'rev' );
    xlabel( sprintf('',) );
    ylabel( 'Pressure [hPa]' );
  else
    plot( jq{i}.grids{1}, xfac*x(ind) );
  end
end


plotted = 1;