% DO_GRIDCELL_3D   The ARTS function with the same name.
%
%    The ARTS function with the same name is called (by the WSM DoGridcell3d)
%    and the result is plotted. For further information, see the ARTS 
%    documantation.
%
%    The grid cell and the ground are plotted by *atmplot_gridcell2D*. 
%    The path is plotted as 'b-*', where the a red ring is drawn around 
%    the * for the start point, and a red square for a tangent point.  
%
%    Grid cell corner points are named as rxy, where:
%       lower pressure surface : x=1 or x = 2 
%   	upper pressure surface : x=3 or x = 4
%   	lower latitude (lat1)  : x=1 or x = 4
%   	upper latitude (lat3)  : x=2 or x = 3
%   	lower longitude (lon5) : y=a 
%   	upper longitude (lon6) : y=b 
%    See also figure in AUG. Ground radii are named as the lower pressure 
%    surface.
% 
% FORMAT   [r,lat,lon,za,aa,lstep,endface] = do_gridcell_3d(r,lat,lon,za,aa,
%                    lmax,lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,
%                    rground1a,rground2a,rground1b,rground2b)
%        
% OUT   r          Vector with radius of found path points.
%       lat        Vector with latitude of found path points.
%       lon        Vector with longitude of found path points.
%       za         Vector with LOS zenith angle at found path points.
%       aa         Vector with LOS azimuth angle at found path points.
%       lstep      Distance along the path between the points. All points are
%                  equally spaced.
%       endface    Number coding of grid cell face of exit point. See 
%                  header of the ARTS function.
% IN    r          Radius of start point for path to calculate.
%       lat        Latitude of start point for path to calculate.
%       lon        Longitude of start point for path to calculate.
%       za         LOS zenith angle at start point for path to calculate.
%       aa         LOS azimuth angle at start point for path to calculate.
%       lmax       Maximum lengt between points to define the path. -1 means
%                  that just grid crossings and tangent points are included.
%       lat1       Lower latitude of the grid cell.
%	lat3       Upper latitude of the grid cell.
%       lon5       Lower longitude of the grid cell.
%	lon6       Upper longitude of the grid cell.
%   	r1a        Radius of one corner point (see above).
%   	r2a        Radius of one corner point (see above).
%   	r3a        Radius of one corner point (see above).
%   	r4a        Radius of one corner point (see above).
%   	r1b        Radius of one corner point (see above).
%   	r2b        Radius of one corner point (see above).
%   	r3b        Radius of one corner point (see above).
%   	r4b        Radius of one corner point (see above).
%       rground1a  Radius for the ground at *lat1* and *lon5*.
%       rground2a  Radius for the ground at *lat3* and *lon5*.
%       rground1b  Radius for the ground at *lat1* and *lon6*.
%       rground2b  Radius for the ground at *lat3* and *lon6*.  

% 2002-12-21   Created by Patrick Eriksson.


function [r,lat,lon,za,aa,lstep,endface] = do_gridcell_3d(r,lat,lon,za,aa,lmax,lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,rground1a,rground2a,rground1b,rground2b)


%= Input
%
min_nargin( 18, nargin );
%
if nargin < 19
  rground1a = [];
  rground2a = [];
  rground1b = [];
  rground2b = [];
end


%= Set the variables at_upper and at_lower
%
at_lower = 0;
at_upper = 0;


%- Set to 1 if the Matlab version shall be used
if 1
  [r,lat,lon,za,aa,lstep,endface] = do_gridcell_3d(r,lat,lon,za,aa,lmax,lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,rground1a,rground2a,rground1b,rground2b)

else

  %= Set the fields of Q. 
  %
  Q.R    = r;
  Q.LAT  = lat;
  Q.LON  = lon;
  Q.ZA   = za;
  Q.AA   = aa;
  Q.LMAX = lmax;
  Q.LAT1 = lat1;
  Q.LAT3 = lat3;
  Q.LON5 = lon5;
  Q.LON6 = lon6;
  Q.R1a  = r1a;
  Q.R2a  = r2a;
  Q.R3a  = r3a;
  Q.R4a  = r4a;
  Q.R1b  = r1b;
  Q.R2b  = r2b;
  Q.R3b  = r3b;
  Q.R4b  = r4b;
  Q.AT_LOWER = at_lower;
  Q.AT_UPPER = at_upper;
  if ~isempty( rground1a )
    Q.RGROUND1a = rground1a;
    Q.RGROUND2a = rground2a;
    Q.RGROUND1b = rground1b;
    Q.RGROUND2b = rground2b;
  else
    Q.RGROUND1a = 0;
    Q.RGROUND2a = 0;
    Q.RGROUND1b = 0;
    Q.RGROUND2b = 0;
  end

  %= Create a temporary folder
  %
  tmpfolder = create_tmpfolder;


  %= Create a name of a control file inside the temporary folder
  %
  cfileshort = fullfile( tmpfolder, 'cfile' );
  cfilelong  = fullfile( tmpfolder, 'cfile.arts' );


  %= Create the control file
  %
  qtool( cfiletemplate, cfilelong, Q );


  %= Execute ARTS and load the result
  %
  call_fmodel( cfilelong );
  %
  r   	= xmlLoad( [ cfileshort, '.r.xml' ] );
  lat 	= xmlLoad( [ cfileshort, '.lat.xml' ] );
  lon 	= xmlLoad( [ cfileshort, '.lon.xml' ] );
  za 	= xmlLoad( [ cfileshort, '.za.xml' ] );
  aa 	= xmlLoad( [ cfileshort, '.aa.xml' ] );
  lstep 	= xmlLoad( [ cfileshort, '.lstep.xml' ] );
  endface = xmlLoad( [ cfileshort, '.endface.xml' ] );



  %= Remove the temporary folder
  %
  delete_tmpfolder( tmpfolder );

