% QP2_L2    Standardised L2 output for Qpack2
%
%    The function allows that a L2 structure is generated where the set of
%    fields can be controlled through Q. The fields of L2 are determined by the
%    settings of the L2 field of the retrieval quantities (such as
%    Q.POLYFIT.L2) and Q.L2_EXTRA. 
%
%    Possible choices for L2_EXTRA are:
%    ----------: These data are transferred from X, the output of *oem*
%         'dx' : Last value of X.dx. See qinfo(@oem,'dx')
%       'cost' : Last value of X.cost. See qinfo(@oem,'dx')
%          'e' : See qinfo(@oem,'e')
%         'eo' : See qinfo(@oem,'eo')
%         'es' : See qinfo(@oem,'es')
%         'yf' : See qinfo(@oem,'yf')
%          'A' : See qinfo(@oem,'A')
%          'G' : See qinfo(@oem,'G')
%          'J' : See qinfo(@oem,'J')
%          'S' : See qinfo(@oem,'S')
%         'So' : See qinfo(@oem,'So')
%         'Ss' : See qinfo(@oem,'Ss')
%    ----------: Other data
%       'date' : Date of the measurement. Taken from Y. Gives fields 'year', 
%                'hour', 'day', 'hour', 'min' and 'sec'
%         'xa' : A priori state for each retrieval quantity.
%          'y' : Measured spectrum.
%         'bl' : Baseline fit.
%     'tnoise' : Thermal noise magnitude. A scalar. Overall mean of Y.TNOISE.
%        'ptz' : Includes 'p_grid', 'z_field' and 't_field' from corresponding
%                fields of Q. For higher atmospheric dimensionalities 
%                'lat_grid' and 'lon_grid* are also included.
%
%    It must be ensured that the output of *oem* includes the data to be
%    extracted here. This is most easily done by this function, following the
%    first format below. Instead of initiating as O = oem;, instead do:
%       O = qp2_l2(Q); 
%    And O will be initiated in a way that this function can be used for
%    producing the L2 data.
%
% FORMAT   O = qp2_l2( Q )
%
% OUT   O       OEM setting structure. 
% IN    Q       Qarts setting structure. 
%
%      or
%
% FORMAT   L2 = qp2_l2( Q, R, xa, O, X, Y, m )
%
% OUT   L2      Creaed L2 structure.
% IN    Q       Qarts setting structure. 
%       R       See *arts_oem_init*.
%       O       OEM setting structure. See *oem*.
%       xa      A priori state vector.
%       X       Output structure from *oem*
%       Y       Measurement structure. See qinfo(@qp2_y)
%       m       Index of retrieved measurement.

% 2009-07-01   Created by Patrick Eriksson.

function L2 = qp2_l2( Q, R, xa, O, X, Y, m )

if nargin == 1
  %
  L2 = oem;
  %
  if ~qarts_isset( Q.L2_EXTRA ) 
    return;           % --->
  end 
  Q.L2_EXTRA = qarts_get( Q.L2_EXTRA );
  rqre_datatype( Q.L2_EXTRA, @iscellstr, 'Q.L2_EXTRA' );                    %&%
  %
  for i = 1 : length( Q.L2_EXTRA )
    switch Q.L2_EXTRA{i} 
      case {'dx','cost','e','eo','es','yf','A','G','J','S','So','Ss'}
        L2.(Q.L2_EXTRA{i})= true;
      case 'mresp'
        L2.A = true;
      case {'date','xa','y','bl','tnoise','ptz'}
        %
      otherwise
        error( sprintf('Unknow out variable: %s', Q.L2_EXTRA{i} ) );
    end        
  end
  %
  return;           % --->
end

%- To handle ase when no putput is selected
%
L2 = [];


%- Set up some do-variables to avoid repetition of any(strcmp))
%
do_mresp = any( strcmp( Q.L2_EXTRA, 'mresp' ) );
do_A     = any( strcmp( Q.L2_EXTRA, 'A' ) ) ;
do_xa    = any( strcmp( Q.L2_EXTRA, 'xa' ) );
do_e     = any( strcmp( Q.L2_EXTRA, 'e' ) );
do_eo    = any( strcmp( Q.L2_EXTRA, 'eo' ) );
do_es    = any( strcmp( Q.L2_EXTRA, 'es' ) ) ;   


% Date and position
%
if any( strcmp( Q.L2_EXTRA, 'date' ) )
  L2.year   = Y(m).YEAR;
  L2.month  = Y(m).MONTH;
  L2.day    = Y(m).DAY;
  L2.hour   = Y(m).HOUR;
  L2.minute = Y(m).MINUTE;
  L2.second = Y(m).SECOND;
end


% Retrieval diagnostics 
%
L2.converged = X.converged;
%
if ~O.linear
  if any( strcmp( Q.L2_EXTRA, 'dx' ) )
    L2.dx = X.dx(end);
  end
end 
%
if any( strcmp( Q.L2_EXTRA, 'cost' ) )
  L2.cost   = X.cost(end);
  L2.cost_x = X.cost_x(end);
  L2.cost_y = X.cost_y(end);
end


% Measurement and fits
%  
if any( strcmp( Q.L2_EXTRA, 'y' ) )
  L2.f  = qarts_get( Q.SENSOR_RESPONSE_F );
  L2.y  = Y(m).Y;
end
if any( strcmp( Q.L2_EXTRA, 'yf' ) )
  L2.yf = X.yf;
end
if any( strcmp( Q.L2_EXTRA, 'bl' ) )
  L2.bl = R.bl;
end
if any( strcmp( Q.L2_EXTRA, 'tnoise' ) )
  L2.tnoise = mean( mean( Y(m).TNOISE ) );
end


