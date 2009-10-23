% OEM   Data inversion by "optimal estimation method"
%
%    The name OEM is here kept as it is so well established in the atmospheric
%    community. A better name would be "the maximum a posteriori solution".
%    See "Inverse methods for atmospheric sounding: Theory and practice"
%    by C.D. Rodgers for background and theory.
%
%    The OEM calculations are controlled by the structure O. The fields of O,
%    and associated descriptions, are lsited by
%       qinfo(@oem)
%
%    The results are gathered in a structure X, with fields:
%       x         : Retrieved state.
%       converged : Convergence flag. 1 if convergency criterion has been 
%                   reached. Otherwise 0 for non-linear inversions. Set to 
%                   NaN for linear retrievals.
%       cost      : Total cost, normalised by length of y. A succesful retrieval
%                   shall then have a cost in the order of 1.
%       cost_y    : Cost corresponding to the measurement vector.
%       cost_x    : Cost corresponding to the state vector.
%       e         : total retrieval error (square root of diagonal elements 
%                   of S).
%       eo        : observation error (square root of diagonal elements of So).
%       es        : smoothing error (square root of diagonal elements of Ss).
%       yf        : Fitted spectrum.
%       A         : Averaging kernel matrix.
%       G         : Gain matrix (also denoted as Dy).
%       J         : Jacobian (weighting function matrix).
%       S         : Covariance matrix for total error. That is, the sum
%                   of So and Ss.
%       So        : Covariance matrix for observation error.
%       Ss        : Covariance matrix for smoothing error.
%       Xiter     : The x-vector after each iteration.
%   The fields *x* and *converged* are always included (if an actual inversion 
%   is performed). Other fields are included if corresponding O field is set.
%
%   Use the first format to check default values for O. The second format
%   is intended for extracting retrieval characteristics (corresponding to
%   a linear inversion). The third format performs a complete inversion.
%
% FORMAT   O = oem
%            or
%          [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv)
%            or
%          [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)
%        
% OUT   O        O structure with default value for all recognised fields.
%       X        Retrieved state and additional information.
%       R        Retreival variable structure from last calculation.
% IN    O        OEM setting structure.
%       Q        Forward model setting structure.
%       R        Rtreival variable structure.
%       comfun   Handle to function for communication with forward model.
%       Sx       Covariance matrix for a priori uncertainty.
%       Se       Covariance matrix for observation uncertainties.
%       Sxinv    The inverse of Sx. If set to [], the inverse is calculated 
%                internally.
%       Sxinv    The inverse of Se. If set to [], the inverse is calculated 
%                internally.
%       xa       A priori profile.
%       y        Measurement vector.

function [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)

  
%=============================================================================
%=== Definition of O
%=============================================================================
  
if ~nargin

