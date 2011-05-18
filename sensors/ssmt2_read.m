% SSMT2_READ   Read SSM/T-2 data file.
%
%    Reads an SSM/T-2 file into a structure and applies calibration.
%
%    This function is based on the ssmt2list C program written by Don Moss,
%    University of Alabama in Huntsville.
%
%    Known Bugs: dataset name is not read correctly (but also not important)
%
% FORMAT   S = ssmt2_read (filename, apply_calibration)
%        
% OUT   S   SSM/T-2 structure
%             Header information:
%               dsname   Dataset name (currently unsupported)
%               nscan    Number of scans
%               ngap     Data gaps
%               precal   Preflight calibration (not used)
%               apc      Antenna pattern correction coefficients
%               qc_earth QC of earth locations
%               qc_scene QC of scene data
%               qc_cal   Calibration QC flags
%             Data records S.recs():
%               orbit    Orbit number
%               scan     Scan number
%               t1x      ?
%               yyddd    Year and day of year
%               ols      ?
%               ts       ?
%               lat      Latitude earth location vector
%               lon      Longitude earth location vector
%               time     Scene time data
%               count    Scene raw count data (not returned if
%                        apply_calibration is set to true or not given)
%               temp     Scene calibrated antenna temperatures (not returned if
%                        apply_calibration is set to false)
%               rawcal   Raw calibration data (not used)
%               slopes   Calibration slopes
%               offset   Calibration intercepts
%               qc_earth QC flags of earth locations
%               qc_scene QC flags of scene data
%               qc_cal   Calibration QC flags
%               
%               
% IN    filename            Name of SSM/T-2 file
% OPT   apply_calibration   Pass false to get the raw count values,
%                           (default: true)

% 2009-11-20   Created by Oliver Lemke.

function S = ssmt2_read (filename, apply_calibration)

if nargin == 1
  apply_calibration = 1;
end

uncompressed_filename='';
if strcmp( filename(length(filename)-2:end), '.gz')
  workarea = atmlab( 'WORK_AREA' );
  uncompressed_filename = tempname(workarea);
  cmd = [ 'gunzip -cd ' filename ' > ' uncompressed_filename ];
  st = system (cmd);
  if st
    delete (uncompressed_filename);
    error ('Failed to uncompress SSM/T-2 file');
  end
  filename = uncompressed_filename;
end

HDRSIZE = 692;
DATSIZE = 692;
NPOS    = 28;
NCHAN   = 5;

ebcdic_ascii = [ ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	' ','?','?','?','?','?','?','?','?','?','?','.','?','?','+','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'-','?','?','?','?','?','?','?','?','?','?','?','?','_','?','?', ...
	'?','?','?','?','?','?','?','?','?','?',':','#','@','?','=','?', ...
	'?','a','b','c','d','e','f','g','h','i','?','?','?','?','?','?', ...
	'?','j','k','l','m','n','o','p','q','r','?','?','?','?','?','?', ...
	'?','?','s','t','u','v','w','x','y','z','?','?','?','?','?','?', ...
	'?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?', ...
	'?','A','B','C','D','E','F','G','H','I','?','?','?','?','?','?', ...
	'?','J','K','L','M','N','O','P','Q','R','?','?','?','?','?','?', ...
	'?','?','S','T','U','V','W','X','Y','Z','?','?','?','?','?','?', ...
	'0','1','2','3','4','5','6','7','8','9','?','?','?','?','?','?' ...
    ];

fid = fopen (filename, 'rb', 'b');

if (fid == -1)
  error ('Can''t open input file')
end

%%%%%%%%%% Read Header %%%%%%%%%%
%
S.dsname  = ebcdic_ascii (fread (fid, 44, 'uint8'));
S.nscan   = fread (fid, 1, 'uint16');
S.ngap    = fread (fid, 1, 'uint16');
S.precal  = fread (fid, 108, 'uint8');

S.apc  = reshape (fread (fid, NPOS*NCHAN, 'uint16') / 100, NCHAN, NPOS)';

S.qc_earth = fread (fid, 1, 'uint16');
S.qc_scene = fread (fid, 1, 'uint16');
S.qc_cal   = fread (fid, NCHAN, 'uint16');

%%%%%%%%%% Read Data Records %%%%%%%%%%
%
recn = 0;
try
  while (~feof (fid) && recn < S.nscan)
    recn = recn + 1;
    fseek (fid, recn*692, 'bof');

    rec.orbit = fread (fid, 1, 'uint32');
    
    if (~rec.orbit)
      fclose (fid);
      if ~strcmp (uncompressed_filename, ''), delete (uncompressed_filename); end;
      return;
    end

    rec.scan  = fread (fid, 1, 'uint16');
    rec.t1x   = fread (fid, 1, 'uint16');
    rec.yyddd = fread (fid, 1, 'uint32');
    rec.ols   = fread (fid, 1, 'uint32');
    rec.ts    = fread (fid, 1, 'uint32');

    latlon = reshape (fread (fid, NPOS*2, 'int16') / 128, 2, NPOS);
    rec.lat = latlon (1, :);
    rec.lon = latlon (2, :);
  
    timecount = reshape (fread (fid, (1+NCHAN)*NPOS, 'uint16'), 1+NCHAN, NPOS);
    rec.time  = timecount (1, :);
    rec.count = timecount (2:NCHAN+1, :);

    rec.rawcal = fread (fid, 172, 'uint8');

    rec.slope  = fread (fid, NCHAN, 'int16')' / 10000;
    %FIXME OLE: The offset factor was changed at some point 
    %rec.offset  = fread (fid, NCHAN, 'int16')' / 100;
    rec.offset  = fread (fid, NCHAN, 'int16')' / 20;

    rec.qc_earth = fread (fid, 1, 'uint16');
    rec.qc_scene = fread (fid, 1, 'uint16');
    rec.qc_cal   = fread (fid, NCHAN, 'uint16')';

    %%%%%%%%%% Apply calibration %%%%%%%%%%
    %
    if (apply_calibration)
      if (apply_calibration == 2)
        experimental_offset_calibration = [0.2815 0.2915 0.2782 0.3762 1.1355];
      else
        experimental_offset_calibration = [1 1 1 1 1];
      end    
      for chan = 1:NCHAN
        rec.temp(chan,:) = rec.count(chan,:) * rec.slope(chan) ...
            + rec.offset(chan) * experimental_offset_calibration(chan);
      end
    end

    S.recs(recn) = rec;
    clear rec;
  end
catch
  fclose (fid);
  if ~strcmp (uncompressed_filename, ''), delete (uncompressed_filename); end;
  return;
end

fclose(fid);
if ~strcmp (uncompressed_filename, ''), delete (uncompressed_filename); end;

