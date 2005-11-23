% MCI   Retrieval by Monte Carlo integration
%
%   A Bayesian inversion is performed by using a precalculated database.
%   The retrieval algoithm is descibed in e.g.
%      Evans et al., Submillimeter-wave cloud ice radiometer: Simulations
%      of retrieval algorithm performance, JGR, 107, D3, 2002.
%
%   The match between the measurement and the database cases is reported
%   as exp(-chi2/2)/exp(-m/2), where m=size(Y,1) and chi2 is defined in
%   the function with same name.
%
%   Some details of the inversion is controled by the structure M. Fields
%   can be left out. Defined fields are
%      use_all : If set to 1 all cases in database are weighted together.
%                If 0, only cases with a weight > w_limit are considered.
%                Default is 1.                
%      w_limit : Threshold level for what is considered as an OK databse hit.
%                Used by *use_all* and controls D.n_hit. Default is 0.01.
%
%    MCI specific retrieval diagnostics is given in the structure array D, 
%    having the fields
%      n_con : Number of considered cases
%      n_hit : Number of cases with weight >= *w_limit*
%      sum_w : Sum of weights (for considered cases)
%      max_w : Maximum weight value
%    To plot e.g. n_hit: plot([D(:).n_hit])
%
% FORMAT   [Xh,E,D,W] = mci(M,Xb,Yb,Se,Y)
%        
% OUT   Xh   Retrieved statese (that is, x-hat).
%       E    Retrieval error.
%       D    Diagnostics of the retrieval. See further above.
%       W    Weights for each database entry and each retrieval.
% IN    M    Settings for the MCI retrieval.  See further above.
%       Xb   States of retrieval data base.
%       Yb   Measurements corresponding to Xb.
%       Se   Observation unvertainty covariance matrix.
%       Y    Measurements to be inverted.

% 2005-11-23   Created by Patrick Eriksson.

function [Xh,E,D,W] = mci(M,Xb,Yb,Se,Y)


if ~isfield( M, 'use_all' )
  M.use_all = 1;
end
if ~isfield( M, 'w_limit' )
  M.w_limit = 0.01;
end


nb = size(Xb,2);
m  = size(Y,1);
ny = size(Y,2);
lx = size(Xb,1);

Xh = zeros( lx, ny );
W  = zeros( nb, ny );

for i = 1 : ny

  w = exp( -0.5*chi2( repmat(Y(:,i),1,nb)-Yb, Se ) ) / exp(-m/2);

  if M.use_all
    ind = 1:nb;
  else
    ind = find( w >= M.w_limit );    
  end

  D(i).sum_w = sum( w(ind) );
  D(i).max_w = max( w );
  D(i).n_con = length(ind);
  D(i).n_hit = length( find( w >= M.w_limit ) );

  Wi = repmat(w(ind)',lx,1);

  Xh(:,i) = sum( Xb(:,ind).*Wi, 2 ) ./ D(i).sum_w;

  if nargout > 1
    E(:,i) = sqrt( sum( ...
         (Xb(:,ind)-repmat(Xh(:,i),1,D(i).n_con)).^2.*Wi, 2 ) ./ D(i).sum_w );
    if nargout > 3
      W(:,i) = w;
    end
  end
end

