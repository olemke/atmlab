
function [h,hs] = arts_plot_atmgrids(dim,lat_grid,lon_grid,z_field,...
                                          r_geoid,z_ground,cb_lims,mark_fields)


%= Check input and default values
%
min_nargin( 6, nargin );
%
if ~isscalar( dim )  |  dim < 1  |  dim > 3
  error('The atmospheric dimensionality must be a scalar between 1 and 3.');
end
%
if dim == 1  & ( ~isvector( lat_grid )   |  length( lat_grid ) ~= 2 )
  error('For 1D, *lat_gid* must be a vector of length 2.');
end
%
if nargin < 7
  cb_lims = [];
end
%
if nargin < 8
  mark_fields = 0;
end



%= Check if plot is hold
%
figure(gcf);
figstat = ishold;
%
if ~ishold
  clf
end


%= Plotting symbols
%
ps_grids     = 'k:';
ps_ground{1} = 'r-';
ps_ground{2} = 'LineWidth';
ps_ground{3} = 2;
ps_geoid     = 'b-.';
ps_cloudb    = 0.7*ones(1,3);
ps_field     = 'k.';
%
hs{1} = 'Atmospheric grids';
hs{2} = 'Ground';
hs{3} = 'Geoid';
hs{4} = 'Cloud box';
if mark_fields
  hs{5} = 'Atmospheric field';
end


nz = size(z_field,1);


switch dim

  %- 1D
  case 1
    %
    if ~isempty( cb_lims )
      [x1,y1] = surf_segment2D( lat_grid, [r_geoid(1)+z_field(cb_lims(1)), ...
                                           r_geoid(1)+z_field(cb_lims(1)) ] );
      [x2,y2] = surf_segment2D( lat_grid, [r_geoid(1)+z_field(cb_lims(2)), ...
                                           r_geoid(1)+z_field(cb_lims(2)) ] );
      h(4) = patch( [x1 fliplr(x2)], [y1 fliplr(y2)], ps_cloudb);
      set( h(4), 'EdgeColor', ps_cloudb );
      hold on
    end
    %
    for j = 1 : nz
      [x,y] = surf_segment2D( lat_grid, ...
                            [ r_geoid(1)+z_field(j), r_geoid(1)+z_field(j) ] );
      h(1) = plot( x, y, ps_grids );
      hold on
      %
      if mark_fields
        i0 = round( length(x)/2 );
        h(5) = plot( x(i0), y(i0), ps_field );
      end

    end
    %
    [x,y] = surf_segment2D( lat_grid, ...
                          [ r_geoid(1)+z_ground(1), r_geoid(1)+z_ground(1) ] );
    h(2) = plot( x, y, ps_ground{:} );
    %
    [x,y] = surf_segment2D( lat_grid, [ r_geoid(1), r_geoid(1) ] );
    h(3) = plot( x, y, ps_geoid );


  %- 2D
  case 2
    %
    if ~isempty( cb_lims )
      ind     = cb_lims(3):cb_lims(4);
      [x1,y1] = surf_segment2D( lat_grid(ind), ...
                                       r_geoid(ind)+z_field(cb_lims(1),ind)' );
      [x2,y2] = surf_segment2D( lat_grid(ind), ...
                                       r_geoid(ind)+z_field(cb_lims(2),ind)' );
      h(4) = patch( [x1 fliplr(x2)], [y1 fliplr(y2)], ps_cloudb );
      set( h(4), 'EdgeColor', ps_cloudb );
      hold on
    end
    %
    for j = 1 : nz
      [x,y] = surf_segment2D( lat_grid, r_geoid+z_field(j,:)' );
      h(1) = plot( x, y, ps_grids );
      hold on
    end
    %
    for j = 1 : length( lat_grid )
      [x,y] = atmplot_pol2cart( [ r_geoid(j)+z_field(1,j), ...
                           r_geoid(j)+z_field(nz,j) ], lat_grid(j)*ones(1,2) );
      plot( x, y, ps_grids );
      %
      if mark_fields
        for k = 1 : nz
          [x,y] = atmplot_pol2cart( r_geoid(j)+z_field(k,j), lat_grid(j) );
          h(5) = plot( x, y, ps_field );
        end
      end
    end
    %
    [x,y] = surf_segment2D( lat_grid, r_geoid+z_ground );
    h(2) = plot( x, y, ps_ground{:} );
    %
    [x,y] = surf_segment2D( lat_grid, r_geoid(1) );
    h(3) = plot( x, y, ps_geoid );

end


%= Set equal axis
%
axis equal


%= Set hold off if this was status at the start
%
if ~figstat
  hold off
end



function [x,y] = surf_segment2D(lat,r)

  % Nominal latitude step length
  nom_dlat = 0.2;

  lat1 = lat(1);
  lat3 = tail( lat, 1 );

  lats  = linspace( lat1, lat3, max([ 2, ceil( (lat3-lat1) / nom_dlat ) ] ) );

  slope = ( tail(r,1) - r(1) ) / ( lat3 - lat1 );

  rs    = r(1) + slope * ( lats - lat1 );
    
  [x,y] = atmplot_pol2cart( rs, lats );
return