% ATOVS_DEFINE_HIRSL1C   Define a format of HIRS level 1c data record
%
% This function defines a format of HIRS level 1c data record.
%
% FORMAT   [rec_format, rec_len, nchan, nfovs] = atovs_define_hirsl1c;
%
% OUT   rec_format   Format of a record. A structure with fields:
%                    time, lat, lon, and tb.
%       rec_len      Length of a record.
%       nchan        Number of channels.
%       nfovs        Number of instrument field of views.

% 2004-06-29   Created by Mashrab Kuvatov.


function [rec_format, rec_len, nchan, nfovs] = atovs_define_hirsl1c;

% number of channels
nchan = 20;

% number of instrument field of views
nfovs = 56;

% length of a record
rec_len = 1664;

% define where each of these appear in the data records
rec_format.time     = 4;
rec_format.lat = 29 + 2 * [1:nfovs];
rec_format.lon = 30 + 2 * [1:nfovs];

for ichan = 1 : nchan
  rec_format.tb( ichan, : ) = 349 + ichan + nchan * [1:nfovs];
end

return