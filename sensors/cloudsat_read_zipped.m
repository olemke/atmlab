function data = cloudsat_read_zipped(CSin, varargin)

% cloudsat_read_zipped unpack CS file, return input, remove unpacked file
%
% This is a wrapper around cloudsat_read that unzips the file, reads the data
% and then deletes the unzipped file.
%
% $Id$

tmpdir = create_tmpfolder;
filenames = unzip(CSin, tmpdir);
CSout = filenames{1};
c = onCleanup(@() rmdir(tmpdir,'s'));
data = read_cloudsat_hdf(CSout, varargin{:});
