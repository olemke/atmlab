% Reads a tag from an XML file.
%
%    Internal function. Parses the tag and calls the appropriate reading
%    function.
%
% FORMAT   result = xmlReadTag(filename)
%
% OUT   result     Data read from file
% IN    filename   Name of XML file

% 2002-11-28   Created by Oliver Lemke.

function result = xmlReadTag(fid)

data_ok = 0;
exit_loop = 0;

%=== Parsing tags
while ~feof (fid) & ~exit_loop
  s = fscanf (fid, '%s', 1);

  if ~size (s)
    break
  end

  %=== Tag has to start with bracket
  if s(1) == '<'
    %=== Do we have an opening tag here?
    if s(2) ~= '/'
      l = size(s);
      tag = s(2:l(2));
      
      attrlist = xmlReadAttributes (fid);
      
      switch tag
       case 'arts'
       otherwise
         func = str2func (strcat ('xmlRead', tag));
         result = feval (func, fid, attrlist);
         data_ok = 1;
      end
    else %=== or is it a closing tag
      exit_loop = 1;
    end
  else
    exit_loop = 1;
  end
end