end



%= Plot results
%
atmplot_gridcell3D(lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,...
                                      rground1a,rground2a,rground1b,rground2b);
%
hold on
%
atmplot_sph2cart( r, lat, lon, 'b-*' );
%
atmplot_sph2cart( r(1), lat(1), lon(1), 'ro' );
%
if endface == 8
  n = length( r );
  atmplot_sph2cart( r(n), lat(n), lon(n), 'rs' );
end
%
axis equal
hold off


return



%----------------------------------------------------------------------

function S = cfiletemplate

S = { ...
'Main{', ...
'DoGridcell3D{', ...
'   r_start    = $Q.R$', ...
'   lat_start  = $Q.LAT$', ...
'   lon_start  = $Q.LON$', ...
'   za_start   = $Q.ZA$', ...
'   aa_start   = $Q.AA$', ...
'   lmax       = $Q.LMAX$', ...
'   r1a        = $Q.R1a$', ...
'   r2a        = $Q.R2a$', ...
'   r3a        = $Q.R3a$', ...
'   r4a        = $Q.R4a$', ...
'   r1b        = $Q.R1b$', ...
'   r2b        = $Q.R2b$', ...
'   r3b        = $Q.R3b$', ...
'   r4b        = $Q.R4b$', ...
'   lat1       = $Q.LAT1$', ...
'   lat3       = $Q.LAT3$', ...
'   lon5       = $Q.LON5$', ...
'   lon6       = $Q.LON6$', ...
'   at_lower   = $Q.AT_LOWER$', ...
'   at_upper   = $Q.AT_UPPER$', ...
'   rground1a  = $Q.RGROUND1a$', ...
'   rground2a  = $Q.RGROUND2a$', ...
'   rground1b  = $Q.RGROUND1b$', ...
'   rground2b  = $Q.RGROUND2b$', ...
'}', ...
'}'
};




%--- Matlab version of the function, and help functions

function r = r_at_latlon(lat1,lat3,lon5,lon6,r15,r35,r36,r16,lat,lon)
  
  if( lat == lat1 )
    r = r15 + ( lon - lon5 ) * ( r16 - r15 ) / ( lon6 -lon5 );
  elseif( lat == lat3 )
    r = r35 + ( lon - lon5 ) * ( r36 - r35 ) / ( lon6 -lon5 );
  elseif( lon == lon5 )
    r = r15 + ( lat - lat1 ) * ( r35 - r15 ) / ( lat3 -lat1 );
  elseif( lon == lon6 )
    r = r16 + ( lat - lat1 ) * ( r36 - r16 ) / ( lat3 -lat1 );
  else
    fdlat = ( lat - lat1 ) / ( lat3 - lat1 );
    fdlon = ( lon - lon5 ) / ( lon6 - lon5 );
    r = (1-fdlat)*(1-fdlon)*r15 + fdlat*(1-fdlon)*r35 + ...
                                         (1-fdlat)*fdlon*r16 + fdlat*fdlon*r36;
  end
return



