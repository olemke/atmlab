% FIND_LEGEND   Handle to legend.
%
%    The function returns the handle to the legend of a figure.
%
%    An error is issued if no legend is found.
%
% FORMAT   h = find_legend
%        
% OUT   h   Handle to the legend.

% 2002-12-12   Created by Patrick Eriksson.


function h = find_legend


h = get( gcf, 'Children' );

found = 0;

ih    = 1;


while ih <= length(h)  &  ~found

  if strcmp( lower( get( h(ih), 'tag' ) ), 'legend' )
    found = 1;
  else
    ih = ih + 1;
  end

end


if ~found

  error('No legend could be found in the figure.');

else

  h = h(ih);

end
