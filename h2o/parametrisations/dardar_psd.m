% DARDAR_PSD   DARDAR's particle size distribution
%
% As described in Delanoe et al 2014, Normalized particle size distribution for
% remote sensing application. J. Geophys. Res., 119:4204–4227. This article
% is below denoted as D14.
%
% A direct application of the expressions gives Inf for de = 0. If you want to
% include de=0, this OK but requires a sorted de (i.e. de(1)=0). The zero
% size is than replaced with 0.1*de(2) and a hopefully useful psd is obtained.
%
% FORMAT [psd,N0star,dm] = dardar_psd(de,rho,iwc,paramater_value,paramater_name[,version])
%
% OUT    psd              particle size distribution vector
%        N0star           Input or derived value for this parameter.
%        dm               Input or derived value for this parameter.
% IN     de               Particle size grid [m].
%        rho              Density of medium [Kg/m3]
%        iwc              Oce water content
%        parameter_value  Options are the value of N0star, Dm (mean size by mass)
%                         or temperature.
%                         N0star and Dm are psd parameter as defined in Delanoe.
%                         If temperature is used, an a priori parameterisation
%                         of N0star will be applied (defined in Table 5 of D14)
%        paramater_name   Options are:
%                            'N0star'
%                            'Dm'
%                            'Temperature'
% OPT    version          The PSD involves a combination of alpha and beta,
%                         that differs between different versions. These
%                         sources are at hand
%                            'd14': Alpha and beta are taken as "All DARADR" 
%                                   Ext-Z in Table 4 of D14. 
%                             'v2': Set to values applied in DARDAR V2.1,
%                                   according to Cazenave et al, AMT, 2019
%                                   (Fig 2). This is the default option.
%                             'vX': Set to values applied in DARDAR V2,
%                                   according to Cazenave et al, AMT, 2019.
%                                   These values are also found as "All" in
%                                   Table 4 of D14. 

% History: created by Bengt Rydberg, modified 2017-02-10

function [psd,N0star,dm] = dardar_psd(de,rho,iwc,parameter_value,parameter_name,version)
%
if nargin < 6 | isempty(version), version = 'v2'; end

% The function has been tested to give agreement with Fig 2 in Cazenave et al,
% AMT, 2019. This for N0star and Dm options.


if strcmp(parameter_name, 'N0star')
  N0star = parameter_value;
  dm = (4^4 * iwc / pi / rho ./ parameter_value).^(1/4);
elseif strcmp(parameter_name, 'Dm')
  dm = parameter_value;
  N0star = 4^4 * iwc / pi / rho ./ parameter_value.^4;
elseif strcmp(parameter_name,'Temperature')
  T = parameter_value;
  % Parameter values taken from "DARDAR" in Table 5 of D14
  N0star = exp(-0.076586 * (T - 273.15) + 17.948);
  dm = (4^4 * iwc / pi / rho ./ N0star ).^(1 / 4);
else
  error('Unknown choice for *parameter_name*.');
end
% Handle zero size
%
if de(1) == 0
  de(1) = 0.1*de(2);
end

psd = zeros(length(N0star), length(de));

% dardar-psd parameters for n(De)
switch lower(version)
  case 'd14'
    alfa = -0.237;
    beta = 1.839;
  case 'v2'
    alfa = -2;
    beta = 4;
  case 'vx'
    alfa = -0.262;
    beta = 1.754;
  otherwise
    error( 'Allowed options for *version* are: ''d14'', ''v2'' and ''vX''.' );
end


for i = 1:length(iwc)
  X = de / dm(i);
  f0 = beta * gamma(4) / 4^4;
  g4 = gamma((alfa + 4)/beta);
  g5 = gamma((alfa + 5)/beta);
  f1 = g5^(4 + alfa) / g4^(5 + alfa);
  f2 = g5 / g4;
  n_norm = f0 * f1 * X.^alfa .* exp( -(X * f2).^beta );
  psd(i, :) = N0star(i) * n_norm;
end
ind = find(isnan(psd));
psd(ind) = 0;
