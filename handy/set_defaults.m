% SET_DEFAULTS   Sets default values for input arguments.
%
%    This is a script to help setting defaults values for input arguments
%    (or any other variable, if that would be useful).
%
%    The default value is used if the variable does not exist, or set to
%    be empty. The default value is set by creating a variable with the
%    same name as the main variable, but ending with '_DEFAULT'. For
%    example, if there is an input variable *f*, the default value is set
%    by the variable *f_DEFAULT*. The default variable is removed by the
%    script.
%
%    The start of a function could look like:
%
%    function test(f,z)
%
%    %= Default values
%    %
%    f_DEFAULT = 10e9 : 0.2e9 : 30e9;
%    z_DEFAULT = [ 2e3 7e3 12e3 ];
%    %
%    set_defaults;
%    ...
%
%    The function above can then be called as:
%       test;
%       test(110e9:1e9:120e9);
%       test([],[3e3:1e3:10e3]);
%
%    Be aware of that this is a pure script, not a function. However,
%    the script checks that are no crashes between variable names
%    (long "strange" variable names are used, such as VNS93628462)
%    and the script removes all used local variables.
%     
% FORMAT   set_defaults

% HISTORY: 2004-01-06  Created by Patrick Eriksson



if exist('VNS93628462','var')  |  exist('i93628462','var')  |  ...
   exist('VNF93628462','var')  |  exist('VN93628462','var')

  fprintf('Collision between variable names.\n');
  fprintf('The variable names VNS93628462, i93628462,\n');  
  fprintf('VNF93628462 and VN93628462 are used in this script.\n');
  error('Please, do not use the variable names listed above.');
end


VNS93628462 = who;

for i93628462 = 1 : length(VNS93628462)
  VNF93628462 = VNS93628462{i93628462};
  if length( VNF93628462 ) > 8  &  ...
     strcmp( VNF93628462(length(VNF93628462)+(-7:0)), '_DEFAULT' )
    VN93628462 = VNF93628462( 1 : (length(VNF93628462)-8) );
    if ~exist( eval(['''',VN93628462,'''']), 'var' ) | isempty(VN93628462)
      eval([ VN93628462, '=', VNF93628462 , ';' ])
      eval([ 'clear ', VNF93628462 ])
    end
  end
end

clear VNS93628462 VNF93628462 VN93628462 i93628462 