% PTZ (last forward model fields)
%
if any( strcmp( Q.L2_EXTRA, 'ptz' ) )
  L2.p_grid = qarts_get( Q.P_GRID );
  if Q.ATMOSPHERE_DIM >= 2
    L2.lat_grid = qarts_get( Q.LAT_GRID );
    if Q.ATMOSPHERE_DIM == 3
      L2.lon_grid = qarts_get( Q.LON_GRID );
    end
  end
  L2.t_field = qarts_get( Q.T_FIELD );
  L2.z_field = qarts_get( Q.Z_FIELD );
end


% Optional matrices
%
if any( strcmp( Q.L2_EXTRA, 'G' ) )
  L2.G = X.G;
end
if any( strcmp( Q.L2_EXTRA, 'J' ) )
  L2.J = X.J;
end
if any( strcmp( Q.L2_EXTRA, 'S' ) )
  L2.S = X.S;
end
if any( strcmp( Q.L2_EXTRA, 'So' ) )
  L2.So = X.So;
end
if any( strcmp( Q.L2_EXTRA, 'Se' ) )
  L2.Se = X.Se;
end


% Start and stop index for each retrieval quantity  
I = zeros( length(R.jq), 2 );
for q = 1 : length(R.jq)
  I(q,:) = [ R.ji{q}{1}  R.ji{q}{2} ];
end


% Measurement response and averaging kernel
%
if do_A & do_mresp 
  [mresp,As] = mrespA( X.A, I );
elseif do_A
  As = splitA( X.A, I );
elseif do_mresp
  mresp = mrespA( X.A, I );
end


% Retrieval quantities
%
i_asj    = find([Q.ABS_SPECIES.RETRIEVE]); 
%
for q = 1 : length(R.jq)

  unitfac = 1;
  include = 0;
  do_log  = 0;
  ind     = I(q,1) : I(q,2);
  siz     = [ length(ind), 1 ];
  
  if strcmp( R.jq{q}.maintag, 'Absorption species' )
    %--------------------------------------------------------------------------
    % It is assumed that abs. species are included first among the ret. quant.
    %--------------------------------------------------------------------------
    ispecies = i_asj(q);
    vname = sprintf( 'Q.ABS_SPECIES(%d)', ispecies );                       %&%
    rqre_field( Q.ABS_SPECIES(ispecies), 'L2', vname );                     %&%
    out = qarts_get( Q.ABS_SPECIES(ispecies).L2 );
    rqre_datatype( out, @isboolean, vname );                                %&%
    %    
    if out 
      s        = sprintf( 'species%d', q );
      include  = 1;
      %
      if strcmp( Q.ABS_SPECIES(ispecies).UNIT, 'logrel' )
        do_log  = 1;
        unitfac = R.x_vmr0(ind);
      elseif strcmp( Q.ABS_SPECIES(ispecies).UNIT, 'rel' )
        unitfac = R.x_vmr0(ind);
      end
      %
      L2.([s,'_name'])  = R.jq{q}.subtag;
      L2.([s,'_p'])     = Q.ABS_SPECIES(ispecies).GRIDS{1};
      if Q.ATMOSPHERE_DIM >= 2
        L2.([s,'_lat']) = Q.ABS_SPECIES(ispecies).GRIDS{2};
        if Q.ATMOSPHERE_DIM == 3
          L2.([s,'_lon']) = Q.ABS_SPECIES(ispecies).GRIDS{3};
          siz = [ length( Q.ABS_SPECIES(ispecies).GRIDS{1} );
                  length( Q.ABS_SPECIES(ispecies).GRIDS{2} );
                  length( Q.ABS_SPECIES(ispecies).GRIDS{3} ) ];
        else
          siz = [ length( Q.ABS_SPECIES(ispecies).GRIDS{1} );
                  length( Q.ABS_SPECIES(ispecies).GRIDS{2} ) ];
        end
      end
    end  
  
  elseif strcmp( R.jq{q}.maintag, 'Frequency' )
    %--------------------------------------------------------------------------
    rqre_field( Q.FFIT, 'L2', 'Q.FFIT' );                                   %&%
    if Q.FFIT.L2
      s       = 'ffit';
      include = 1;
    end
    
  elseif strcmp( R.jq{q}.maintag, 'Polynomial baseline fit' )
    %--------------------------------------------------------------------------
    rqre_field( Q.POLYFIT, 'L2', 'Q.POLYFIT' );                             %&%
    if Q.POLYFIT.L2
      s       = sprintf( 'polyfit%s', R.jq{q}.subtag(end) );
      include = 1;
    end

  else
    error( sprintf( 'Unknown retrieval quantity: %s', R.jq{q}.maintag ) );
  end

  if include
    if ~do_log
      if any( strcmp( Q.L2_EXTRA, 'xa' ) )
        L2.([s,'_xa']) = reshape( unitfac .* xa(ind), siz );
      end
      L2.([s,'_x'])  = reshape( unitfac .* X.x(ind), siz );
    else
      if any( strcmp( Q.L2_EXTRA, 'xa' ) )
        L2.([s,'_xa']) = reshape( unitfac .* exp( xa(ind) ), siz );
      end
      L2.([s,'_x'])  = reshape( unitfac .* exp( X.x(ind) ), siz );
    end
    %
    if any( strcmp( Q.L2_EXTRA, 'e' ) )
      L2.([s,'_e'])  = reshape( unitfac .* X.e(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'eo' ) )
      L2.([s,'_eo']) = reshape( unitfac .* X.eo(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'es' ) )    
      L2.([s,'_es']) = reshape( unitfac .* X.es(ind), siz );  
    end
    %
    if any( strcmp( Q.L2_EXTRA, 'mresp' ) )
      L2.([s,'_mr']) = reshape( mresp(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'A' ) )
      L2.([s,'_A']) = As{q};
    end
  end
end
