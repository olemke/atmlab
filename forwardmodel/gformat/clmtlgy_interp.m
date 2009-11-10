% CLMTLGY_INTERP   Interpolation of climatology data
%
%     The climatology data are interpolated (using gf_regrid) to the specified
%     pressure(s), position(s) and time(s). The data are returned in original
%     format for those dimension where no interpolation point is given ([]).
%     The data are treated to be valid at all positions for dimensions where
%     the size is 1. For example, a climatology holding zonal mean profiles
%     should have size 1 for the longitude (third) dimension.
%     
%     The time dimension (fourth) can use different formats. The following 
%     time formats are handled:
%        'doy'     : day of the year (see *mjd2doy* for definition)
%        'mjd'     : modified julian data 
%        'datenum' : Matlab's datenum (with default pivot year).
%     The function will look for G.TFORMAT to determine used time format.
%     If this field is not found, an intelligent guess will be made based
%     values in time grid. Valid range for 'doy' is [1,367].
%
% FORMAT   F = clmtlgy_interp( D, G, p [, lat, lon, time ] )
%             or
%          F = clmtlgy_interp( D, G, p [, lat, lon, ...
%                           year, month, day, hour, minute, second, tformat ] )
%        
% OUT   F        Derived field/profile(s).
% IN    D        Gformat definition structure.
%       G        Climatology data (in gformat).
%       p        Pressure value or vector.
% OPT   lat      Latitude value or vector. Default is [].
%       lon      Longitude value or vector. Default is [].
%        -
%       time     If only one argument is given after lon, this value is 
%                interpreted as time following G.TFORMAT/time grid. That is,
%                doy, mjd or datenum.
%        -
%       year     Year value or vector. Default is [].
%       month    Month value or vector. Default is [].
%       day      Day value or vector. Default is [].
%       hour     Hour value or vector. Default is [].
%       minute   Minute value or vector. Default is [].
%       second   Second value or vector. Default is [].

% 2008-10-08   Created by Patrick Eriksson.

function F = clmtlgy_interp( D, G, p, lat, lon, ...
                              year, month, day, hour, minute, second )

%- Default values
%
lat_DEFAULT     = [];
lon_DEFAULT     = [];
year_DEFAULT    = [];
month_DEFAULT   = [];
day_DEFAULT     = [];
hour_DEFAULT    = [];
minute_DEFAULT  = [];
second_DEFAULT  = [];
%
set_defaults;


%- Check input
%
if any( ~strcmp( fieldnames(D), fieldnames(clmtlgy_define) ) )
  error( 'Input *D* does not follow the format expected for climatology data' )
end
%
gf_check( D, G );


%- Time format
%
if ~isfield( G, 'TFORMAT' )
  if size(G.DATA,4) == 1  |  ( min(G.GRID4)>=0 & max(G.GRID4) <= 367 )
    tformat = 'doy';       % Use doy as dummy for the "non-interp" case
  elseif max(G.GRID4) < 1000*365
    tformat = 'mjd';   
  elseif max(G.GRID4) < 1000*365
    tformat = 'datenum';   
  end
else
  tformat = G.TFORMAT;
end
%
if nargin == 6
  t = year;
else
  switch lower(tformat)
    case 'doy'
      t = mjd2doy( date2mjd( year, month, day, hour, minute, second ) );
    case 'mjd'
      t = date2mjd( year, month, day, hour, minute, second );
    case 'datenum'
      t = datenum( year, month, day, hour, minute, second );
    otherwise
      error( 'Unknown slection for *tformat*.' );
  end
end


if size(G.DATA,1) > 1  &  ~isempty(p)
  dims     = 1;
  grids{1} = p;
else
  dims = [];
end

if size(G.DATA,2) > 1  &  ~isempty(lat)
  dims(end+1)  = 2;
  grids{end+1} = lat;
end

if size(G.DATA,3) > 1  &  ~isempty(lon)
  dims(end+1)  = 3;
  grids{end+1} = lon;
end

if size(G.DATA,4) > 1  &  ~isempty(t)
  dims(end+1)  = 4;
  grids{end+1} = t;
end


%- Perform interpolation/regrid
%
F = gf_regrid( D, G, grids, dims );
%
F = F.DATA;