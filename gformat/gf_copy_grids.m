% GF_COPY_GRIDS   Creates new data array, with grids copied from another array
%
%    The function is useful to create a data structure of a smaller
%    dimension than existing data, but with some common grids. An example
%    from ARTS:
%        G.R_GEIOD = gf_copy_grids( G.T_FIELD, 2:3 )
%
% FORMAT   Gnew = gf_copy_grids( Gold, dims )
%        
% OUT   Gnew     New data structure array
% IN    Gold     Old/template data structure aray.
%       dims     Dimensions for which grids shall be copied (can be given in
%                any order). 

% 2007-05-15   Created by Patrick Eriksson.


function Gnew = gf_copy_grids( Gold, dims )

if max(dims) > min([Gold.dim])
  error( 'Values in *dims* outside dimension range of *Gold*.' );  
end

  
dimnew = length(dims);
  

for i = 1 : length(Gold)

  Gnew(i)           = Gold(i);
  %
  Gnew(i).dim       = dimnew;
  Gnew(i).data      = [];
  Gnew(i).data_name = [];
  Gnew(i).data_unit = [];
  Gnew(i).name      = [];
  Gnew(i).source    = [];
  
  for d = 1:dimnew

    gridnew = sprintf('grid%d',d);
    gridold = sprintf('grid%d',dims(d));
    
    Gnew(i).(gridnew)           = Gold(i).(gridold);
    Gnew(i).([gridnew,'_name']) = Gold(i).([gridold,'_name']);
    Gnew(i).([gridnew,'_unit']) = Gold(i).([gridold,'_unit']);
    
  end
  
end


Gnew = gf_clean( Gnew );