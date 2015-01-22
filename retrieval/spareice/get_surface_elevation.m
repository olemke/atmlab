function Z = get_surface_elevation(lat, lon, varargin)

persistent elev

if isempty(elev)
    %elev = loadncfile('/local/gerrit/data/ETOPO1_Ice_g_gmt4_1m.grd');
    elev = loadncfile('/scratch/uni/u237/data/etopo1/ETOPO1_Ice_g_gmt4_1m.grd');
end

if isempty(lat)
    Z = [];
    return;
end

mode = optargs(varargin, {0});

lat_i = round(interp1(elev.lat, 1:length(elev.lat), lat));
lon_i = round(interp1(elev.lon, 1:length(elev.lon), lon));
Z = elev.z(sub2ind(size(elev.z), lon_i, lat_i));

if mode==1 % calculate std.dev instead
    all9 = zeros(3, 3, length(lat_i));
    for dlati = -1:1
        for dloni = -1:1
            all9(dlati+2, dloni+2, :) = ...
                elev.z(sub2ind(...
                    size(elev.z), ...
                    mod(lon_i+dloni, length(elev.lon))+1, ...
                    min(max(lat_i+dlati, 1), length(elev.lat))));
        end
    end
    Z = std(reshape(all9, 9, []), 0, 1);
end
end
