% INPUT_SCALAR   Prompts for user input of scalar type.
%
%    Works as INPUT but accepts only scalar imput. It is also possible
%    to define a range for allowed input. For example:
%
%	v = input_scalar( 'Select shoe size', 30, 50 );
%
%     results in
%
%       Select shoe size [30 <= v <= 50]: 
%
% FORMAT   v = input_scalar( s, vlow, vhigh )
%
% OUT      v       User input.
% IN       s       String describing the selection
% OPT      vlow    A lower limit for the selection. Default is [], which
%                  means no lower limit.
%          vhigh   An upper limit for the selection.Default is [], which
%                  means upper lower limit.

% HISTORY: 2003-03-07  Created by Patrick Eriksson

function v = input_scalar( s, vlow, vhigh )


if nargin == 4
  sdef = [' (default = ',num2str(vdefault),')']
else
  sdef = [];
end


while 1

  fprintf('\n');

  switch nargin
 
    case 1
      v = input( [s,sdef,': '] );
      if isscalar(v)
        return;
      end

    case 2
      v = input( [s,sdef,' [v >= ',num2str(vlow),']: '] );
      if isscalar(v)  &  v >= vlow
        return;
      end

    case 3
      if isempty(vlow)
        v = input( [s,sdef,' [v <= ',num2str(vhigh),']: '] );
        if isscalar(v)  &  v <= vhigh
          return;
        end
      else
        v = input( [s,sdef, ...
                        ' [',num2str(vlow),' <= v <= ',num2str(vhigh),']: '] );
        if isscalar(v)  &  v >= vlow  &  v <= vhigh
          return;
        end
      end
  end

  fprintf('Incorrect selection. Please try again:\n');
end