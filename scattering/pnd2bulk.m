% PND2BULK Converts ARTS particle number densites to bulk extinction etc.
%
%    Mimics how ARTS calculates bulk scattering data, including temperature
%    interpolation. 
%
%    The output data covers the complete atmosphere, this matches t_field in
%    atmospheric size. Data outside of the cloudbox are set to zero.
%
%    The funtion handles only totally random orientation.
%   
% FORMAT [k_ext,k_abs,Z] = pnd2bulk(S,t_field,cbox_limits,pnd_field,ispecies,sa_grid)
%
% OUT   k_ext   Bulk extinction [frequency,pressure,lat,lon] 
%       k_abs   Bulk absorption [frequency,pressure,lat,lon]
%       Z       Bulk phase function [frequency,angle,pressure,lat,lon]
% IN    S       Matches as ARTS scat_data (as returned by *scat_dataCalc*)
%       t_field     As the ARTS WSV
%       cbox_limits As ARTS' cloudbox_limits (0-based data expected)
%       pnd_field   As the ARTS WSV
%       ispecies    Sattering species to include. Set to [] to include all
%                   species.
%       sa_grid     Scattering angle grid. Z is returned for this set of angles.

% 2020-03-04 Patrick Eriksson

function [k_ext,k_abs,Z] = pnd2bulk(S,t_field,cbox_limits,pnd_field,ispecies,sa_grid)
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
      
      for ip = 1 : size(pnd_field,2)
        for ilat = 1 : size(pnd_field,3)
          for ilon = 1 : size(pnd_field,4)
      
            if pnd_field(iflat,ip,ilat,ilon) > 0

              % Index with respect to t_field
              i1 = cbox_limits{1} + ip; 
              if size(t_field,2) == 1
                i2 = 1;
              else
                i2 = cbox_limits{3} + ilat;
              end
              if size(t_field,3) == 1
                i3 = 1;
              else
                i3 = cbox_limits{5} + ilon;
              end

              % Temperature for present point
              t = t_field(i1,i2,i3);
                
              % Extinction (temperature interpolation, add to bulk)
              x = interp1( S{is}{ie}.T_grid, S{is}{ie}.ext_mat_data', t );
              k_ext(:,i1,i2,i3) = k_ext(:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
            
              % Absorption
              x = interp1( S{is}{ie}.T_grid, S{is}{ie}.abs_vec_data', t );
              k_abs(:,i1,i2,i3) = k_abs(:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
              
              % Phase matrix
              x = S{is}{ie}.pha_mat_data(:,:,:,1,1,1,1);
              x = shiftdim( x, 1 );
              x = interp1( S{is}{ie}.T_grid, x, t );
              x = shiftdim( x, 1 );
              x = interp1( S{is}{ie}.za_grid, x, sa_grid );
              Z(:,:,i1,i2,i3) = Z(:,:,ip,ilat,ilon) + ...
                                    pnd_field(iflat,ip,ilat,ilon) * x';
            end
          end
        end
      end 
    end
  end
end
