function S = common_read_avhrr_cmsaf_gac(file, varargin)

% common_read_cmsaf_gac Read AVHRR based data developed by CMSAF in the common format (see README)
%
% This file reads data from a AVHRR CMSAF GAC IWP file and rearranges the fields to
% the common format.
%
%
% IN
%
%   file    string      Path to hdf file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = common_read_cmsaf_gac(file, varargin)
%
% $Id$
% Created by Salomon Eliasson

core_fields   = {'time','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];
% List of hand-made fields that can be composed already here to save memory and
% storage space. I call them "pseudo fields" (e.g. modis_IWP that depends on 3
% fields in the modis file). The loop of hdfread will check if any psudeo fields
% are present. If so, it will be processed and the fields this pseudo field
% requires to be created are further assumed to be frivolous and therefore
% removed afterwards.
pseudo_fields = {'AVHRR_IWP'};

S.path = file; % get original file

% UNCOMPRESS first if gzipped
if strcmp(file(end-2:end),'.gz')
	tmpdir = create_tmpfolder;
	gfile = gunzip(file,tmpdir);
	file = gfile{1};
	c= onCleanup(@() rmdir(tmpdir,'s'));
end

for F = all_fields'
    if ismember(F{1},pseudo_fields)
        continue
    end
    S.(F{1}) = loadncvar(file,F{1});
end

% turn time data into seconds (in hours)
S.time = S.time*3600;
S.time = repmat(S.time,size(S.lon,1),1);

S.lat  = double(S.lat(:)*0.01); % use scale (see attributes)
S.lon  = double(S.lon(:)*0.01); % use scale (see attributes)
S.time = double(S.time(:));

% get the verion directly from the filename
x = datasets_config('avhrr_cmsaf');
info = x.find_info_from_granule(file);
S.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), str2double(info.day)));

%% Flatted matrixes according to conventions (not the pseudo fields)
S = flattenMatrixes(S,extra_fields(~ismember(extra_fields,pseudo_fields)));

if any(ismember(pseudo_fields,extra_fields))
    for P = pseudo_fields(:)'
        S = dealWithPseudoFields(S,P{1},file);
    end
end
S.version = info.version;

S = removeInvalidGeoTimedata(S);

end
%%%%%%%%%%%%%
% SUBFUNCTION

function S = flattenMatrixes(S,fields)
%% Flatted matrixes according to conventions

for F = fields(:)'
    tmp = permute(S.(F{1}),[3,1,2]);
    S.(F{1}) = squeeze(permute(tmp(:,:),[2,1]));
end

end

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. Will check in the loop if this field is present. The
% crux is that the fields the psuedo field relies on must be read, hence
% listed before it. This is because they are ofcourse needed to build the
% data field. and the fields it required are further assumed to be
% frivolous and therefore removed afterwards. This part is hardcoded

% READ dependent fields
switch field
    case 'AVHRR_IWP'
        dependent_fields = {'cwp','cty'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = loadncvar(file,F{1});
        end
        S = flattenMatrixes(S,dependent_fields);
end

% use dependent fields to BUILD the pseudo field
switch field
    case 'AVHRR_IWP'
        
        % Keeping record of the pixels that are deemed to be cloud free
        clearPixel = S.cty==0;
        %S.cwp(clearPixel)=0;
        
        % grab values flagged as ice phase
        icePhase = S.cty==2;
             
        % remove all non applicable data
        [sz1,~] = size(S.cwp);
        for F = fieldnames(S)'
            if isequal(size(S.(F{1}),1),sz1)
                S.(F{1}) = S.(F{1})(clearPixel | icePhase);
            end
        end
        S.AVHRR_IWP = S.cwp;
        
end

S=rmfield(S,dependent_fields(rmflag));
end