% OEM   Data inversion by "optimal estimation method"
%
%    The name OEM is here kept as it is so well established in the atmospheric
%    community. A better name would be "the maximum a posteriori solution".
%    See "Inverse methods for atmospheric sounding: Theory and practice"
%    by C.D. Rodgers for background and theory.
%
%    The Marquardt-Levenberg method is implemented following Eq. 5.36 of Rodgers'
%    book. The gamma factor, here denoted as ga, is not allowed to exceed
%    O.ga_max. When a succesful iteration has been performed, ga is decreased
%    following O.ga_factor_ok. For cases when a lower cost is not obtained, ga is
%    increased by O.ga_factor_not_ok. Values of ga below 1 will be treated as
%    zero. If not a lower cost is obtained for ga=0, then ga=1 is tested. 
%    O.ga_start is used as start value for ga.
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
O.ga_factor_not_ok = 3;
I.ga_factor_not_ok = [ ...
'The factor with which the Marquardt-Levenberg factor is increased when not ',...
'a lower cost value is obtained. This starts a new sub-teration. This value ',...
'must be > 1.'    
];
%-----------------------------------------------------------------------------
O.ga_factor_ok = 2;
I.ga_factor_ok = [ ...
'The factor with which the Marquardt-Levenberg factor is decreased after a ',...
'lower cost values has been reached. This value must be > 1.'    
];
%-----------------------------------------------------------------------------
O.ga_max = 100;
I.ga_max = [ ...
'Maximum value for gamma factor for the Marquardt-Levenberg method. The ',...
'stops if this value is reached and cost value is still not decreased. ',...'
'This value must be > 0.'
];
%-----------------------------------------------------------------------------
O.ga_start = 4;
I.ga_start = [ ...
'Start value for gamma factor for the Marquardt-Levenberg method. Type:',...
'#   help oem',...
'#for a definition of the gamma factor. This value must be >= 0.'
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
O.jfast = 0;
I.jfast = [ ...
'Flag to always calculate the Jacobian in parallel to the spectrum. This ',...
'field is only used for the Marquardt-Levenberg case. This option can save ',...
'time if the calculation of the Jacobian is very fast and the convergence ',...
'is smooth (few cases where ga has to be increased). The advanatge of this ',...
'option is that the next iteration can be started without a call of the ',...
'forward model.'
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
  doing_ml = 0;
  %
  if ~O.linear
    rqre_char( 'O.imethod', O.imethod );
    rqre_scalar( 'O.maxiter', O.maxiter, 0 );
    rqre_scalar( 'O.stop_dx', O.stop_dx, 0 );
    if strcmp( upper(O.imethod), 'GN' )
      O.imethod = 'GN';  
    elseif strcmp( upper(O.imethod), 'ML' )  |  strcmp( upper(O.imethod), 'LM' )
      O.imethod = 'ML';
      O.cost    = 1;  % Note default value here, cost must anyhow be calculated
      doing_ml  = 1;
      %
      if O.ga_start < 0
        error( 'O.ga_start must be >= 0.' );
      end
      if O.ga_max <= 1
        error( 'O.ga_max must be > 1.' );
      end
      if O.ga_factor_ok <= 1
        error( 'O.ga_factor_ok must be > 1.' );
      end
      if O.ga_factor_not_ok <= 1
        error( 'O.ga_factor_not_ok must be > 1.' );
      end
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
    Sxinv = [];
  else
    xnorm = NaN;
  end
  
  if nargin < 7  |  isempty(Sxinv)
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
  j_updated  = 0;
  %
  if doing_ml
    ga       = O.ga_start;  % ML gamma factor
  else
    ga       = NaN; 
  end
  
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

if ~only_char
  
  while ~ready

    %- This starts a new iteration
    %
    iter = iter + 1;

    %- Calculate new Jacobian (J)   
    %
    if ~j_updated 
      [R,yf,J]  = feval( comfun, Q, R, x, iter );
      j_updated = 1;
    end
    %
    if O.sxnorm
      J = J .* repmat( xnorm', ny , 1 );
    end

    %- Cost values
    %
    % For methods beside ML, there is no need to calculate the cost value to
    % to check if new state is OK. So it is more efficient then to calculate
    % the cost when spectrum and jacobian are recalculated for next iteration.
    %
    if ( iter==1  &  doing_ml )  |  ...
       ( iter >1  &  O.cost  &  isnan( cost ) )
      [cost,cost_y,cost_x] = calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm );  
    end
    %
    if iter == 1  &  doing_ml
      nlinprint( O.outfids, iter-1, NaN, cost, cost_x, cost_y, NaN );
    elseif iter > 1
      nlinprint( O.outfids, iter-1, ga, cost, cost_x, cost_y, dx );
      X.cost(iter-1)   = cost;
      X.cost_y(iter-1) = cost_y;
      X.cost_x(iter-1) = cost_x;
    end

    %- gamma for ML
    %
    if iter > 1  &  ~isnan( ga )
      if ga >= O.ga_factor_ok
        ga = ga / O.ga_factor_ok;
      else
        ga = 0;
      end
    end
    
    %- Some matrix products
    %
    JtSeinv  = J' * Seinv;
    JtSeinvJ = JtSeinv * J;
    
    %- Weighted difference between y and yf
    if iter == 1
      wdy = JtSeinv * ( y - yf );
    else
      if O.sxnorm 
        wdy = JtSeinv * ( y - yf ) - Sxinv * ( ( x - xa ) ./ xnorm );
      else
        wdy = JtSeinv * ( y - yf ) - Sxinv * ( x - xa );
      end
    end
    
    %- Calculate new state
    %
    cost0  = cost;
    xfound = 0;
    dx     = NaN;
    % 
    while ~xfound

      %- New/try x state
      %
      if doing_ml  &  ga > 0
        SJSJ    = (1+ga)*Sxinv + JtSeinvJ;      
      else
        SJSJ    = Sxinv + JtSeinvJ;
      end
      %
      xstep = SJSJ \ wdy; 
      %
      if O.sxnorm 
        xnew = x + xnorm .* xstep;
      else
        xnew = x + xstep;
      end
      
      %- Has OK state been found?
      if O.linear  |  strcmp( O.imethod, 'GN' )
        %
        xfound = 1;
        %
      else  % ML
        %
        if O.jfast
          [R,yf,J]  = feval( comfun, Q, R, xtry, iter+1 );
          j_updated   = 1; 
        else
          [R,yf] = feval( comfun, Q, R, xtry, iter+1 );
        end
        %
        [cost,cost_y,cost_x] = ...
                             calc_cost( y, yf, Seinv, xa, xnew, Sxinv, O, xnorm );
        if cost < cost_old
          xfound = 1;
        else
          nlinprint( O.outfids, -99, ga, cost, cost_x, cost_y, NaN );
          if ga < 1
            ga = 1;
          else
            if ga < O.ga_max
              ga = ga * O.ga_factor_not_ok;
              if ga > O.ga_max
                ga = O.ga_max;
              end
            else
              brake;    % New x could not be found !!!
            end
          end
        end
      end
    
    end  % while ~xfound

    %- Ready if linear or ML failed
    if ~xfound  |  O.linear
      ready = 1;
    
    %-Convergence reached  
    else
    %- Convergence or max iterations reached ?
    %
    if O.linear
      ready = 1;
    else
      %
      % (Equation 5.31 in the Rodgers book was tested here but it didn't work
      % well for some cases)
      %
      dd = xnew - x;
      %
      if O.sxnorm 
        dd = dd ./ xnorm;
      end
      %
      dx = ( dd' * SJSJ * dd ) / nx;
      %
      if dx <= O.stop_dx
        ready       = 1;
        X.converged = 1;
      else
        X.converged = 0;
      end
      %
      if O.dx
        X.dx(iter) = dx;
      end
      %
      if doing_ml  &  ga >= O.ga_max
        xnew  = x;    % Iteration was not succesful
        ready = 1;
      elseif iter == O.maxiter
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
end
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Update inversion characteristics =========================================

  %- Update J?
  %
  if O.jexact  &  ~j_updated
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
  end
  nlinprint( O.outfids, iter, ga, cost, cost_x, cost_y, dx );
  X.cost(iter)   = cost;
  X.cost_y(iter) = cost_y;
  X.cost_x(iter) = cost_x;
  
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
  function nlinprint(outfids,iter,ga,cost,xcost,ycost,dx)
    if nargin == 1
     out( 2,'    Main    Gamma       Total   Profile   Spectrum    Converg.', ...
                                                                     outfids );
     out( 2,' iterat.   factor        cost      cost       cost     measure', ...
                                                                     outfids );
    else
     out( 2, sprintf('%8d%9d%12.3f%10.2f%11.2f%12.2f', iter, ga, ...
                                           cost, xcost, ycost, dx ), outfids );
    end
  return
  %
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  
%=== calc_cost ================================================================
  %
  function [cost,cost_y,cost_x] = ...
                              calc_cost( y, yf, Seinv, xa, x, Sxinv, O, xnorm )
    dd       = x - xa;
    if O.sxnorm
      dd = dd ./ xnorm;
    end
    ny       = length( y );
    cost_x   = (dd' * Sxinv * dd) / ny;  
    dd       = y - yf;
    cost_y   = (dd' * Seinv * dd) / ny; 
    cost     = cost_x + cost_y;
  return
  %
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
