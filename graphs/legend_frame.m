% LEGEND_FRAME   Visibility of legend frame.
%
%    The functions makes the legend frame visible or invisible.
%
% FORMAT   h = legend_frame(on_or_off)
%        
% OUT   h           Handle to the legend.
% IN    on_or_off   Either 'on' or 'off'.

% 2002-12-12   Created by Patrick Eriksson.


function h = legend_frame(on_or_off)


%=== Check input
%
min_nargin( 1, nargin );
%
if ~( strcmp( on_or_off, 'off' )  |  strcmp( on_or_off, 'on' ) )
  error('Valid actions are ''off'' and ''on''.');
end


h = find_legend;


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