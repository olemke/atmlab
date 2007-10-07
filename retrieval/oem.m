function [x,P] = oem(O,Q,R,comfun,Sx,Se,Sxinv,Seinv,xa,y)
%
% P  : Inversion "profile" (A, S, la, chi-values, x-iter, ...)
%
% Q  : Basic forward model and retrieval settings
% R  : Retrieval bookkeeping
% O  : OEM settings




%=== Default values ===========================================================

  if ~isfield( O, 'method' ),    O.method = 'LI';       end
  if ~isfield( O, 'outfids' ),   O.outfids = 1;         end
  if ~isfield( O, 'jexact' ),    O.jexact = 0;          end
  %
  if ~isfield( O, 'cost' ),      O.cost = 0;            end  
  if ~isfield( O, 'Xiter' ),     O.Xiter = 0;           end  
  if ~isfield( O, 'yf' ),        O.yf = 0;              end
  if ~isfield( O, 'J' ),         O.J  = 0;              end
  if ~isfield( O, 'G' ),         O.G  = 0;              end
  if ~isfield( O, 'A' ),         O.A  = 0;              end
  if ~isfield( O, 'S' ),         O.S  = 0;              end
  if ~isfield( O, 'So' ),        O.So = 0;              end
  if ~isfield( O, 'Ss' ),        O.Ss = 0;              end
  if ~isfield( O, 'd' ),         O.d  = 0;              end
  if ~isfield( O, 'do' ),        O.do = 0;              end
  if ~isfield( O, 'ds' ),        O.ds = 0;              end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



%=== Check input ==============================================================
                                   
  min_nargin( 6, nargin );

  rqre_datatype( 'struct', O );
  %
  rqre_char( 'O.method', O.method );
  rqre_datatype( 'vector', O.outfids );
  %
  if strcmp( upper(O.method), 'LI' )
    O.method = 'LI';
  else
    rqre_field( O, 'maxiter', 0 );
    rqre_field( O, 'stop_dx', 0 );
    if strcmp( upper(O.method), 'GN' )
      O.method = 'GN';  
    elseif strcmp( upper(O.method), 'ML' )  |  strcmp( upper(O.method), 'LM' )
      O.method = 'ML';
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
  x      = xa;
  yf     = NaN;
  G      = NaN;

  %- Iteration variables
  %
  ready      = 0;           % Iteration ready?
  iter       = 0;           % Iteration number
  nx         = size( Sx, 1 );
  ny         = size( Se, 1 );
  linear     = strcmp( O.method, 'LI' );
  cost       = NaN;
  cost_x     = NaN;
  cost_y     = NaN;

  %- P structure
  %
  P.converged = 0;
  P.dx        = [];
  if O.Xiter
    P.Xiter   = [];
  end
  if O.cost  |  strcmp( O.method, 'ML' )
    P.cost_x = [];
    P.cost_y = [];
    P.cost   = [];
  end

  %- Print initial screen message
  %
  out( 1, 1, O.outfids );
  out( 1, 'Analytical Bayesian inversion (OEM/MAP)', O.outfids );
  out( 2, 0, O.outfids );
  if linear
    out( 2, 'Linear inversion' );
  else
    if strcmp( upper(O.method), 'GN' )
      out( 2, 'Non-linear inversion: Gauss-Newton', O.outfids );
    elseif strcmp( upper(O.method), 'ML' )  |  strcmp( upper(O.method), 'LM' )
      out( 2, 'Non-linear inversion: Marquardt-Levenberg', O.outfids );
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
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
      if linear
        xnew = xa + SJSJ \ wdy;

      %- Non-linear
      else
        if strcmp( O.method, 'GN' )
          xnew = x + SJSJ \ wdy; 
        elseif strcmp( O.method, 'ML' )
          error('ML not yet handled');
        end
      end

      %- yf not valid for xnew
      yf = NaN;

      %- Cost values
      if O.cost  |  strcmp( O.method, 'ML' )
        [R,yf]   = feval( comfun, Q, R, xnew, iter+1 );
        a        = xnew - xa;
        cost_x   = (a' * Sxinv * a) / ny;  
        a        = y - yf;
        cost_y   = (a' * Seinv * a) / ny; 
        cost     = cost_x + cost_y;
        P.cost   = [ P.cost cost ];
        P.cost_y = [ P.cost_y cost_y ];
        P.cost_x = [ P.cost_x cost_x ];
      end

      %- Has OK state been found?
      if linear  |  strcmp( O.method, 'GN' )
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
    if linear
      x     = xnew;
      ready = 1;
    else
      %
      % (Equation 5.31 in the Rodgers book was used here but it didn't work
      % well for some cases)
      %
      dx = ( ( xnew - x )' * SJSJ * ( xnew - x ) ) / nx;
      %
      if linear  |  dx <= O.stop_dx
        ready       = 1;
        P.converged = 1;
      end
      %
      P.dx = [ P.dx dx ];
      %
      if ~ready  &  iter == O.maxiter
        ready = 1;
      end
      %
      nlinprint( O.outfids, iter, subiter, cost, cost_x, cost_y, dx );
    end

    %- Update x
    %
    x = xnew;

    if O.Xiter
      P.Xiter   = [ P.Xiter x ];
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

  %- Fill P, part 1
  %
  if O.yf
    if isnan(yf)
      [R,yf] = feval( comfun, Q, R, x, iter+1 );
    end
    %
    P.yf = yf;
  end
  %
  if O.J
    P.J = J;
  end

  %- Calculate G ?
  %
  if O.G | O.A | O.S | O.So | O.Ss | O.d | O.do | O.ds
    G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
  end

  %- Calculate A ?
  %
  if O.A | O.S | O.Ss | O.d | O.ds
    A = G * J;
  end

  %- Fill P, part 2
  %
  if O.G
    P.G = G;
  end
  %
  if O.A 
    P.A = A;
  end  
  %
  if O.S  |  O.So  |  O.d  |  O.do
    So = G * Se * G';
    %
    if O.So
      P.So = So;
    end
    %
    if O.do
      P.do = sqrt( diag( So ) );
    end
  end  
  %
  if O.S  |  O.Ss  |  O.d  |  O.ds
    AI = A - eye(size(A,1));
    Ss = AI * Sx * AI';
    %
    if O.S
      P.S = Ss + So;
    end
    %
    if O.Ss
      P.Ss = Ss;
    end
    %
    if O.d
      P.d = sqrt( diag( Ss ) + diag( So ) );
    end
    %
    if O.ds
      P.ds = sqrt( diag( Ss ) );
    end
  end  
    
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== End of main part =========================================================
  
  %= End screen meassages 
  %
  out( 1, -1 );

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
     out( 1,'     Main      Sub-     Total   Profile  Spectrum  Converg.', ...
                                                                     outfids );
     out( 1,'  iterat.   iterat.      cost      cost      cost   measure', ...
                                                                     outfids );
    else
     out( 1, sprintf('%8d  %8d  %8.2f  %8.2f  %8.2f  %8.2f', iter, subiter, ...
                                           cost, xcost, ycost, dx ), outfids );
    end
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
