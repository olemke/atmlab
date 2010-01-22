% ARTS   Call ARTS 
%
%    Calls ARTS where path to executable and verbosity are taken from personal
%    settings. That is, the settings ARTS_PATH and 
%    FMODEL_VERBOSITY are used (see futher*atmlab*).
%
%    Note that Matlab allows a call as
%        arts -h;
%    which can be usefull when working in Matlab and you want to use the
%    on-line documentation of ARTS. If your call needs an argument, put
%    all inside a string, as:
%       arts '-w all';
%
% FORMAT   status = arts( cfile [,errortol] )
%        
% OUT   status     Status returned by ARTS. Is 0 if all OK.
% IN    cfile      Name on control file, or OK command line option such as
%                  '-h'.
% OPT   errortol   Flag to tolerate error. If set to 0, an ARTS error gives
%                  rise also to a Matlab error. Default is 0.

% 2004-09-07   Created by Patrick Eriksson .


function status = arts(cfile,errortol)

if nargin < 2
  errortol = 0;
end
                                                                 %&%
atmlab( 'require', {'ARTS_PATH','FMODEL_VERBOSITY'} );           %&%

exec = atmlab( 'ARTS_PATH' );
rlevel = atmlab( 'FMODEL_VERBOSITY' );
                                                                 %&%
if isempty( exec )                                               %&%
  error('Path to ARTS executable must be a string.');            %&%
end                                                              %&%
if isempty( rlevel )                                             %&%
  rlevel = 0;                                                    %&%
end                                                              %&%

status = system( sprintf('%s -r%d0 %s', exec, rlevel, cfile ) );

if status  &  ~errortol
  fprintf('\n');
  error('An error occured while executing ARTS. See above.')
end

