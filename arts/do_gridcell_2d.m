% ATMPLOT_GRIDCELL2D   2D grid cell plot.
%
%    The function plots a 2D grid cell. The pressure surfaces are plotted
%    with linear segments in steps of 0.5 degrees latitude. Latitude 0
%    is placed in the upward direction. That means that grid cells centered 
%    around latitude 0 will look nice in the plot.
%
%    The function does not change the hold status of the plot.
%
%    If no ground radius is given, the ground will no be included in the plot.
%
% FORMAT   atmplot_gridcell2D(lat1,lat3,r1,r2,r3,r4,rground1,rground2)
%        
% IN    lat1       Latitude of left end face of the grid cell
%	lat3       Latitude of right end face of the grid cell
%       r1         Radius of lower-left corner of the grid cell
%       r2         Radius of lower-right corner of the grid cell.
%	r3         Radius of upper-right corner of the grid cell.
%       r4         Radius of upper-left corner of the grid cell.
% OPT   rground1   Radius for the ground at *lat1*. Default is [].
%       rground2   Radius for the ground at *lat3*. Default is [].

% 2002-12-21   Created by Patrick Eriksson.


function [r,lat,za,lstep,endface] = do_gridcell_2d(r,lat,za,lmax,lat1,lat3,r1,r2,r3,r4,at_lower,at_upper,rground1,rground2)


%= Input
%
min_nargin( 12, nargin );
%
if nargin < 13
  rground1 = [];
  rground2 = [];
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
atmplot_pol2cart( r, lat, 'b-' )
%
hold off

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