function [r,lat,lon,l] = psurface_crossing_3d(lat1,lat3,lon5,lon6,...
                                                r15,r35,r36,r16,x,y,z,dx,dy,dz)
  
  rmin = min( [  r15, r35, r36, r16 ] );
  rmax = max( [  r15, r35, r36, r16 ] );

  if( rmax > rmin )
    ntest  = 5;
    rtest  = linspace( rmin, rmax, ntest );
  else
    ntest  = 1;
    rtest  = rmin;
  end

  any_hit = 0;

  rfound   = zeros( 1, ntest );
  latfound = zeros( 1, ntest );
  lonfound = zeros( 1, ntest );
  lfound   = zeros( 1, ntest );

  for j = 1 : ntest
    [rfound(j),latfound(j),lonfound(j),lfound(j)] = ...
                               gridcell_crossing_3d(x,y,z,dx,dy,dz,1,rtest(j));
    if( rfound(j) > 0 )
      any_hit   = 1;
      rfound(j) = r_at_latlon(lat1,lat3,lon5,lon6,r15,r35,r36,r16,...
                                                      latfound(j),lonfound(j));
    end
  end

  % --- 
  if( ntest > 1  &  any_hit )
    ok = 0;
    j  = 1;
    while( ~ok  &  j < ntest )
      if( round(j) > 0  &  rfound(j+1) > 0  &  rfound(j) >= rtest(j)  &  ...
                                                    rfound(j+1) <= rtest(j+1) )
        rq1      = rtest(j) / rfound(j);
        rq2      = rtest(j+1) / rfound(j+1);
        rtest(1) = rtest(j) + (rtest(j+1)-rtest(j)) * (1-rq1) / (rq2-rq1);
        [rfound(1),latfound(1),lonfound(1),lfound(1)] = ...
                               gridcell_crossing_3d(x,y,z,dx,dy,dz,1,rtest(1));
        ok = 1;
      end
      j = j+ 1;
    end
  else
    ok = 1;
  end

  if( ok )
    r   = rfound(1);
    lat = latfound(1);
    lon = lonfound(1);
    l   = lfound(1);
  else
    r   = -1;
    lat = 999;
    lon = 999;
    l   = -1;
  end

return