%-----------------------------------------------------------------------------
O.A = 0;
I.A = [ ...
'Flag to include averaging kernel matrix in X. Default is 0.'
];
%-----------------------------------------------------------------------------
O.cost = 0;
I.cost = [ ...
'Flag to include cost values in X and to calculate cost even if solution ',...
'method does not require cost values. This affects also the output to ',...
'*outfids*.'
];
%-----------------------------------------------------------------------------
O.dx = 0;
I.dx = [ ...
'Flag to include the sequence of convergence values (defined as for *stop_dx*).'
];
%-----------------------------------------------------------------------------
O.e = 0;
I.e = [ ...
'Flag to include in X the estimate of total retrieval error  (square root ',...
'of diagonal elements of S). That is, the standard deviation for the sum ',...
'of observation and smoothing errors.'
];
%-----------------------------------------------------------------------------
O.eo = 0;
I.eo = [ ...
'Flag to include in X the estimate of observation error (square root of ',...
'diagonal elements of So).'
];
%-----------------------------------------------------------------------------
O.es = 0;
I.es = [ ...
'Flag to include in X the estimate of smootning error (square root of ',...
'diagonal elements of Ss).'
];
%-----------------------------------------------------------------------------
O.G = 0;
I.G = [ ...
'Flag to include gain matrix in X (alse denoted as Dy).'
];
%-----------------------------------------------------------------------------
O.imethod = 'ML';
I.imethod = [ ...
'Iteration method. Choices are ''GN'' for Gauss-Newton and ''ML'' or',...
'''LM'' for Marquardt-Levenberg.'
];
%-----------------------------------------------------------------------------
O.J = 0;
I.J = [ ...
'Flag to include weighting function matrix in X.'
];
%-----------------------------------------------------------------------------
O.jexact = 0;
I.jexact = [ ...
'Flag to select recalculation of J after last iteration. If not set to 1, ',...
'J will correspond to x before last iteration.'
];
%-----------------------------------------------------------------------------
O.linear = 0;
I.linear = [ ...
'Flag to trigger a linear inversion. Default is non-linear.'
];
%-----------------------------------------------------------------------------
O.maxiter = 99;
I.maxiter = [ ...
'Maximum number of iterations.'
];
%-----------------------------------------------------------------------------
O.msg = [];
I.msg = [ ...
'Message to put at the start of output messages. Can include e.g. number ',...
'of retrieval case.'
];
%-----------------------------------------------------------------------------
O.outfids = 1;
I.outfids = [ ...
'File identifiers for output messages. Inlcude 1 for the screen. Set to [] ',...
'for no output att all.'
];
%-----------------------------------------------------------------------------
O.S = 0;
I.S = [ ...
'Flag to include covariance matrix for total error in X. That is, the sum ',...
'of So and Ss.'
];
%-----------------------------------------------------------------------------
O.So = 0;
I.So = [ ...
'Flag to include covariance matrix for observation error in X.'
];
%-----------------------------------------------------------------------------
O.Ss = 0;
I.Ss = [ ...
'Flag to include covariance matrix for smoothing error in X.'
];
%-----------------------------------------------------------------------------
O.stop_dx = 1e-3;
I.stop_dx = [ ...
'Convergence criterion. The iteration is halted when the the change in x ',...
'is < stop_dx (see Eq. 5.29 in Rodgers'' book). A normalisation to the ',...
'length of x is applied.'
];
%-----------------------------------------------------------------------------
O.sxnorm = 0;
I.sxnorm = [ ...
'Flag to internally perform a normalisation of x, based on the diagonal ',...
'elements of Sx. This to avoid a pure condition number for a matrix ',...
'inversion that is encountered when units are such that retrieved values ',...
'vary strongly in magnitude.',...
'#The inverse of Sx must be calculated internally if this option is used ',...
'and there is no use in pre-calculating *Sxinv*.'
];
%-----------------------------------------------------------------------------
O.yf = 0;
I.yf = [ ...
'Flag to include "fitted spectrum" in X. That is, the simulated ',...
'measurement matching retrieved state.'
];
%----------------------------------------------------------------------------- 
O.Xiter = 0;
I.Xiter = [ ...
'Flag to include all iteration states in X.'
];
%-----------------------------------------------------------------------------
 
X = O;
R = I; 
return  
end
  




%==============================================================================
%=== Start of calculations
%==============================================================================

  
%=== Check of input ===========================================================
                                   
  min_nargin( 6, nargin );

  %- O
  %
  rqre_datatype( 'struct', O );
  qcheck( @oem, O );
  %
  rqre_bool( 'O.linear', O.linear );
  rqre_datatype( { 'empty', 'vector'}, O.outfids );
  %
  if ~O.linear
    rqre_char( 'O.imethod', O.imethod );
    rqre_scalar( 'O.maxiter', O.maxiter, 0 );
    rqre_scalar( 'O.stop_dx', O.stop_dx, 0 );
    if strcmp( upper(O.imethod), 'GN' )
      O.imethod = 'GN';  
    elseif strcmp( upper(O.imethod), 'ML' )  |  strcmp( upper(O.imethod), 'LM' )
      O.imethod = 'ML';
      O.cost    = 1;    % Notdefault value here !!!
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
  end

  rqre_datatype( 'struct', Q );
  rqre_datatype( {'empty','struct'}, R );

  if ~isa( comfun, 'function_handle' )
    error('Input argument *comfun* must be a function handle.');
  end

  rqre_datatype( 'numeric', Se );
  rqre_datatype( 'numeric', Sx );
  if size(Se,1) ~= size(Se,2)
    error('Input argument *Se* must be a square matrix.');
  end
  if size(Sx,1) ~= size(Sx,2)
    error('Input argument *Sx* must be a square matrix.');
  end

  if O.sxnorm
    xnorm = sqrt( diag( Sx ) );
    Sx    = Sx ./ (xnorm*xnorm');
  else
    xnorm = NaN;
  end
  
  if nargin < 7  |  isempty(Sxinv)  |  O.sxnorm
    Sxinv = Sx \ speye(size(Sx));
  end
  %
  if size(Sxinv,1) ~= size(Sxinv,2)
    error('Input argument *Sxinv* must be a square matrix.');
  end
  if size(Sx,1) ~= size(Sxinv,1)
    error('Mismatch in size between *Sxinv* and *Sx*.');
  end

  if nargin < 8  |  isempty(Seinv)
    Seinv = Se \ speye(size(Se));
  end
  %
  if size(Seinv,1) ~= size(Seinv,2)
    error('Input argument *Seinv* must be a square matrix.');
  end
  if size(Se,1) ~= size(Seinv,1)
    error('Mismatch in size between *Seinv* and *Se*.');
  end

  if nargin == 9
    error('No need to specify *xa* if no *y* is given.');
  end

  if nargin >= 10
    rqre_datatype( 'vector', xa );
    if size(xa,1) ~= size(Sx,1)
      error('Mismatch in size between *Sx* and *xa*.');
    end
    rqre_datatype( 'vector', y );
    if size(y,1) ~= size(Se,1)
      error('Mismatch in size between *Se* and *y*.');
    end
  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



%=== Initializations ==========================================================

  %- Only inversion characterisation?
  %
  only_char = nargin < 8;

  %- Retrieval and iteration variables
  %
  if nargin >= 9
    x    = xa;
  else
    x    = NaN;
  end
  yf     = NaN;
  G      = NaN;
  cost   = NaN;
  cost_x = NaN;
  cost_y = NaN;
  %
  nx         = size( Sx, 1 );
  ny         = size( Se, 1 );
  %
  ready      = 0;           % Iteration ready?
  iter       = 0;           % Iteration number

  %- Print initial screen message
  %
  if out(2) | ~isempty( O.msg )
    out( 1, 1, O.outfids );
  end
  if ~isempty( O.msg )
    out( 1, O.msg, O.outfids );
    out( 3, 0, O.outfids );
  end
  if O.linear
    out( 3, 'Linear inversion', O.outfids );
  else
    if strcmp( upper(O.imethod), 'GN' )
      out( 3, 'Non-linear inversion: Gauss-Newton', O.outfids );
    elseif strcmp( upper(O.imethod), 'ML' )  
      out( 3, 'Non-linear inversion: Marquardt-Levenberg', O.outfids );
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
  end
  if ~O.linear | O.cost
    out( 3, 0, O.outfids );
    nlinprint( O.outfids );
  end

  %- P structure
  %
  X.converged = NaN;
  if O.dx
    X.dx      = [];
  end
  if O.Xiter
    X.Xiter   = [];
  end
  if O.cost 
    X.cost_x = [];
    X.cost_y = [];
    X.cost   = [];
  end

  
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Iterate ==================================================================

  while ~ready

    %- This starts a new iteration
    %
    iter = iter + 1;

    %- Calculate new Jacobian (J)   
    %
    [R,yf,J] = feval( comfun, Q, R, x, iter );
    %
    if O.sxnorm
      J = J .* repmat( xnorm', ny , 1 );
    end
    %
    % If not already done, calculate cost for previous iteration
    if iter > 1  &  O.cost  &  isnan( cost )
      [cost,cost_y,cost_x] = calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm );  
      nlinprint( O.outfids, iter-1, subiter, cost, cost_x, cost_y, dx );
      X.cost(iter-1)   = cost;
      X.cost_y(iter-1) = cost_y;
      X.cost_x(iter-1) = cost_x;
    end
    
    %- Some matrix products
    %
    JtSeinv = J' * Seinv;
    SJSJ    = Sxinv + JtSeinv * J;

    %- If only characterisation, we are ready
    %
    if only_char
      ready = 1;
      break;
    end

    %- Calculate new state
    %
    xfound  = 0;
    subiter = 1;
    dx      = NaN;
    % 
    while ~xfound

      %- Weighted difference between y and yf
      if iter == 1
        wdy = JtSeinv * ( y - yf );
      else
        wdy = JtSeinv * ( y - yf ) - Sxinv * ( x - xa );
      end
       
      %- New x state
      if O.linear | strcmp( O.imethod, 'GN' )
        xstep = SJSJ \ wdy; 
      elseif strcmp( O.imethod, 'ML' )
        error('ML not yet handled');
      end
      %
      if O.sxnorm 
        xnew = x + xnorm .* xstep;
      else
        xnew = x + xstep;
      end
     
      %- Flag that yf and cost values are not valid for xnew
      %
      yf     = NaN;
      cost   = NaN;
      cost_x = NaN;
      cost_y = NaN;

      %- Has OK state been found?
      %
      if O.linear  |  strcmp( O.imethod, 'GN' )
        xfound = 1;
      else
        % ML stuff here
      end

      if ~xfound
        nlinprint( O.outfids, iter, subiter, cost, cost_x, cost_y, dx );
      end
    end  % while ~xfound


    %- Convergence or max iterations reached ?
    %
    if O.linear
      x     = xnew;
      ready = 1;
    else
      %
      % (Equation 5.31 in the Rodgers book was tested here but it didn't work
      % well for some cases)
      %
      dx = ( ( xnew - x )' * SJSJ * ( xnew - x ) ) / nx;
      %
      if dx <= O.stop_dx
        ready       = 1;
        X.converged = 1;
      else
        X.converged = 0;
      end
      %
      if O.dx
        X.dx = [ X.dx dx ];
      end
      %
      if iter == O.maxiter
        ready = 1;
      end
    end

    %- Update x
    %
    x = xnew;
    %
    if O.Xiter
      X.Xiter(:,iter) = x;
    end

  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Update inversion characteristics =========================================

  %- Update J?
  %
  if O.jexact  &  ~only_char 
    [R,yf,J] = feval( comfun, Q, R, x, iter+1 );
    %
    if O.sxnorm
      J = J .* repmat( xnorm', ny , 1 );
    end
    %
    JtSeinv  = J' * Seinv;
    SJSJ     = Sxinv + JtSeinv * J;
  end

  %- Calculate G ?
  %
  if O.G | O.A | O.S | O.So | O.Ss | O.e | O.eo | O.es
    G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
    % back-normalisation with xnorm must be done after calculation of A
  end

  %- Calculate A ?
  %
  if O.A | O.S | O.Ss | O.e | O.es
    A = G * J;
  end

  if O.cost  &  isnan( cost )
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter+1 );
    end
    [cost,cost_y,cost_x] = calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm );  
    nlinprint( O.outfids, iter, subiter, cost, cost_x, cost_y, dx );
    X.cost(iter)   = cost;
    X.cost_y(iter) = cost_y;
    X.cost_x(iter) = cost_x;
  end
  
%=== Fill P ===================================================================

  X.x = x;
  
  if O.yf
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter+1 );
    end
    %
    X.yf = yf;
  end

  if O.J
    if O.sxnorm
      X.J = J ./ repmat( xnorm', ny , 1 );
    else
      X.J = J;
    end
  end

  if O.G
    if O.sxnorm
      X.G = G .* repmat( xnorm', ny , 1 );
    else
      X.G = G;
    end
  end

  if O.A 
    X.A = A;  % No normalisation needed here
  end  

  if O.S  |  O.So  |  O.e  |  O.eo
    So = G * Se * G';
    %
    if O.sxnorm
      So = So .* (xnorm*xnorm');
    end
    %
    if O.So
      X.So = So;
    end
    %
    if O.eo
      X.eo = full( sqrt( diag( So ) ) );
    end
  end  

  if O.S  |  O.Ss  |  O.e  |  O.es
    AI = A - eye(size(A,1));
    Ss = AI * Sx * AI';
    %
    if O.sxnorm
      Ss = Ss .* (xnorm*xnorm');
    end
    %
    if O.S
      X.S = Ss + So;
    end
    %
    if O.Ss
      X.Ss = Ss;
    end
    %
    if O.e
      X.e = full( sqrt( diag( Ss ) + diag( So ) ) );
    end
    %
    if O.es
      X.es = full( sqrt( diag( Ss ) ) );
    end
  end  
    
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== End of main part =========================================================
  
  %= End screen meassages 
  %
  if out(2) | ~isempty( O.msg )
    out( 1, -1, O.outfids );
  end
  
  return

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^





%= Internal sub-functions =====================================================

%=== nlinprint ================================================================
  %
  function nlinprint(outfids,iter,subiter,cost,xcost,ycost,dx)
    if nargin == 1
     out( 2,'     Main      Sub-     Total   Profile  Spectrum  Converg.', ...
                                                                     outfids );
     out( 2,'  iterat.   iterat.      cost      cost      cost   measure', ...
                                                                     outfids );
    else
     out( 2, sprintf('%8d  %8d  %8.2f  %8.2f  %8.2f  %8.2f', iter, subiter, ...
                                           cost, xcost, ycost, dx ), outfids );
    end
  return
  %
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  
%=== calc_cost ================================================================
  %
  function [cost,cost_y,cost_x] = ...
                              calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm )
    a        = x - xa;
    if O.sxnorm
      a = a ./ xnorm;
    end
    ny       = length( y );
    cost_x   = (a' * Sxinv * a) / ny;  
    a        = y - yf;
    cost_y   = (a' * Seinv * a) / ny; 
    cost     = cost_x + cost_y;
  return
  %
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  