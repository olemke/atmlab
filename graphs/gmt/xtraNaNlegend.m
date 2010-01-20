function file = xtraNaNlegend()

%%%%%%%%%%%%%%%% xtraNaNlegend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Purpose: To create an extra legend box for the missing values
%          (allways grey)
%
% Out: The output-file location
%
% Author: Salomon Eliasson
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create NaN.cpt for NaN colorbox
file = 'color_NaN.cpt'; %save to local file
fid = fopen(file,'w');
%##################### HEADER ###############################
fprintf(fid,'%s\n','#cpt file created by: xtraNaNlegend.m');
fprintf(fid,'%s\n','# Created for NaN colorbox');
fprintf(fid,'%s\n%s\n','#COLOR_MODEL = RGB','#'); %currently only hew rainbow
                                                  %############################################################
fprintf(fid,'%i\t%i\t%i\t%i\t%s\n',100,128,128,128,';NaN');
fclose(fid);