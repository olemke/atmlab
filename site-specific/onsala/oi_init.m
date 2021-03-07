% Sets personal settings
%
% FORMAT P = oi_init
%
% OUT   P   Project settings structure

% 2021-02-06 Patrick Eriksson


function P = oi_init


switch whoami
   
  case 'patrick'
    %
    P.workfolder   = [];
    P.indatafolder = '/home/patrick/Projects/OsoInv/Observations';
    P.era5folder   = '/home/patrick/Dendrite/Projects/Onsala_ERA_data';

  otherwise
    error('Unknown user (%s)', whoami);
end
