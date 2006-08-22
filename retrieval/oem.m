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
  if ~isfield( O, 'yf' ),        O.yf = 0;              end
  if ~isfield( O, 'J' ),         O.J = 0;               end
  if ~isfield( O, 'G' ),         O.G = 0;               end
  if ~isfield( O, 'A' ),         O.A = 0;               end

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
    rqre_fields( O, {'maxiter','stop_dx'}, 0 );
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
    Sxinv = Sx \ eye(size(Sx));
  end
  %
  if size(Sxinv,1) ~= size(Sxinv,2)
    error('Input argument *Sxinv* must be a square matrix.');
  end
  if size(Sx,1) ~= size(Sxinv,1)
    error('Mismatch in size between *Sxinv* and *Sx*.');
  end

  if nargin < 8  |  isempty(Seinv)
    Seinv = Se \ eye(size(Se));
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
  cost_x = NaN;
  cost_y = NaN;

  %- Iteration variables
  %
  ready      = 0;           % Iteration ready?
  iter       = 0;           % Iteration number
  nx         = length(xa);
  linear     = strcmp( O.method, 'LI' );

  %- P structure
  %
  P.converged = 0;
  P.dx        = [];

  %- Print initial screen message
  %
  out( 1, 1, O.outfids );
  out( 1, 'Analytical Bayesian inversion (OEM/MAP)', O.outfids );
  out( 2, 0, O.outfids );
  if linear
    out( 2, 'Linear inversion' );
  else
    if strcmp( upper(O.method), 'GN' )
      O.method = 'GM';  % too have a single choice below
      out( 2, 'Non-linear inversion: Gauss-Newton', O.outfids );
    elseif strcmp( upper(O.method), 'ML' )  |  strcmp( upper(O.method), 'LM' )
      O.method = 'ML';  % too have a single choice below
      out( 2, 'Non-linear inversion: Marquardt-Levenberg', O.outfids );
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
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
    %[yf,J] = comfun( Q, R, x, iter, 1 );
    [yf,J] = feval( comfun, Q, R, x, iter, 1 );

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
        wdy = KtSeinv * ( y - yf ) - Sxinv * ( x - xa );
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

      %- Has OK state been found?
      if linear  |  strcmp( O.method, 'GN' )
        xfound = 1;
      else
        % ML stuff here
      end

      if ~xfound
        nlinprint( O.outfids, iter, subiter, cost, xcost, ycost, dx );
      end
    end

    %- Convergence or max iterations reached ?
    %
    if linear
      ready = 1;
    else
      %
      % (Equation 5.31 in the Rodgers book was used here but it didn't work
      % well for some cases)
      %
      dx = ( ( x_new - x )' * SJSJ * ( x_new - x ) ) / nx;
      %
      if linear  |  dx <= O.stop_dx
        ready       = 1;
        P.converged = 1;
      end
      %
      P.dx = [ P.dx dx ];
      %
      if ~ready  &  iter == O.max_iter
        ready = 1;
      end
      %
      nlinprint( O.outfids, iter, subiter, cost, xcost, ycost, dx );
    end

    %- Update x
    %
    x = xnew;

  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Inversion characteristics ================================================

  %- Update J?
  %
  % Use obtained yf only if not already existing. This to avoid subtle
  % discrepancies to yf found to give convergence above  
  %
  if O.jexact  &  ~only_char 
    [yf,J] = feval( comfun, Q, R, x, iter+1, 1 );
    JtSeinv = J' * Seinv;
    SJSJ    = Sxinv + JtSeinv * J;
  end

  %- Fill P, part 1
  %
  if O.yf
    if isnan(yf)
      yf = feval( comfun, Q, R, x, iter+1, 0 );
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
  if O.G | O.A 
    G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
  end

  %- Fill P, part 2
  %
  if O.G
    P.G = G;
  end
  %
  if O.A
    P.A = G*J;
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
     out( 1,' Main     Sub-     Total    Profile  Spectrum Converg.', outfids);
     out( 1,' iterat.  iterat.  cost     cost     cost     measure ', outfids);
    else
     out( 1, sprintf(' %8d %8d %8.2f %8.2f %8.2f %8.2f', iter, subiter, ...
                                           cost, xcost, ycost, dx ), outfids );
    end
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
