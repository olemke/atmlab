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
result = 'error';

%=== Parsing tags
while ~feof (fid) & ~exit_loop

  c = fgets (fid, 1);
  while ~feof (fid) & (c == 10 | c == 32)
    c = fgets (fid, 1);
  end

  if feof (fid), break, end

  %=== Tag has to start with bracket
  if c == '<'
    c = fgets (fid, 1);

    %=== Do we have an opening tag here?
    if c ~= '/'
      tag = c;

      c = fgets (fid, 1);
      while ~feof (fid) & c ~= ' ' & c ~= '>'
        tag = strcat (tag, c);
        c = fgets (fid, 1);
      end

      if feof (fid)
        error ('Unexpected end of file');
        break;
      elseif c ~= '>'
        % Tag with attributes
        attrlist = xmlReadAttributes (fid);
      end
      
      switch tag
       case 'arts'
       otherwise
         func = str2func (strcat ('xmlRead', tag));
         result = feval (func, fid, attrlist);
         data_ok = 1;
      end
    else %=== or is it a closing tag
      c = fgets (fid, 1);
      while ~feof (fid) & c ~= '>'
        c = fgets (fid, 1);
      end
    end
  else
    exit_loop = 1;
  end
end

