% SCALE_LEGEND   Changes the size of a legend box.
%
%    The function allows to change the size of the legend box by giving
%    a scaling factor for the horisontal and vertical directions. 
%
%    A scaling factor of 1.2 means that the box will be 20% larger in the
%    direction of concern.
%
%    The lower-left corner of the box will not be moved by the re-sizing.
%
% FORMAT   h = scale_legend(hscfac[,vscfac])
%        
% OUT   h        Handle to the legend.
% IN    hscfac   Horisontal scaling factor.
% OPT   vscfac   Vertical scaling factor. Default is 1.

% 2002-12-12   Created by XXX.


function h = scale_legend(hscfac,vscfac)


%=== Check input and defaults
%
min_nargin( 1, nargin );
%
if ~isscalar( hscfac )  |  hscfac <= 0
  error('The horisonal scaling factor must be a scalar >= 0.');
end
%
if nargin < 2
  vscfac = 1
else
  if ~isscalar( vscfac )  |  vscfac <= 0
    error('The vertical scaling factor must be a scalar >= 0.');
  end
end


h = find_legend;


pos = get( h, 'position' );


set( h, 'position', [pos(1:2) pos(3)*hscfac pos(4)*vscfac] );