function [r,lat,lon,za,aa,lstep,endface] = do_gridcell_3d(r0,lat0,lon0,za0,aa0,lmax,lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,rground1a,rground2a,rground1b,rground2b)

  DEG2RAD = constants( 'DEG2RAD' );
  RAD2DEG = constants( 'RAD2DEG' );

  ppc = r0 * sin( DEG2RAD * za0 );

  % Assert that the give position is inside the grid cell

  % Position and LOS in cartesian coordinates
  [x,y,z,dx,dy,dz] = poslos2cart(r0,lat0,lon0,za0,aa0);

  % Check possible crossing with faces in number order
  % The crossing with the lowest distance *l* is what we want.
  l_best  = 99999e3;
  endface = 0;


  % --- Face 1: along lat1
  %
  if( abs( aa0 ) > 90 )
    [r_try,lat_try,lon_try,l_try] = ...
                                   gridcell_crossing_3d(x,y,z,dx,dy,dz,2,lat1);
    if( r_try > 0  &  l_try < l_best  &  lon_try >= lon5  &  lon_try <= lon6 )
      rlow  = r_at_latlon(lat1,lat3,lon5,lon6,r1a,r2a,r2b,r2a,lat_try,lon_try);
      rhigh = r_at_latlon(lat1,lat3,lon5,lon6,r4a,r3a,r3b,r4a,lat_try,lon_try);
      if( r_try >= rlow  &  r_try <= rhigh )
        r_best   = r_try;
        lat_best = lat_try;
        lon_best = lon_try;
        l_best   = l_try;
        endface  = 1;
      end
    end
  end

  % --- Face 2: lower pressure surface
  %
  if( za0 > 0 )
    [r_try,lat_try,lon_try,l_try] = psurface_crossing_3d(lat1,lat3, ...
                                     lon5,lon6,r1a,r2a,r2b,r1b,x,y,z,dx,dy,dz);
    if( r_try > 0  &  l_try < l_best  &  lat_try >= lat1  &  ...
                      lat_try <= lat3  &  lon_try >= lon5  &  lon_try <= lon6 )
      r_best   = r_try;
      lat_best = lat_try;
      lon_best = lon_try;
      l_best   = l_try;
      endface  = 2;
    end
  end

  % --- Face 3: along lat3
  %
  if( abs( aa0 ) < 90 )
    [r_try,lat_try,lon_try,l_try] = ...
                                   gridcell_crossing_3d(x,y,z,dx,dy,dz,2,lat3);
    if( r_try > 0  &  l_try < l_best  &  lon_try >= lon5  &  lon_try <= lon6 )
      rlow  = r_at_latlon(lat1,lat3,lon5,lon6,r1a,r2a,r2b,r2a,lat_try,lon_try);
      rhigh = r_at_latlon(lat1,lat3,lon5,lon6,r4a,r3a,r3b,r4a,lat_try,lon_try);
      if( r_try >= rlow  &  r_try <= rhigh )
        r_best   = r_try;
        lat_best = lat_try;
        lon_best = lon_try;
        l_best   = l_try;
        endface  = 3;
      end
    end
  end

  % --- Face 4: upper pressure surface
  %
  if( za0 < 180 )
    [r_try,lat_try,lon_try,l_try] = psurface_crossing_3d(lat1,lat3, ...
                                     lon5,lon6,r4a,r3a,r3b,r4b,x,y,z,dx,dy,dz);
    if( r_try > 0  &  l_try < l_best  &  lat_try >= lat1  &  ...
                      lat_try <= lat3  &  lon_try >= lon5  &  lon_try <= lon6 )
      r_best   = r_try;
      lat_best = lat_try;
      lon_best = lon_try;
      l_best   = l_try;
      endface  = 4;
    end
  end

  % --- Face 5: along lon5
  %
  if( aa0 < 0 )
    [r_try,lat_try,lon_try,l_try] = ...
                                   gridcell_crossing_3d(x,y,z,dx,dy,dz,3,lon5);
    if( r_try > 0  &  l_try < l_best  &  lat_try >= lat1  &  lat_try <= lat3 )
      rlow  = r_at_latlon(lat1,lat3,lon5,lon6,r1a,r2a,r2b,r2a,lat_try,lon_try);
      rhigh = r_at_latlon(lat1,lat3,lon5,lon6,r4a,r3a,r3b,r4a,lat_try,lon_try);
      if( r_try >= rlow  &  r_try <= rhigh )
        r_best   = r_try;
        lat_best = lat_try;
        lon_best = lon_try;
        l_best   = l_try;
        endface  = 5;
      end
    end
  end

  % --- Face 6: along lon6
  %
  if( aa0 > 0 )
    [r_try,lat_try,lon_try,l_try] = ...
                                   gridcell_crossing_3d(x,y,z,dx,dy,dz,3,lon6);
    if( r_try > 0  &  l_try < l_best  &  lat_try >= lat1  &  lat_try <= lat3 )
      rlow  = r_at_latlon(lat1,lat3,lon5,lon6,r1a,r2a,r2b,r2a,lat_try,lon_try);
      rhigh = r_at_latlon(lat1,lat3,lon5,lon6,r4a,r3a,r3b,r4a,lat_try,lon_try);
      if( r_try >= rlow  &  r_try <= rhigh )
        r_best   = r_try;
        lat_best = lat_try;
        lon_best = lon_try;
        l_best   = l_try;
        endface  = 6;
      end
    end
  end

  % --- Face 7: the ground
  %
  if( za0 > 0  &  ( rground1a >= r1a  |  rground2a >= r2a  |  ...
                                      rground1b >= r1b  |  rground2b >= r2b ) )
    [r_try,lat_try,lon_try,l_try] = psurface_crossing_3d(lat1,lat3, ...
             lon5,lon6,rground1a,rground2a,rground2b,rground1b,x,y,z,dx,dy,dz);
    if( r_try > 0  &  l_try < l_best  &  lat_try >= lat1  &  ...
                      lat_try <= lat3  &  lon_try >= lon5  &  lon_try <= lon6 )
      r_best   = r_try;
      lat_best = lat_try;
      lon_best = lon_try;
      l_best   = l_try;
      endface  = 7;
    end
  end

  if( ~endface )
    error('No end face has been found.');
  end

  % --- Face 8: tangent point
  %
  if( za0 > 90 )
    [r_try,lat_try,lon_try,za_try,aa_try] =...
                     cart2poslos(x+dx*l_best,y+dy*l_best,z+dz*l_best,dx,dy,dz);
    if( za_try <= 90 )
      l_best  = sqrt( r0*r0 - ppc*ppc );;
      [r_best,lat_best,lon_best,za_try,aa_try] = ...
                     cart2poslos(x+dx*l_best,y+dy*l_best,z+dz*l_best,dx,dy,dz);
      endface = 8;
    end
  end

  % --- Create return vectors
  %
  if( lmax > 0 )
    n = ceil( abs( l_best / lmax ) );
    if( n < 1 )
      n = 1;
    end
  else
    n = 1;
  end

  lstep = l_best / n;
  r     = zeros( n+1, 1 );
  lat   = zeros( n+1, 1 );
  lon   = zeros( n+1, 1 );
  za    = zeros( n+1, 1 );
  aa    = zeros( n+1, 1 );

  r(1)   = r0;
  lat(1) = lat0;
  lon(1) = lon0;
  za(1)  = za0;
  aa(1)  = aa0;

  for j = 2 : (n+1)
    l  = lstep * ( j - 1 );
    [r(j),lat(j),lon(j),za(j),aa(j)] =...
                                    cart2poslos(x+dx*l,y+dy*l,z+dz*l,dx,dy,dz);
  end

  % --- Set last point to values found above, which should improve the
  %     numerical accuracy
  r(n+1)   = r_best;
  lat(n+1) = lat_best;
  lon(n+1) = lon_best;

  % --- Set last zenith angle to be as accurate as possible
  if( endface == 8 )
    za(n+1) = 90;
  else
    % za(n+1) = geompath_za_at_r( ppc, za0, r(n+1) );
  end

return