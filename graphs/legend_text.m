% LEGEND_TEXT   Properties of legend text.
%
%    Allows to modify all properties of the legend text. The given properties
%    are applied to the text string for all plotting symbols. 
%
%    To change the fontsize to 10:
%       legend_text( 'FontSize', 10 );
%
% FORMAT   h = legend_text('Property1',PropertyValue1,...)
%        
% OUT   h   Handle to legend text objects.
% IN        Arbitrary number of property / property value pairs.

% 2002-12-12   Created by Patrick Eriksson.


function h = legend_text(varargin)


%=== Check input
%
if ~iseven( length(varargin) )
  error('Input be pairs of property and its value.');
end



%=== Find text objects among legend children.
%
h = find_legend;
%
h = children( h );
n = length( h );
%
tobject = zeros( n, 1 );
%
for ih = 1 : n
  if strcmp( lower( get( h(ih), 'type' ) ), 'text' )
    tobject(ih) = 1;
    set( h(ih), varargin{:} );
  end
end


h = h( find( tobject ) );