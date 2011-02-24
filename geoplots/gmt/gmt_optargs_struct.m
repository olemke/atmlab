function out = gmt_optargs_struct(userin, defaults)

% gmt_optargs_struct  A help function to handle optional arguments in a struct
%
% This function provides a simply way to define default values for function
% inputs where this input consists of a structure. It takes two structures,
% one consisting of default values and one of user-provided values. It
% returns a structure containing the user values where provided and the
% default values otherwise.
%
% FORMAT
%
%   out = gmt_optargs_struct(userin, defaults)
%
% IN
%
%   userin      structure   User provided optional settings
%   defaults    structure   Default values.
%
% OUT
%
%   merged      structure   User's value where provided, default otherwise
%
% See also: <a href="matlab:help optargs">optargs</a>
% 
% 
% 2011-02-24 Cloned from  optargs_struct.m by Gerrit Holl in atmlab


out = defaults;
fields_userin = fieldnames(userin);
for i = 1:length(fields_userin)
    f = fields_userin{i};
    out.(f) = userin.(f);
end

end
