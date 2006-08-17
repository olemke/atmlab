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
  if ~isfield( O 'linear' ),    O.linear = 1;          end
  if ~isfield( O 'outfids' ),   O.outfids = 1;         end
  if ~isfield( O 'mform' ),     O.mform = 0;           end
  %
  if ~isfield( O 'yf' ),        O.yf = 0;              end
  if ~isfield( O 'K' ),         O.K = 0;               end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



%=== Check input ==============================================================
                                   
  min_nargin( 6, nargin );

  rqre_datatype( O, 'struct' );
  %
  rqre_bool( 'O.linear', Q.linear );
  rqre_datatype( {'vector}, O.outfids );
  rqre_bool( 'O.mform', Q.mform );
  %
  if ~O.linear
    rqre_fields( O, {'method','maxiter','stop_dx'}, 0 );
    if strcmp( upper(O.method), 'GN' )
      O.method = 'GN';  
    elseif strcmp( upper(O.method), 'ML' )  |  strcmp( upper(O.method), 'LM' )
      O.method = 'ML';  
      O.mform  = 0;
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
  end

  rqre_datatype( 'struct', Q );
  rqre_datatype( 'struct', R );
  rqre_datatype( 'a', comfun );

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
      error(*Mismatch in size between *Sx* and *xa*.');
    end
    rqre_datatype( 'vector', y );
    if size(y,1) ~= size(Se,1)
      error(*Mismatch in size between *Se* and *y*.');
    end
  end

  if nargin < 9
    if O.mform
      Sxinv = NaN;
    else
      Sxinv = Sx \ eye(size(Sx));
    end
  end
  %
  if size(Sxinv,1) ~= size(Sxinv,2)
    error('Input argument *Sxinv* must be a square matrix.');
  end
  if size(xa,1) ~= size(Sxinv,1)
    error(*Mismatch in size between *Sxinv* and *xa*.');
  end

  if nargin < 10
    if O.mform
      Seinv = NaN;
    else
      Seinv = Se \ eye(size(Se));
    end
  end
  %
  if size(Seinv,1) ~= size(Seinv,2)
    error('Input argument *Seinv* must be a square matrix.');
  end
  if size(y,1) ~= size(Seinv,1)
    error(*Mismatch in size between *Seinv* and *y*.');
  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Initializations ==========================================================

  %- State vector 
  %
  x = xa;

  %- Only inversion characterisation?
  %
  only_char = nargin < 8;

  %- Iteration variables
  %
  ready      = 0;     % Iteration ready?
  iter       = 0;     % Iteration number

  %- Parts stiored in P
  %
  P.converged = 0;

  %- Print initial screen message
  %
  out( 1, 1, outfids );
  out( 1, 'Analytical Bayesian inversion (OEM/MAP)' );
  out( 2, 0 );
  if linear
    out( 2, 'Linear inversion' );
  else
    if strcmp( upper(O.method), 'GN' )
      O.method = 'GM';  % too have a single choice below
      out( 2, 'Non-linear inversion: Gauss-Newton' );
    elseif strcmp( upper(O.method), 'ML' )  |  strcmp( upper(O.method), 'LM' )
      O.method = 'ML';  % too have a single choice below
      out( 2, 'Non-linear inversion: Marquardt-Levenberg' );
    else
      error( ['Unknown choice for iteration method. ', ...
                                 'Possible choices are ''GN'' and ''ML''.' ] );
    end
  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Iterate ==================================================================

  while ~ready

    %- This starts a new iteration
    iter = iter + 1;

    %- Calculate new Jacobian (K)   
    %
    [yf,K] = comfun( Q, R, x, iter, 1, 1 );

    
    %- Calculate gain matrix (contribution function)
    %
    G = oem_gain( O, K, Sx, Sxinv, Se, Seinv );


    %- If only characterisation, we are ready
    %
    if only_char
      ready = 1;
      break;
    end

    %- Calculate new state
    %
    xfound = 0;
    xold
    % 
    while ~xfound
       
      if O.linear
        x = xa + G * ( y - yf );

      else

        xold = x;

        if strcmp( O.method, 'GN' )
          x = xa + G * ( y - yf + K * ( xold - xa ) );

        elseif strcmp( O.method, 'ML' )
          % Calculate x without G

        else
          % should not happen !
        end
      end
    end

  end

%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^




%=== Inversion characteristics ================================================

  %- G does not exist for some method(s)
  %
  if isnan( G )
    O.linear = 1;
    G = oem_gain( O, K, Sx, Sxinv, Se, Seinv );
  end
  
  %- Check what shall go to P
  %
  if O.yf
    P.yf = yf;
  end
  %
  if O.K
    P.K = K;
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
  function G = oem_gain( O, K, Sx, Se )
    if O.linear  |  strcmp(O.method,'GN')
      if O.mform

      else
        KtSeinv = K' * Seinv;
        
      end
    else
      G = NaN;
    end
  return
%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
