% ATOVS_READ_DATA   Read ATOVS level 1c data
%
% This function reads ATOVS level 1c data.
%
% FORMAT   data = atovs_read_data( file_name );
%
% IN    file_name   File name.
% OUT   data        Data structure with the following fields:
%                   time   Vector of scanline time stamps in UTC [msec].
%	            lon    2D matrix (fov,scanline) of longitudes in [degrees].
%		    lat    2D matrix (fov,scanline) of latitudes in [degrees].
%		    tb     3D matrix (fov,channel,scanline) of brightness
%                          temperatures in [K].
%       err         Error flag. 0 - no error, 1 - error.

% 2004-06-29   Created by Mashrab Kuvatov.


function [data, err] = atovs_read_data( file_name );

% no error
err = 0;

% determine satellite and instrument IDs, data level,
% and number of scan lines
[sat_id, inst_id, level, nlines, err] = atovs_read_header( file_name );

if err ~= 0
  % error
  disp( 'Error. Unable to read input file.' );
  data = [];
  err = 1;
  return
end

% make sure it is level 1c data
if ~strcmp( level, 'l1c')
  % error
  disp( 'Error. Input file must be of level 1c.' );
  data = [];
  err = 1;
  return
end

% depending on instrument, define data record format
switch inst_id
 case 'AMSU-B'
  [rec_format, rec_len, nchan, nfovs] = atovs_define_amsubl1c;
 case 'AMSU-A'
  [rec_format, rec_len, nchan, nfovs] = atovs_define_amsual1c;
 case 'HIRS'
  [rec_format, rec_len, nchan, nfovs] = atovs_define_hirsl1c;
end

% open a file
% 'b' means big-endian byte ordering
file_id = fopen( file_name, 'r', 'b' );

% skip the header
fseek( file_id, rec_len * 4, -1 );

% read all records
[record, count] = fread( file_id, rec_len * nlines, 'int32' );

% close a file
fclose( file_id );

% number of scan lines read
nlines_read = count / rec_len;

% if amount of data read is less than asked
if count < rec_len * nlines
  % if some scan lines are missing, we still can go on
  if isinteger( nlines_read )
    disp( 'Warning. Some scanlines are missing.' );
  % if number of scan lines is not integer, part of a record is missing
  else
    disp( 'Error. Input file is corrupt.' );
    data = [];
    err = 1;
    return
  end
end

% Reshape read data. Result: rec_len rows and nlines_read columns
record = reshape( record, rec_len, nlines_read );

% read into the structure according to the record format
data.lon = record( rec_format.lon, : ) * .0001;
data.lat = record(  rec_format.lat, : ) * .0001;
data.time = record( rec_format.time, : );
data.tb = reshape( record( rec_format.tb', : ) * .01, nfovs, nchan, nlines_read );

return