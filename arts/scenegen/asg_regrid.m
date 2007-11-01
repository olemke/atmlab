% ASG_REGRID   Re-gridding of ASG data.
%
%    The data are re-gridded to match Q.P_GRID, Q.LAT_GRID and Q.LON_GRID. 
%    These grids must be set before calling this function (that is, scalar
%    input is not allowed as for *asg_atmgrids*).
%
%    Interpolation in pressure is performed after conversion to pressure
%    decades. Nothing is done if the DATA field is empty. 
%
% FORMAT   G = asg_regrid( D, G, Q )
%        
% OUT   G   Re-gridded ASG data.
% IN    D   Gformat definition structure.
%       G   ASG data.
%       Q   Qarts setting structure.

% 2007-10-08   Created by Patrick Eriksson


function G = asg_regrid( D, G, Q )


%- Basic checks
%
% D and G are partially checked inside gf functions.
% Full check of D, G and Q is only made in *asg_chdim* for efficiency reasons.


%- Create array with new grids. 
%
grids = { Q.P_GRID, Q.LAT_GRID, Q.LON_GRID };


%- Switch to pressure decades
%
grids{1} = gridconvert( grids{1}, 0, @log10, 1 );
G        = gf_grid_convert( D, G, 1, 0, @log10, 1 );
 

for ig = 1 : length(G)

  %- Do nothing if DATA or DIMS field is empty.
  
  if ~isempty( G(ig).DATA )  &  ~isempty( G(ig).DIMS )  
    
    dims = G(ig).DIMS;
    
    try
      G(ig) = gf_regrid( D, G(ig), { grids{dims} }, dims );
    catch
      fprintf( '%s\n\n', lasterr );
      error( sprintf('Message above applies to G(%d).',ig) );
    end
    
  end
  
end

  
%- Back to Pa
%
G        = gf_grid_convert( D, G, 1, 1, @pow10 );

