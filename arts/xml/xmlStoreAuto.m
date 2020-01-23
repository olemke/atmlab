% XMLSTOREAUTO   Creates multiple ARTS XML from structure array
%
%   A file is created for each field of argument *D*. The field names in *D*
%   are taken as the name of a variable and a corresponding file will be
%   created. If *D* has field *D.p_grid*, the file p_grid.xml will be
%   created (in the folder specified by *outfolder*):
%
%   For each variable, these fields are defined:
%     data     Data to be saved (mandatory)
%     group    Group of the variable (optional)
%     format   Format for saving (optional, default is 'binary')
%
%   If the group field is not set, or is empty, an attempt to set the group by
%   *wsv2group* is made. The later only works for defined ARTS workspace
%   variables, and the group must be given for all non-standard WSVs.
%
%   Options for *format* are: 'float', 'double' and 'binary' 
%
% FORMAT   xmlStoreAuto(outfolder,D)
%
% IN outfolder   Files are placed in this folder
%    D           Structure with data. See above.

% 2020-01-23 Patrick Eriksson

function xmlStoreAuto(outfolder,D)

wsvs = fieldnames( D );

for i = 1:length(wsvs)
   
   wsv = wsvs{i};

   if isfield(D.(wsv), 'group' ) & ~isempty(D.(wsv).group)
     group = D.(wsv).group;
   else
     try
       group = wsv2group( wsv );
     catch
       error('Function *wsv2group* failed to determine group of variable %s',...
             wsv );
     end
   end
   
   if isfield(D.(wsv), 'format' ) & ~isempty(D.(wsv).format)
     prec = D.(wsv).format;
   else
     prec = 'binary';
   end
   
   xmlStore( fullfile(outfolder,[wsv,'.xml']), D.(wsv).data, group, prec );
end