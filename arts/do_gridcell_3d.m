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
if isempty( rground1a )
  Q.RGROUND1a = 0;
  Q.RGROUND2a = 0;  
  Q.RGROUND1b = 0;
  Q.RGROUND2b = 0;  
else
  Q.RGROUND1a = rground1a;
  Q.RGROUND2a = rground2a;
  Q.RGROUND1b = rground1b;
  Q.RGROUND2b = rground2b;
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


%= Plot results
%
atmplot_gridcell3D(lat1,lat3,lon5,lon6,r1a,r2a,r3a,r4a,r1b,r2b,r3b,r4b,...
                                      rground1a,rground2a,rground1b,rground2b);
%
hold on
%
atmplot_sph2cart( r, lat, lon, 'b-*' )
%
atmplot_sph2cart( r(1), lat(1), lon(1), 'ro' )
%
if endface == 8
  n = length( r );
  atmplot_sph2cart( r(n), lat(n), lon(n), 'rs' )
end
%
hold off
%
axis equal

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
