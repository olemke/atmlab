function data = cloudsat_read_zipped(CSin, varargin)

% cloudsat_read_zipped unpack CS file, return input, remove unpacked file
%
% This is a wrapper around cloudsat_read that unzips the file, reads the data
% and then deletes the unzipped file.
%
% $Id$

filenames = unzip(CSin, tempdir);
CSout = filenames{1};
data = cloudsat_read(CSout, varargin{:});
delete(CSout);
