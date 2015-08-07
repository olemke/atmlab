% ASG_HYDROSTAT   Calculates hydrostatic equilibrium for ASG data
%
%    The function demands that *G* contains temperature and water vapour
%    data and pressure and altitude reference data. 
%    asg_hydrostat wraps around *pt2z*. 
%
% FORMAT   G = asg_hydrostat( Gtemp, Gh2o, Gp0, Gz0)
%        
% OUT   G     G atmdata structure with altitude data. 
%             Name set to 'Altitude'.
% IN   
%       Gtemp atmdata structure with temperature ('temperature') data.
%       Gh2o  atmdata structure with water vapour ('H2O') data.
%       Gp0   surfdata structure with reference pressure 
%             ('surface pressure') data.
%       Gz0   surfdata structure with reference altitude 
%             ('surface elevation') data.
%       
% Example usage:
%
% fascod_data_path = fullfile(atmlab('ARTS_XMLDATA_PATH'), 'atmosphere/fascod');
% datafile = fullfile(fascod_data_path, 'tropical.H2O.xml');
% Gh2o = gf_artsxml(datafile, 'H2O' , 'vmr_field');
% datafile = fullfile(fascod_data_path, 'tropical.t.xml');
% Gtemp = gf_artsxml(datafile, 'temperature' , 'vmr_field');
% Gz0 = surfdata_scalar(0);
% Gz0.NAME = 'Surface elevation';
% Gp0 = surfdata_scalar(100000);
% Gp0.NAME = 'Surface pressure';
% G = asg_hydrostat( Gtemp, Gh2o, Gp0, Gz0)

% 2014-08-29   Created by Bengt Rydberg

function G = asg_hydrostat( Gtemp, Gh2o, Gp0, Gz0)
   

strictAssert = atmlab('STRICT_ASSERT');

if strictAssert; 
  rqre_datatype( Gtemp, @isatmdata );
  rqre_datatype( Gh2o, @isatmdata );
  rqre_datatype( Gp0, @issurfdata );
  rqre_datatype( Gz0, @issurfdata );
  if ~isequal(lower(Gtemp.NAME),'temperature');
    error('Gtemp must contain temperature data')
  end
  if (~isequal(lower(Gh2o.NAME),'h2o') | ...
      (~isequal(lower(Gh2o.DATA_NAME),'volume mixing ratio') & ...
       ~isequal(lower(Gh2o.DATA_NAME),'vmr') ) ) ;
    error('Gh2o must contain H2O vmr data')
  end
  if ~isequal(lower(Gz0.NAME),'surface elevation');
    error('Gz0 must contain surface elevation data')
  end
  if ~isequal(lower(Gp0.NAME),'surface pressure');
    error('Gp0 must contain surface pressure data')
  end
  if ~all(size(Gtemp.DATA)==size(Gh2o.DATA));
    error('The size of Gtemp.DATA and Gh2o.DATA must match')
  end
end

dim = Gtemp.DIM;

G = atmdata_empty( dim );
G.NAME='Altitude field';
G.DATA = zeros(size(Gtemp.DATA));
G.DATA_NAME = 'Altitude';
G.DATA_UNIT = 'm';
G.SOURCE = 'atmdata_hydrostat';
for i=1:dim
  G.(sprintf('GRID%d',i))=vec2col(Gtemp.(sprintf('GRID%d',i)));
end


%- Run HSE
%
%

for ic = 1 : size(G.DATA,4)
  for ilon = 1 : size(G.DATA,3)
    for ilat = 1 : size(G.DATA,2)
      if isscalar(Gz0.DATA);
        z0=Gz0.DATA;
      else
        z0=Gz0.DATA(ilat,ilon,ic);
      end
      if isscalar(Gp0.DATA);
        p0=Gp0.DATA;
      else
        p0=Gp0.DATA(ilat,ilon,ic);
      end
      if isfield(G,'GRID2');
         G.DATA(:,ilat,ilon,ic) = pt2z( G.GRID1, ...
                                     Gtemp.DATA(:,ilat,ilon,ic), ...
                                     Gh2o.DATA(:,ilat,ilon,ic), ...
                                     p0, z0, G.GRID2(ilat) );
      else
          G.DATA(:,ilat,ilon,ic) = pt2z( G.GRID1, ...
                                     Gtemp.DATA(:,ilat,ilon,ic), ...
                                     Gh2o.DATA(:,ilat,ilon,ic), ...
					 p0, z0);
      end
    end
  end
end

