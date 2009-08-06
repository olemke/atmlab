% OEM   Data inversion by "optimal estimation method"
%
%    The name OEM is here kept as it is so well established in the atmospheric
%    community. A better name would be "the maximum a posteriori solution".
%
%    See "Inverse methods for atmospheric sounding: Theory and practice"
%    by C.D. Rodgers for background and theory.
%
%    The OEM calculations are controlled by the structure O. This structure has
%    the following fields:
%       linear : Flag to trigger a linear inversion.
%       outfids: File identifiers for output messages. Inlcude 1 for the
%                screen. Set to [] for zero verbosity.
%       msg    : Message to put at the start of output messages. Can include
%                e.g. number of retrieval case.
%       ---
%       imethod: Iteration method. Choices are 'GN' for Gauss-Newton and
%                'ML'/'LM' for Marquardt-Levenberg. 
%       maxiter: Maximum number of iterations.
%       stop_dx: Convergence criterion. The iteration is halted when the
%                the change in x is < stop_dx (see Eq. 5.29 in Rodgers' book).
%                A normalisation to the length of x is applied. 
%       ---
%       cost   : Flag to include cost values in X and to calculate cost even
%                if solution method does not require cost values. This affects
%                also the output to *outfids*. If not set, the output can be 
%                NaN.
%       dx     : Flag to include the sequence of convergence values (defined
%                as for *stop_dx*).
%       e      : Flag to include in X the estimate of total retrieval error 
%                (square root of diagonal elements of S). That is, the
%                standard deviation for the sum of observation and smoothing 
%                errors.
%       eo     : Flag to include in X the estimate of observation error 
%                (square root of diagonal elements of So). 
%       es     : Flag to include in X the estimate of observation error 
%                (square root of diagonal elements of Ss).
%       yf     : Flag to include "fitted spectrum" in X. That is, the simulated
%                measurement matching retrieved state.
%       A      : Flag to include averaging kernel matrix in X.
%       G      : Flag to include gain matrix in X.
%       J      : Flag to include weighting function matrix in X.
%       jexact : Flag to select recalculation of J after last iteration.
%                If not set to 1, J will correspond to x before last iteration.
%       S      : Flag to include covariance matrix for total error in X.
%                That is, the sum of So and Ss.
%       So     : Flag to include covariance matrix for observation error in X.
%       Ss     : Flag to include covariance matrix for smoothing error in X.
%       Xiter  : Flag to include all iteration states in X.
%
%   The results are gathered in a structure X, with fields:
%       x         : Retrieved state.
%       converged : Convergence flag. 1 if convergency criterion has been reached. 
%                   Otherwise 0 for non-linear inversions. Set to NaN for
%                   linear retrievals.
%       cost      : Total cost, normalised by length of y. A succesful retrieval
%                   shall then have a cost in the order of 1.
%       cost_y    : Cost corresponding to the measurement vector.
%       cost_x    : Cost corresponding to the state vector.
%       d         : See above.
%       do        : See above.
%       ds        : See above.
%       yf        : See above.
%       A         : See above.
%       G         : See above.
%       J         : See above.
%       S         : See above.
%       So        : See above.
%       Ss        : See above.
%       Xiter     : The x-vector after each iteration.
%   The fields x and converged are always included (if an actual inversion 
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
%       Sxinv    The inverse of Sx. If set [], the inverse is calculated 
%                internally.
%       Sxinv    The inverse of Se. If set [], the inverse is calculated 
%                internally.
%       xa       A priori profile.
%       y        Measurement vector.

function [X,R] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)



%=== Default values ===========================================================
  if ~nargin, O=[]; end

  if ~isfield( O, 'linear' ),    O.linear  = 0;         end
  if ~isfield( O, 'outfids' ),   O.outfids = 1;         end
  if ~isfield( O, 'msg' ),       O.msg = [];            end
  %
  if ~isfield( O, 'imethod' ),   O.imethod = 'ML';      end
  if ~isfield( O, 'maxiter' ),   O.maxiter = 99;        end
  if ~isfield( O, 'stop_dx' ),   O.stop_dx = 1e-3;      end
  %
  if ~isfield( O, 'cost' ),      O.cost    = 0;         end  
  if ~isfield( O, 'dx' ),        O.dx      = 0;         end
  if ~isfield( O, 'e' ),         O.e       = 0;         end
  if ~isfield( O, 'eo' ),        O.eo      = 0;         end
  if ~isfield( O, 'es' ),        O.es      = 0;         end
  if ~isfield( O, 'yf' ),        O.yf      = 0;         end
  if ~isfield( O, 'A' ),         O.A       = 0;         end
  if ~isfield( O, 'G' ),         O.G       = 0;         end
  if ~isfield( O, 'jexact' ),    O.jexact  = 0;         end
  if ~isfield( O, 'J' ),         O.J       = 0;         end
  if ~isfield( O, 'S' ),         O.S       = 0;         end
  if ~isfield( O, 'So' ),        O.So      = 0;         end
  if ~isfield( O, 'Ss' ),        O.Ss      = 0;         end
  if ~isfield( O, 'Xiter' ),     O.Xiter   = 0;         end  

  if ~nargin, X=O; return, end
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


%=== Check input ==============================================================
                                   
  min_nargin( 6, nargin );

  %- O
  %
  rqre_datatype( 'struct', O );
  %
  %- Unknown fields in O?
  fields0 = fieldnames( oem );
  fields  = fieldnames( O );
  e  = [];
  for i = 1 : length(fields)
    if ~strcmp( fields{i}, fields0 ), e{end+1} = fields{i}; end
  end
  if ~isempty(e)
    for i = 1 : length(e), fprintf('   O.%s\n', e{i} ); end
    error( 'The fields listed above  are not recognised but were found in O.');
  else
    clear fields0 fields e
  end
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

  %- Retrieval variables
  %
  if nargin >= 9
    x    = xa;
  else
    x    = NaN;
  end
  yf     = NaN;
  G      = NaN;

  %- Iteration variables
  %
  ready      = 0;           % Iteration ready?
  iter       = 0;           % Iteration number
  nx         = size( Sx, 1 );
  ny         = size( Se, 1 );
  cost       = NaN;
  cost_x     = NaN;
  cost_y     = NaN;

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

  %- Print initial screen message
  %
  out( 1, 1, O.outfids );
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
    out( 2, 0, O.outfids );
    nlinprint( O.outfids );
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
       
      %- Linear 
      if O.linear
        xnew = xa + SJSJ \ wdy;

      %- Non-linear
      else
        if strcmp( O.imethod, 'GN' )
          xnew = x + SJSJ \ wdy; 
        elseif strcmp( O.imethod, 'ML' )
          error('ML not yet handled');
        end
      end

      %- yf not valid for xnew
      yf = NaN;

      %- Cost values
      if O.cost  |  strcmp( O.imethod, 'ML' )
        [R,yf]   = feval( comfun, Q, R, xnew, iter+1 );
        a        = xnew - xa;
        cost_x   = (a' * Sxinv * a) / ny;  
        a        = y - yf;
        cost_y   = (a' * Seinv * a) / ny; 
        cost     = cost_x + cost_y;
        if O.cost 
          X.cost   = [ X.cost cost ];
          X.cost_y = [ X.cost_y cost_y ];
          X.cost_x = [ X.cost_x cost_x ];
        end
      end

      %- Has OK state been found?
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

    if ~O.linear | O.cost
      nlinprint( O.outfids, iter, subiter, cost, cost_x, cost_y, dx );
    end

    %- Update x
    %
    x = xnew;

    if O.Xiter
      X.Xiter   = [ X.Xiter x ];
    end

  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Inversion characteristics ================================================

  %- Update J?
  %
  if O.jexact  &  ~only_char 
    [R,yf,J] = feval( comfun, Q, R, x, iter+1 );
    JtSeinv  = J' * Seinv;
    SJSJ     = Sxinv + JtSeinv * J;
  end

  %- Calculate G ?
  %
  if O.G | O.A | O.S | O.So | O.Ss | O.e | O.eo | O.es
    G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
  end

  %- Calculate A ?
  %
  if O.A | O.S | O.Ss | O.e | O.es
    A = G * J;
  end

  %- Fill P

  X.x = x;
  
  if O.yf
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter+1 );
    end
    %
    X.yf = yf;
  end

  if O.J
    X.J = J;
  end

  if O.G
    X.G = G;
  end

  if O.A 
    X.A = A;
  end  

  if O.S  |  O.So  |  O.e  |  O.eo
    So = G * Se * G';
    %
    if O.So
      X.So = So;
    end
    %
    if O.eo
      X.eo = sqrt( diag( So ) );
    end
  end  

  if O.S  |  O.Ss  |  O.e  |  O.es
    AI = A - eye(size(A,1));
    Ss = AI * Sx * AI';
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
      X.e = sqrt( diag( Ss ) + diag( So ) );
    end
    %
    if O.es
      X.es = sqrt( diag( Ss ) );
    end
  end  
    
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== End of main part =========================================================
  
  %= End screen meassages 
  %
  out( 1, -1, O.outfids );

  return

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^





%= Internal sub-functions =====================================================

%=== nlinprint ================================================================
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
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
