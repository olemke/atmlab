% LEGEND_TITLE   Legend title.
%
%    Adds text at the top of the legend of the current figure.
%
%    Works as *title* but acts on the legend.
%
% FORMAT   legend_title(s[,'Property1',PropertyValue1,...])
%        
% OUT   ht   Handle to the title.
% IN    s    Title string.
% OPT        Arbitrary number of propoert / property value pairs.

% 2002-12-12   Created by Patrick Eriksson.


function ht = legend_title(s,varargin)


%=== Check input
%
min_nargin( 1, nargin );
%
if ~iseven( length(varargin) )
  error('Input arguments beside *s* must be property pairs.');
end

h = find_legend;

ht = get( h, 'title' );

set( ht, 'string', s, varargin{:} );