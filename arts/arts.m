% ARTS   Call ARTS 
%
%    Calls ARTS where path to executable and verbosity are taken from 
%    personal settings. That is, the settings ARTS_PATH and 
%    FMODEL_VERBOSITY are used (see futher*atmlab*).
%
%    Note that Matlab allows a call as
%        arts -h;
%    which can be usefull when working in Matlab and you want to use the
%    on-line documentation of ARTS. If your call needs an argument, put
%    all inside a string, as:
%       arts '-w all';
%
% FORMAT   [status,result] = arts( cfile [,errortol] )
%        
% OUT   status     Status returned by ARTS. Is 0 if all OK.
%       result     String containing messages to standard output.
% IN    cfile      Name on control file, or OK command line option such as
%                  '-h'.
% OPT   errortol   Flag to tolerate error. If set to 0, an ARTS error gives
%                  rise also to a Matlab error. Default is 0.

% 2004-09-07   Created by Patrick Eriksson.

function [status,result] = arts(cfile,varargin)
%
[errortol] = optargs( varargin, { false } );
                                                                
if atmlab('STRICT_ASSERT')
  %
  atmlab( 'require', {'ARTS_PATH','FMODEL_VERBOSITY'} ); 
  %
  exec   = atmlab( 'ARTS_PATH' );
  rlevel = atmlab( 'FMODEL_VERBOSITY' );
  %                                                         
  if isempty( exec )                                       
    error('Path to ARTS executable must be a string.');    
  end
else
  exec   = atmlab( 'ARTS_PATH' );
  rlevel = atmlab( 'FMODEL_VERBOSITY' );
end


if isempty( rlevel )                                     
  rlevel = 0;                                            
end                                                      


outdir = fileparts( cfile );


% The call involving bash introduced 2015-08-28. Pattern suggested by 
% Oliver L. THis after problems with an old matlab version. The speculation
% is that the old version does not catch stderr, and result could end up
% empty. The bash solution should hopefully fix this!?

if isempty( outdir )
  [status,result] = system( sprintf( ...
                               'bash -c "%s -r%d0 %s" 2>&1', exec, rlevel, cfile ) );
  %[status,result] = system( ...
  %                     sprintf('%s -r%d0 %s', exec, rlevel, cfile ) );
else
  [status,result] = system( sprintf( ...
                 'bash -c "%s -r%d0 -o %s %s" 2>&1', exec, rlevel, outdir, cfile ) );
%  [status,result] = system( ...
%         sprintf('%s -r%d0 -o %s %s', exec, rlevel, outdir, cfile ) );
end


if ~isempty( result )  &  nargout < 2
  disp( result )
end


if status  &  ~errortol
  error('An error occured while executing ARTS. See above.')
end

