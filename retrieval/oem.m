function [x,P] = oem(O,Q,R,comfun,Sx,Se,xa,y,Sxinv,Seinv)
%
% P  : Inversion "profile" (A, S, la, chi-values, x-iter, ...)
%
% Q  : Basic forward model and retrieval settings
% R  : Retrieval bookkeeping
% O  : OEM settings




%=== Default values ===========================================================

  if isempty(O)
    O.linear = 1;
  end
  %
  if ~isfield( O, 'linear' ),    O.linear = 1;          end
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
  rqre_bool( 'O.linear', O.linear );
  rqre_datatype( 'vector', O.outfids );
  %
  if ~O.linear
    rqre_fields( O, {'method','maxiter','stop_dx'}, 0 );
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

  if nargin == 7
    error('No need to specify *xa* if no *y* is given.');
  end

  if nargin >= 8
    rqre_datatype( 'vector', xa );
    if size(xa,1) ~= size(Sx,1)
      error('Mismatch in size between *Sx* and *xa*.');
    end
    rqre_datatype( 'vector', y );
    if size(y,1) ~= size(Se,1)
      error('Mismatch in size between *Se* and *y*.');
    end
  end

  if nargin < 9
    Sxinv = Sx \ eye(size(Sx));
  end
  %
  if size(Sxinv,1) ~= size(Sxinv,2)
    error('Input argument *Sxinv* must be a square matrix.');
  end
  if size(Sx,1) ~= size(Sxinv,1)
    error('Mismatch in size between *Sxinv* and *Sx*.');
  end

  if nargin < 10
    Seinv = Se \ eye(size(Se));
  end
  %
  if size(Seinv,1) ~= size(Seinv,2)
    error('Input argument *Seinv* must be a square matrix.');
  end
  if size(Se,1) ~= size(Seinv,1)
    error('Mismatch in size between *Seinv* and *Se*.');
  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Initializations ==========================================================

  %- Only inversion characterisation?
  %
  only_char = nargin < 8;
  xa = NaN;

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

  %- P structure
  %
  P.converged = 0;
  P.dx        = [];

  %- Print initial screen message
  %
  out( 1, 1, O.outfids );
  out( 1, 'Analytical Bayesian inversion (OEM/MAP)', O.outfids );
  out( 2, 0, O.outfids );
  if O.linear
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
    [yf,J] = comfun( Q, R, x, iter, 1, 1 );

    %- Calculate gain matrix (contribution function)
    %
    [G,SJSJ] = oem_gain( O, J, Sxinv, Seinv );

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
       
      %- Linear 
      if O.linear
        xnew = xa + G * ( y - yf );

      %- Non-linear
      else
        if strcmp( O.method, 'GN' )
          xnew = xa + G * ( y - yf + J * ( xold - xa ) );
        elseif strcmp( O.method, 'ML' )
          error('ML not yet handled');
        end
      end

      if O.linear  |  strcmp( O.method, 'GN' )
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
    if O.linear
      ready = 1;
    else
      %
      % (Equation 5.31 in the Rodgers book was used here but it didn't work
      % well for some cases)
      %
      dx = ( ( x_new - x )' * SJSJ * ( x_new - x ) ) / nx;
      %
      if O.linear  |  dx <= O.stop_dx
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
  if O.jexact 
    [ydummy,j] = comfun( Q, R, x, iter, 1, 1 );
    if isnan(yf)
      yf = ydummy;
    end
  end

  %- Fill P, part 1
  %
  if O.yf
    %- For linear inversions yf can be lacking
    if isnan(yf)
      [yf,J] = comfun( Q, R, x, iter, 1, 0 );
    end
    %
    P.yf = yf;
  end
  %
  if O.J
    P.J = J;
  end

  %- G is lacking for ML
  %
  if isnan( G )  &  ( O.G | O.A )
    O.linear = 1;
    G = oem_gain( O, J, Sxinv, Seinv );
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


%=== oem_gain =================================================================
  function [G,SJSJ] = oem_gain( O, J, Sxinv, Seinv )
    JtSeinv = J' * Seinv;
    SJSJ    = Sxinv + JtSeinv * J;
    %
    if O.linear  |  strcmp(O.method,'GN')
      G = ( SJSJ \ speye(size(Sxinv)) ) * JtSeinv;
    else
      G = NaN;
    end
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


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
