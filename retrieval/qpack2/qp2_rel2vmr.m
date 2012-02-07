% QP2_REL2VMR  Convert 'rel' or 'logrel' data to VMR
%
%    If one or several absorption species have been retrived with 'rel' or
%    'logrel' as unit, but prefer to have the L2 data as VMR values, this
%    function makes the conversion.
%    
%    The L2 data must contain the a priori state (species1_xa etc.). This field
%    is used to determine if 'rel' or 'logrel' has been used. A field holding
%    the a priori VMR (species1_vmr0 etc.) must also exist (added automatically
%    by *qp2_l2*). If the later field is lacking, no conversion is performed
%    (without any warning). After the conversion, the a priori field (xa) is
%    modified and the VMR field is removed.
%
%    Note that if L2_RANGE has been used to include parts outside the range of
%    the retrieval grids, the obtained VMR profile is not representing those
%    parts correctly (the L2 data will only have a stright line for those
%    parts). 
%
%   For 'logrel', errors are converted simply as e_vmr = e*x_vmr.
%
% FORMAT   L2 = qp2_rel2vmr( L2 )
%        
% OUT      L2   Modified L2 data structure.
% IN       L2   Original L2 data structure.

% 2011-05-20   Created by Patrick Eriksson.

function L2 = qp2_rel2vmr(L2)
  
i     = 0;
ready = false;

while ~ready
  
  i = i + 1;
  
  nx = sprintf( 'species%d_x', i );
  
  if ~isfield( L2, nx )
    ready = true;
  
  else
    
    nv    = sprintf( 'species%d_vmr0', i );
    
    % If field nv does not exist, vmr or nd has been used
    if exist( L2, nv )   
    
      na    = sprintf( 'species%d_xa', i );
      nA    = sprintf( 'species%d_A', i );
      nmr   = sprintf( 'species%d_mr', i );
      ns{1} = sprintf( 'species%d_e', i );
      ns{2} = sprintf( 'species%d_eo', i );
      ns{3} = sprintf( 'species%d_es', i );
      ns{4} = sprintf( 'species%d_ex', i );
      nS{1} = sprintf( 'species%d_S', i );
      nS{2} = sprintf( 'species%d_So', i );
      nS{3} = sprintf( 'species%d_Ss', i );

      rqre_field( L2, nv, 'sub-field vmr0' );

      for j = 1: length(L2)
        %
        vmr0       = L2(j).(nv);
        xa         = L2(j).(na);

        if isfield( L2, nA )
          L2(j).(nA) = L2(j).(nA) .* (vmr0*(1./vmr0'));
        end

        % rel
        if xa(1) == 1
          L2(j).(nx) = L2(j).(nx) .* vmr0;
          L2(j).(na) = vmr0;
          for k = 1 : length(ns)
            if isfield( L2, ns{k} )
              L2(j).(ns{k}) = L2(j).(ns{k}) .* vmr0;
            end
          end
          
        % logrel
        elseif xa(1) == 0
          L2(j).(nx) = exp(L2(j).(nx)) .* vmr0;
          L2(j).(na) = vmr0;
          for k = 1 : length(ns)
            if isfield( L2, ns{k} )
              if strcmp(ns{k},sprintf( 'species%d_ex', i ))
              %apriori uncertainty is given in rel even for logrel inversions
                L2(j).(ns{k}) = L2(j).(ns{k}) .* vmr0; 
              else
                L2(j).(ns{k}) = (exp(L2(j).(ns{k}))-1) .* L2(j).(nx);
              end
            end
          end
        
        else
          error( 'Could not establish retrieval unit.' );
        end
        %
      end  % for j
      %
      L2 = rmfield( L2, nv );
      %
    end  % if exist
  end   % if ~isfield
end   % while
