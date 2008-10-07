% ATOVS_DEFINE_AMSUAL1C   Define a format of AMSU-A level 1c data record
%
% This function defines a format of AMSU-A level 1c data record.
%
% FORMAT   [rec_format, rec_len, nchan, nfovs] = atovs_define_amsual1c;
%
% OUT   rec_format   Format of a record. A structure with fields:
%                    time, lat, lon, and tb.
%       rec_len      Length of a record.
%       nchan        Number of channels.
%       nfovs        Number of instrument field of views.

% 2004-06-29   Created by Mashrab Kuvatov.


function [rec_format, rec_len, nchan, nfovs] = atovs_define_amsual1c;

% number of channels
nchan = 15;

% number of instrument field of views
nfovs = 30;

% length of a record
rec_len = 768;

% define where each of these appear in the data records
rec_format.time     = 4;
rec_format.lat = 24 + 2 * [1:nfovs];
rec_format.lon = 25 + 2 * [1:nfovs];

for ichan = 1 : nchan
  rec_format.tb( ichan, : ) = 193 + ichan + nchan * [1:nfovs];
end

return