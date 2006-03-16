function C = read_continua( fname );
% Function to read ARTS 1 continua files
%
% Output
%  C - Cell structure with continua parameters.
%      One cell per continuum term.
% Input
%  fname - Filename
%
% 2006-03-13  M Ekstrom

fid = fopen(fname,'r');

C = struct([]);
cit = 0;
cell_open = 0;

l = fgetl(fid);
while ~feof(fid)
  if cell_open
    if strncmp(l,'cont_descriptionAppend{',23)
      error('Previous continuum description not closed properly');
    end
    
    if ~isempty(l)
      % Check if comment
      l(isspace(l)) = [];
      if l(1)=='}'
        cell_open = 0;
      elseif l(1)~='#'
        % Split string into parts
        p = strread(l,'%s','delimiter','=');
        if strcmp(p{1},'userparameters');
          % Field userparameters uses numeric input
          C = setfield(C,{cit},p{1},eval(p{2}));
        else
          C = setfield(C,{cit},p{1},p{2});
        end
      end
    end
  else
    if strncmp(l,'cont_descriptionAppend{',23)
      % Ok, open new continuum description
      cell_open = 1;
      cit = cit+1;
    end
  end
  
  % Read next line 
  l = fgetl(fid);
end

fclose(fid);