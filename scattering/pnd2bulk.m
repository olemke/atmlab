% PND2BULK Converts ARTS particle number densites to bulk extinction etc.
%
%    Mimics how ARTS calculates bulk scattering data, including temperature
%    interpolation. 
%   
% FORMAT [k_ext,k_abs,Z] = pnd2bulk(S,t_field,pnd_field,ispecies,sa_grid)
%
% OUT   k_ext   Bulk extinction [frequency,pressure,lat,lon] 
%       k_abs   Bulk absorption [frequency,pressure,lat,lon]
%       Z       Bulk phase function [frequency,angle,pressure,lat,lon]
% IN    S       Matches as ARTS scat_data (as returned by *scat_dataCalc*)
%       t_field     As the ARTS WSV
%       pnd_field   As the ARTS WSV
%       ispecies    Sattering species to include. Set to [] to include all
%                   species.
%       sa_grid     Scattering angle grid. Z is returned for this set of angles.

% 2020-03-04 Patrick Eriksson

function [k_ext,k_abs,Z] = pnd2bulk(S,t_field,pnd_field,ispecies,sa_grid)
%
if isempty(ispecies) 
  ispecies = 1:length(S);
end

% Number of frequencies
nf = size( S{1}{1}.ext_mat_data, 1 );

% Allocate output arguments
k_ext = zeros( [nf size( t_field )] );
k_abs = zeros( [nf size( t_field )] );
Z     = zeros( [nf length(sa_grid) size( t_field )] );

% Scattering element index w.r.t. pnd_field
iflat = 0;

for is = 1 : length(S)
  for ie = 1 : length(S{is})

    iflat = iflat + 1;
     
    if any( is == ispecies )
      
      if size(S{is}{ie}.ext_mat_data,3) > 1
        error( 'This function handles only TRO' );
      end
      
      for ip = 1 : size(t_field,1)
        for ilat = 1 : size(t_field,2)
          for ilon = 1 : size(t_field,3)
      
            if pnd_field(iflat,ip,ilat,ilon) > 0

              % Extinction (temperature interpolation, add to bulk)
              x = interp1( S{is}{ie}.T_grid, S{is}{ie}.ext_mat_data', ...
                           t_field(ip,ilat,ilon) );
              k_ext(:,ip,ilat,ilon) = k_ext(:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
            
              % Absorption
              x = interp1( S{is}{ie}.T_grid, S{is}{ie}.abs_vec_data', ...
                           t_field(ip,ilat,ilon) );
              k_abs(:,ip,ilat,ilon) = k_abs(:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
              
              % Phase matrix
              x = S{is}{ie}.pha_mat_data(:,:,:,1,1,1,1);
              x = shiftdim( x, 1 );
              x = interp1( S{is}{ie}.T_grid, x, t_field(ip,ilat,ilon) );
              x = shiftdim( x, 1 );
              x = interp1( S{is}{ie}.za_grid, x, sa_grid );
              Z(:,:,ip,ilat,ilon) = Z(:,:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
            end
          end
        end
      end 
    end
  end
end
