% CALL_FMODEL   Run a forward model calculation.
%
%    The function runs the forward model by a system call and waits for
%    the execution to end.
%
%    Both FMODEL_NAME and FMODEL_EXEC are required personal settings.
%    See CONFIGURE.
%
%    The different forward models are called with these string patterns:
%
%    'arts'
%       [ FMODEL_EXEC, ' ', cfile ]
%
% FORMAT   est = call_fmodel([args,etol])
%        
% OUT   est    Error status. If all OK, *est* = 0. Otherwise, *est* = 1.
% OPT   cfile  Argument string. The usage of this string can vary between
%              forward models, but the standard choice would be to give the
%              name of a control file. See atmlab/atmlab_defs for information.
%       etol   Boolean for tolerate errors. Default is 0, which means that
%              forward model errors also give a Matlab error.

% 2002-12-20   Created by Patrick Eriksson.


function est = call_fmodel(cfile,etol)


%= Input
%
if nargin < 1
  cfile = '';
end
%
if nargin < 2
  etol = 0;
end


fmodelname = atmlab( 'FMODEL_NAME', 1 );

fmodelexec = atmlab( 'FMODEL_EXEC', 1 );


switch fmodelname

  case 'arts'
    %
    c = [ fmodelexec, ' ', cfile ];

  otherwise
    % 
    serr = sprintf('You have selected an unknown forwrad model (%s).', ...
                                                                  fmodelname );
    error( serr );
end


st = system( c );


if st 
  fprintf('\n');
  serr = sprintf('An error ocurred when calling %s (see above)', fmodelname );
  if etol
    warning( serr );
  else
    error( serr );
  end
  est = 1;
else
  est = 0;
end