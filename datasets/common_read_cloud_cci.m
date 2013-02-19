function S = common_read_cloud_cci( file, varargin )
% COMMON_READ_CLOUD_CCI
%
% Read cloud cci data and output the data in the format common to all
% common_read_<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
%
% FORMAT
%
%   S = common_read_cloud_cci(file,varargin)
%
% IN
%
%   file    string      Path to file
%   fields  cell array (optional) extra fields.
%
% OUT
%
%   data    struct  At least with fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% NOTE
%               You can read special fields here:
%               "iwp". "cwp" and "phase" are used together to define it
%
%
% Salomon Eliasson
% $Id$

core_fields   = {'time','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

% valid pseudo fields that are not in the original data but are built
% on fields from the existing data fields
pseudo_fields = {'iwp'};

S = loadncvar(file, all_fields(~ismember(all_fields,pseudo_fields)) );
attr = loadncattr(file, all_fields(~ismember(all_fields,pseudo_fields)));

% Add offsets and scale the data if this is provided
for F = fieldnames(S)'
    if isfield(attr.(F{1}),'scale_factor')
        S.(F{1}) = (S.(F{1})*double(attr.(F{1}).scale_factor))+ ...
            double(attr.(F{1}).add_offset);
    end
end

% is saved as column major. flip the data.
refsz = size(S.lat);
for F = fieldnames(S)'
    if isequal(size(S.(F{1})),refsz)
        S.(F{1}) = S.(F{1})';
    end
end

S.time = S.time(:,1); %Each scanline has the same time. 'Julian Date, days elapsed since 12:00 January 1, 4713 BC'
[~,~,~,h,m,s] = jd2date(S.time);
S.time = h*3600+m*60+s; % seconds since O:00 UTC

S.lat = double(S.lat);
S.lon = double(S.lon);

% get additional stuff
D = datasets;
info = D.cloud_cci.find_info_from_granule(file);

S.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), str2double(info.day)));

if any(ismember(pseudo_fields,extra_fields))
    for P = pseudo_fields(ismember(pseudo_fields,extra_fields))
        S = dealWithPseudoFields(S,P{1},file);
    end
end

S.path = file;
ga = loadncglobalattr(file);
S.version = ga.product_version;

S = MaskInvalidGeoTimedataWithNaN(S);

end

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. The fields the pseudo fields required are further
% assumed to be frivolous and therefore removed afterwards, unless these
% fields were already read before this function.
% READ dependent fields
switch field
    case 'iwp'
        dependent_fields = {'cwp','phase'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file, F{1}); 
            attr = loadncattr(file, F{1});
            S.(F{1}) = (S.(F{1})*double(attr.scale_factor))+double(attr.add_offset);
        end
end



% column integrate
% use dependent fields to BUILD the pseudo field. maybe transpose to get
% the right orientation
% use dependent fields to BUILD the pseudo field
switch field
    case 'iwp'
        
        % Keeping record of the pixels that are deemed to be cloud free
        clearPixel = S.phase==0 & S.cwp ==0;
        
        % grab values flagged as ice phase
        icePhase = S.phase==2;
             
        % NaN all non applicable data
        S.cwp(~(clearPixel | icePhase)) = NaN;
        
        % Therefore we can call this simply IWP
        S.iwp = S.cwp'; % is saved as column major. need to flip for conventions
        
end


S=rmfield(S,dependent_fields(rmflag));
end