% 22 GHz retrieval settings
%
%    The structure R has these fields
%
%    R.show_plots    Show plots while processing
%    R.show_oem      Show OEM output about iterations
%
%    R.phase1_do     Flag to activate / deactive phase 1
%    R.phase1_ntest  No. of channels in each end of spectrum to consider
%    R.phase1_dtb    Iteration stops when difference smaller than this value [K]
%    R.phase1_bp1    Adjustment 100% up to this altitude
%    R.phase1_bp2    Adjustment 0% above this altitude
%
%    R.phase2_stop_dx   Stop criterion, see ARTS' OEM
%    R.phase2_max_iter  Maximum number of iterations, see ARTS' OEM
%
%    R.phase3_do                Flag to activate / deactive phase 3
%    R.phase3_lm_ga_settings    See ARTS' OEM
%
%    R.h2o.grid      H2O retrieval grid [Pa].
%    R.h2o.sx        H2O a priori covariance matrix.
%    R.h2o.sxinv     Inverse of the matric above. Not mandatory.
%
%    R.polyfit.n     Order of polynomial fit. Set to -1 to deactivate polyfit.
%    R.polyfit.sx    Covariance matrices for polyfit as an array of sparse
%                    matrises (of size 1x1). Matrix 1 matches polynomial 0 etc.
%    R.polyfit.sxinv Inverse of the matrices above. Not mandatory.   
%
% FORMAT R = r22
%
% OUT   R   Retrieval settings structure.

% 2021-02-10 Patrick Eriksson


function R = r22


%- Overall control settings
%
R.show_plots           = true;
R.show_oem             = true;


%- Phase 1: Adjustment lower troposphere
%
R.phase1_do            = true;
R.phase1_ntest         = 500;
R.phase1_dtb           = 0.02;
R.phase1_bp1           = 3e3;
R.phase1_bp2           = 6e3;


%- Phase 2: Gauss-Newton
%
R.phase2_stop_dx       = 0.5;
R.phase2_max_iter      = 10;


%- Phase 3: Levenberg-Marquardt
%
% Phase 2 settings also applied here
%
R.phase3_do            = true;
R.phase3_lm_ga_settings= [100 5 10 1e4 1 1]';


%- H2O
%
dz                     = 3e3;
lc                     = 15e3;
%
z                      = [0 : dz : 90e3]';
sigma                  = 0.01 + 0.4 * linear_transition( 35e3, 60e3, z);
sigma(1)               = 0.4;
%
R.h2o.grid             = z2p_simple( z );
[R.h2o.sx,R.h2o.sxinv] = covmat1d_markov( length(R.h2o.grid), sigma, dz, lc );


%- Polyfit
%
R.polyfit.n            = 3;    
sigma                  = [1e-5 repmat(0.02,1,9)]; % Sigma for poly 0, 1, 2 ...
%
if R.polyfit.n >= 0
  for i = 0 : R.polyfit.n
    cov                  = sigma(i+1)^2;
    R.polyfit.sx{i+1}    = sparse( cov );
    R.polyfit.sxinv{i+1} = sparse( 1/cov );
  end
end
