function S = common_read_dardar(file, varargin)

% common_read_modis Read DARDAR data in the common format (see README)
%
% This file reads data from a DARDAR file and rearranges the fields to
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
%   S = common_read_dardar(file, varargin)
%
% $Id$
% Created by Salomon Eliasson

core_fields   = {'time','latitude','longitude'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];
% List of hand-made fields that can be composed already here to save memory and
% storage space. I call them "pseudo fields" (e.g. modis_IWP that depends on 3
% fields in the modis file). The loop of hdfread will check if any psudeo fields
% are present. If so, it will be processed and the fields this pseudo field
% requires to be created are further assumed to be frivolous and therefore
% removed afterwards.
pseudo_fields = {'dardar_IWP'};

for F = all_fields'
    if ismember(F{1},pseudo_fields)
        continue
    end
    S.(F{1}) = hdfread(file,F{1});
    if isvector(S.(F{1})) && ~iscolumn(S.(F{1})) && length(S.(F{1})) == length(S.time)
        S.(F{1}) = S.(F{1}).';
    end
end


% CONSTRUCT time axis with same dimensions
S.lat = double(S.latitude(:));
S.lon = double(S.longitude(:));
S.time = double(S.time(:));

% get the verion directly from the filename
D = datasets;
info = D.dardar.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

if any(ismember(pseudo_fields,extra_fields))
    for P = pseudo_fields(:)'
        S = dealWithPseudoFields(S,P{1},file);
    end
end
S.version = info.version;
S.path = file;

S = removeInvalidGeoTimedata(S);

S = rmfield(S,{'latitude','longitude'});
end
%%%%%%%%%%%%%
% SUBFUNCTION

function S = dealWithPseudoFields(S,field,file)
%% dealWithPseudoFields
%
% List of hand-made fields that can be composed already here to save memory
% and storage space. Will check in the loop if this field is present. The
% fields required to generate the pseudo fields are further assumed to be
% frivolous and therefore removed afterwards.

% READ dependent fields
switch field
    case 'dardar_IWP'
        dependent_fields = {'iwc','height','ln_iwc_error'};
        rmflag = ~ismember(dependent_fields,fieldnames(S));
        for F = dependent_fields
            S.(F{1}) = hdfread(file,F{1});
        end
        S.height = repmat(S.height,size(S.iwc,1),1);
end

% use dependent fields to BUILD the pseudo field
switch field
    case 'dardar_IWP'
        
        % get the footprints that are cloud free
        cloudFree = sum(S.iwc,2)==0;
        S.dardar_IWP = column_integrate(S,{'iwc','height'});
        
        % with IWP comes also IWP error
        S.dardar_IWP_error = column_integrate(...
            struct('errorIWC',S.iwc.*S.ln_iwc_error,'height',S.height),{'errorIWC','height'})./S.dardar_IWP;
        
        S.dardar_IWP_error(cloudFree)=0;
        
        S.dardar_IWP = S.dardar_IWP(:);
        S.dardar_IWP_error = S.dardar_IWP_error(:);
end

S=rmfield(S,dependent_fields(rmflag));
end
