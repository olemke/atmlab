% MIN_NARGIN   Gives an error if to few input arguments.
%
%    This is a function to facliate checking of a minimum number of input
%    arguments. The standard choice would be to send *nargin* as argument
%    *n*. That is: min_nargin(3,nargin);
%
% FORMAT   min_nargin(nmin,n)
%        
% IN    nmin   Minimum number of input arguments.
%       n      Actual number of input arguments.

% 2002-12-11   Created by Patrick Eriksson.


function min_nargin(nmin,n)


if n < nmin
  serr = sprintf('At least %d input arguments are requiered.', nmin );
  error( serr );
end
 
