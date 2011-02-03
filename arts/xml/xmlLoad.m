% Loads data from an xml file.
%
%    The data type is determined from the file and *result* adapted
%    accordingly.
%
%    On error, the execution is stopped and an error message is printed.
%
% FORMAT   result = xmlLoad(filename)
%
% OUT   result     Data read from file
% IN    filename   XML filename
 
% 2002-09-25   Created by Oliver Lemke.

function result = xmlLoad(filename)

uncompressed_filename='';
if strcmp( filename(length(filename)-2:end), '.gz')
  workarea = atmlab( 'WORK_AREA' );
  uncompressed_filename = tempname(workarea);
  cmd = [ 'gunzip -cd ' filename ' > ' uncompressed_filename ];
  st = system (cmd);
  if st
    delete (uncompressed_filename);
    error ('Failed to uncompress XML file');
  end
  filename = uncompressed_filename;
end

fid = fopen (filename,'rt');

if fid == -1
  if ~strcmp (uncompressed_filename, '')
    delete (uncompressed_filename);
  end
  error ('Cannot open file %s', filename);
end

%=== Validate XML file header
c = fgets (fid, 1);
s = c;
while ~feof (fid) && c ~= '>'
  c = fgets (fid, 1);
  s = strcat (s, c);
end

if ~strcmp (s, '<?xmlversion="1.0"?>')
  if ~strcmp (uncompressed_filename, '')
    delete (uncompressed_filename);
  end
  error ('Invalid xml header');
end

%=== Parsing data tag
result = xmlReadTag(fid, filename, '', '', 0, 0);

fclose (fid);

if ~strcmp (uncompressed_filename, '')
  delete (uncompressed_filename);
end

