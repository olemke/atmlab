% DO_GRIDCELL_2D   The ARTS function with the same name.
%
%    The ARTS function with the same name is called (by the WSM DoGridcell2d)
%    and the result is plotted. For further information, see the ARTS 
%    documantation.
%
%    The grid cell and the ground are plotted by *atmplot_gridcell2D*. 
%    The path is plotted as 'b-*', where the a red ring is drawn around 
%    the * for the start point, and a red square for a tangent point.  
%
% FORMAT   [r,lat,za,lstep,endface] = do_gridcell_2d(r,lat,za,lmax,lat1,lat3,
%                                                r1,r2,r3,r4,rground1,rground2)
%        
% OUT   r          Vector with radius of found path points.
%       lat        Vector with latitude of found path points.
%       za         Vector with LOS zenith angle at found path points.
%       lstep      Distance along the path between the points. All points are
%                  equally spaced.
%       endface    Number coding of grid cell face of exit point. See 
%                  header of the ARTS function.
% IN    r          Radius of start point for path to calculate.
%       lat        Latitude of start point for path to calculate.
%       za         LOS zenath angle at start point for path to calculate.
%       lmax       Maximum lengt between points to define the path. -1 means
%                  that just grid crossings and tangent points are included.
%       lat1       Latitude of left end face of the grid cell
%	lat3       Latitude of right end face of the grid cell
%       r1         Radius of lower-left corner of the grid cell
%       r2         Radius of lower-right corner of the grid cell.
%	r3         Radius of upper-right corner of the grid cell.
%       r4         Radius of upper-left corner of the grid cell.
% OPT   rground1   Radius for the ground at *lat1*. Default is [].
%       rground2   Radius for the ground at *lat3*. Default is [].

% 2002-12-21   Created by Patrick Eriksson.


function [r,lat,za,lstep,endface] = do_gridcell_2d(r,lat,za,lmax,lat1,lat3,r1,r2,r3,r4,rground1,rground2)


%= Input
%
min_nargin( 10, nargin );
%
if nargin < 11
  rground1 = [];
  rground2 = [];
end


%= Set the variables at_upper and at_lower
%
at_lower = 0;
at_upper = 0;
%
c = ( r2 - r1 ) / ( lat3 - lat1 );
if r == r1 + c * ( lat - lat1 )
  at_lower = 1;
end
%
c = ( r3 - r4 ) / ( lat3 - lat1 );
if r == r4 + c * ( lat - lat1 )
  at_upper = 1;
end


%= Set the fields of Q. 
%
Q.R    = r;
Q.LAT  = lat;
Q.ZA   = za;
Q.LMAX = lmax;
Q.LAT1 = lat1;
Q.LAT3 = lat3;
Q.R1   = r1;
Q.R2   = r2;
Q.R3   = r3;
Q.R4   = r4;
Q.AT_LOWER = at_lower;
Q.AT_UPPER = at_upper;
if isempty( rground1 )
  Q.RGROUND1 = 0;
  Q.RGROUND2 = 0;  
else
  Q.RGROUND1 = rground1;
  Q.RGROUND2 = rground2;
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
za 	= xmlLoad( [ cfileshort, '.za.xml' ] );
lstep 	= xmlLoad( [ cfileshort, '.lstep.xml' ] );
endface = xmlLoad( [ cfileshort, '.endface.xml' ] );



%= Remove the temporary folder
%
delete_tmpfolder( tmpfolder );


%= Plot results
%
atmplot_gridcell2D(lat1,lat3,r1,r2,r3,r4,rground1,rground2)
%
hold on
%
atmplot_pol2cart( r, lat, 'b-*' )
%
atmplot_pol2cart( r(1), lat(1), 'ro' )
%
if endface == 8
  n = length( r );
  atmplot_pol2cart( r(n), lat(n), 'rs' )
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
'DoGridcell2D{', ...
'   r_start    = $Q.R$', ...
'   lat_start  = $Q.LAT$', ...
'   za_start   = $Q.ZA$', ...
'   lmax       = $Q.LMAX$', ...
'   r1         = $Q.R1$', ...
'   r2         = $Q.R2$', ...
'   r3         = $Q.R3$', ...
'   r4         = $Q.R4$', ...
'   lat1       = $Q.LAT1$', ...
'   lat3       = $Q.LAT3$', ...
'   at_lower   = $Q.AT_LOWER$', ...
'   at_upper   = $Q.AT_UPPER$', ...
'   rground1   = $Q.RGROUND1$', ...
'   rground2   = $Q.RGROUND2$', ...
'}', ...
'}'
};
