% SURFRTDATA_EMPTY creates an empty surfrtdata structure
%                  
%          a surfrtdata structure can be used to specify
%          the surface reflectivity or refractive index
%          properties to be used for radiative transfer
%          simulations in the asg-project 
%          
%
% FORMAT   G = surfrtdata_empty( type, dim )
%        
% OUT   G      Created empty surfrtdata structure.
% IN    type   'surface_reflectivity' or 'surface_refractive_index'
%       dim    dimension; valid options are 
%              0, 1, 4, or 6 for type surface_reflectivity
%              3 or 5 for type surface_refractive_index

% Created by Bengt Rydberg 2014-10-09

function G=surfrtdata_empty(type,dim)


if ( ~isequal(type,'surface_reflectivity') & ... 
     ~isequal(type,'surface_refractive_index') );

  error(['Valid type is surface_reflectivity or', ...
	 ' surface_refractive_index'])
end  

if isequal(type,'surface_reflectivity');
  if ~(dim==0 | dim==1 | dim==4 | dim==6);
    error('dim can only be 0, 1, 4, or 6 for type surface_reflectivity')
  end
end
if isequal(type,'surface_refractive_index');
  if ~(dim==3 | dim==5);
    error('dim can only be 3 or 5 for type surface_refractive_index')
  end
end

   
if isequal(type,'surface_reflectivity');
  
  if dim==0;
    G = gf_empty(0);
  end

  if dim==1;
    G = gf_empty(1);
    G.GRID1_NAME='Frequency';
    G.GRID1_UNIT='hz';
  end

  if dim==4;
    G = gf_empty(4);
    G.GRID1_NAME='Frequency';
    G.GRID1_UNIT='hz';
    G.GRID2_NAME='Incidence angle';
    G.GRID2_UNIT='deg';
    G.GRID3_NAME='Latitude';
    G.GRID3_UNIT='deg';
    G.GRID4_NAME='Longitude';
    G.GRID4_UNIT='deg';
  end

  if dim==6;
    G = gf_empty(6);
    G.GRID1_NAME='Frequency';
    G.GRID1_UNIT='hz';
    G.GRID2_NAME='Stokes element';
    G.GRID2_UNIT='-';
    G.GRID3_NAME='Stokes element';
    G.GRID3_UNIT='-';
    G.GRID4_NAME='Incidence angle';
    G.GRID4_UNIT='deg';
    G.GRID5_NAME='Latitude';
    G.GRID5_UNIT='deg';
    G.GRID6_NAME='Longitude';
    G.GRID6_UNIT='deg';

  end

  G.TYPE = 'surfrtdata';
  G.NAME = 'surface_reflectivity';
  G.DATA_NAME = 'surface_reflectivity';
  G.DATA_UNIT ='-';

elseif isequal(type,'surface_refractive_index');

  if dim==3;
    G = gf_empty(3);
    G.GRID1_NAME='Frequency';
    G.GRID1_UNIT='hz';
    G.GRID2_NAME='Temperature';
    G.GRID2_UNIT='K';
    G.GRID3_NAME='Complex';
    G.GRID3_UNIT='-';
  end

  if dim==5;
    G = gf_empty(5);
    G.GRID1_NAME='Frequency';
    G.GRID1_UNIT='hz';
    G.GRID2_NAME='Temperature';
    G.GRID2_UNIT='K';
    G.GRID3_NAME='Complex';
    G.GRID3_UNIT='-';
    G.GRID4_NAME='Latitude';
    G.GRID4_UNIT='deg';
    G.GRID5_NAME='Longitude';
    G.GRID5_UNIT='deg';
  end

  G.TYPE = 'surfrtdata';
  G.NAME = 'surface_refractive_index';
  G.DATA_NAME = 'surface_refractive_index';
  G.DATA_UNIT ='-';   

end
