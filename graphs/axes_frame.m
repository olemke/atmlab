% AXES_FRAME   Visibility of axes frame.
%
%    The functions makes the frame for some axes visible or invisible.
%
% FORMAT   axes_frame(h,on_or_off)
%        
% IN    h           Handle to the axes.
%       on_or_off   Either 'on' or 'off'.

% 2002-12-12   Created by Patrick Eriksson.


function axes_frame(h,on_or_off)


%=== Check input
%
min_nargin( 2, nargin );
%
if ~( strcmp( on_or_off, 'off' )  |  strcmp( on_or_off, 'on' ) )
  error('Valid actions are ''off'' and ''on''.');
end



if strcmp( on_or_off, 'off' )
  %
  set( h, 'Box', 'off' );
  set( h, 'XCol', [1 1 1] );
  set( h, 'YCol', [1 1 1] );

else
  %
  set( h, 'Box', 'on' );
  set( h, 'XCol', [0 0 0] );
  set( h, 'YCol', [0 0 0] );

end
