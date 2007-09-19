%------------------------------------------------------------------------
% OUT   Prints screen messages with some layout
%
%          The verbosity is determined by the general Atmlab setting 
%          VERBOSITY. This function is called by setting a report level
%          and if this level is <= than VERBOSITY, the message is 
%          displayed. Otherwise it is ignored.
%
%          The function puts a frame around the text. The width of this
%          frame is set by the general setting SCREEN_WIDTH. To begin a 
%          frame put s=1, to end s=-1. A braking line is obtained by s=0.
%
%          An example. The command
%
%            out(1,1);out(1,'Heading');out(1,0);out(2,'Some text');out(1,-1)
%
%          gives
%
%           /--------------------------------------------------------------\
%           | Heading                                                      |
%           |--------------------------------------------------------------|
%           |   Some text                                                  |
%           \--------------------------------------------------------------/
%
%          The function can also be used to determine if figures etc.
%          shall be produced (the last format example).
%
%          The output can also be directed to a file by using the optional
%          argument *fid*. Note that you can write to several files and
%          the screen by making *fid* a vector. The screen has identifier 1.
%
% FORMAT:  out( level, s [, fid] )
%            or
%          do_output = out( level )
%
% OUT:     do_output   Boolean. True if level <= VERBOSITY
% IN:      level       Report level for the message. This can be specified
%                      for each entry in *fid*. Default is 0. This values is
%                      also applied if *level* is shorter than *fid*.  
%          s           Message. Can be a string matrix (see str2mat).
%                      If s is an integer, different vertical lines are
%                      produced (see above).
% OPT      fid         Vector with file identifiers. Default is 1, which
%                      is standard output (screen).
%------------------------------------------------------------------------

% HISTORY: 040907  Copied from AMI and modified to Atmlab by Patrick
%                  Eriksson, who also made AMI version.


function do_output = out( level, s, fid )

level_DEFAULT = 0;
%
set_defaults;

if nargin < 3
  fid = 1;
end


if length(fid) > 1
  for i = 1 : length(fid)
    if length(level) >= i
      out( level(i), s, fid(i) );
    else
      out( 0, s, fid(i) );
    end
  end
  return
end


%=== Check data
%
atmlab( 'require', {'VERBOSITY','SCREEN_WIDTH'} );
verbosity = atmlab( 'VERBOSITY' );
ncols     = atmlab( 'SCREEN_WIDTH' );
rqre_scalar( 'Atmlab setting VERBOSITY', verbosity, 0 );
rqre_scalar( 'Atmlab setting SCREEN_WIDTH', ncols, 0 );
rqre_scalar( 'Input argument *level*', level, 0 );


if level <= verbosity
  do_output = 1;
else
  do_output = 0;
  return
end


if nargin == 1
  return;
end

if level == 0
  level = 1;
end

if ischar(s)

  for i = 1:size(s,1)
  
    fprintf(fid,'| ');
  
    %Indention
    for j = 1:(level-1)
      fprintf(fid,'  ');
    end
  
    fprintf(fid,'%s',s(i,:));
  
    for j = 1:(ncols-length(s)-(level-1)*2-3)
      fprintf(fid,' ');
    end
  
    fprintf(fid,'|\n');
  
  end


else

  %=== Start line
  if s > 0
    fprintf(fid,'\n/');
    for j = 1:(ncols-2)
      fprintf(fid,'-');
    end
    fprintf(fid,'\\\n');

  %=== Brake line
  elseif s == 0
    fprintf(fid,'|');
    for j = 1:(ncols-2)
      fprintf(fid,'-');
    end
    fprintf(fid,'|\n');

  %=== End line
  else
    fprintf(fid,'\\');
    for j = 1:(ncols-2)
      fprintf(fid,'-');
    end
    fprintf(fid,'/\n');
  end

end
