function write_continua(C,fname)
% Function that writes a continua structure to ARTS 1 format
%
% Input
%   C     - Continua structure
%   fname - Filename
%
% 2006-03-13  M Ekstrom

% Open file in write mode (append could be added with flag)
fid = fopen(fname,'w');

% Get list of field
fields = fieldnames(C);

% Write header
fprintf(fid,'# Generated with Atmlab function write_continua\n\n');

% Iterate through C structure
for it=1:length(C)

  fprintf(fid,'cont_descriptionAppend{\n');
  
  % Go through all fields
  for ft=1:length(fields)
    value = getfield(C,{it},fields{ft});
    if isnumeric(value)
      % If numeric loop over all elements
      fprintf(fid,'    %s = [',fields{ft});
      valstr = sprintf(' %g,',value);
      fprintf(fid,'%s',valstr(1:end-1));
      fprintf(fid,']\n');
    else
      fprintf(fid,'    %s = %s\n', fields{ft}, value);
    end
  
  end

  fprintf(fid,'}\n\n');
end

% Close file
fclose(fid);
