function S = avhrr_gac_read(filename)

% AVHRR_GAC_READ Read and calibrate AVHRR GAC L1B data.
%
% Work in progress.  Implemented thermal channels.  Not yet implemented
% solar channels.  So far returns ONLY brightness temperatures, no
% geolocation or anything else.
%
% TODO:
%
% - verify data integrity
% - look at quality flags etc.
% - geolocate data
% - read arbitrary fields
% - write documentation
% - verify correctness
% - read entire files
% - finalise

% $Id$

%limit = 500; % while still in progress
[data_head, data_line] = avhrr_gac_read_raw(filename, ...
    {'avh_h_satid', 'avh_h_siteid', 'avh_h_hdrcnt', ...
    'avh_h_radtempcnv3b1', 'avh_h_radtempcnv3b2', 'avh_h_radtempcnv3bc', ...
    'avh_h_radtempcnv41', 'avh_h_radtempcnv42', 'avh_h_radtempcnv4c', ...
    'avh_h_radtempcnv51', 'avh_h_radtempcnv52', 'avh_h_radtempcnv5c'}, ...
    {'avh_calvis_os11', 'avh_calvis_oi11', ...
     'avh_calvis_os12', 'avh_calvis_oi12', ...
     'avh_calvis_oi1', ...
     'avh_calvis_os21', 'avh_calvis_oi21', ...
     'avh_calvis_os22', 'avh_calvis_oi22', ...
     'avh_calvis_oi2', ...
     'avh_calvis_os3a1', 'avh_calvis_oi3a1', ...
     'avh_calvis_os3a2', 'avh_calvis_oi3a2', ...
     'avh_calvis_oi3a', ...
     'avh_calir_o3b1', 'avh_calir_o3b2', 'avh_calir_o3b3', ...
     'avh_calir_o41', 'avh_calir_o42', 'avh_calir_o43', ...
     'avh_calir_o51', 'avh_calir_o52', 'avh_calir_o53', ...
     'avh_video', 'avh_scnlin', 'avh_scnlinyr', ...
     'avh_telem_id', ...
     'avh_scnlintime', 'avh_pos'});

S.y = calibrate_avhrr(data_head, data_line);
S.time = compensate_wraparound([data_line.avh_scnlintime]/1000);
[S.lat, S.lon] = navigate_avhrr(data_head, data_line);
end

function y = calibrate_avhrr(data_head, data_line)

% Calibrate AVHRR GAC solar and thermal channels
%
% FORMAT
%
%   calib = calibrated_avhrr(data_head, data_line)

N_lines = length(data_line); % while still in progress

% Field avh_telem_id contains bit flags (Scan Line Bit Field).
% The first 2 bits specify "channel 3 select (0=3B; 1=3A; 2=transition)".

chan3_is_3a = logical(bitand(par([data_line.avh_telem_id], 1, ':'), 1));

% Unpack 10-bit data into 16-bits for easier handling
%
% TODO: make this call vectorised; consumes 70% of time for
% calibrate_avhrr
% (but calibrate_avhrr consumes only 17% of avhrr_gac_read)
%ce = par(unpack_bip(data_line(1).avh_video), ':', 4);
X = arrayfun(@(i) unpack_bip(data_line(i).avh_video), 1:N_lines, 'UniformOutput', false);
ce = reshape(vertcat(X{:}), [409, N_lines, 5]);

% pre-allocate calibrated radiance array
Ne = zeros(size(ce), 'single');

%% calibrate visible channels
%
% According to NOAA KLM User's Guide, Section 7.1.1, page 7-2 (page 248)
% and onward
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c7/sec7-1.htm#a041801aa
%
% A = SC + I
%
% with one pair of (S, I) for C<avh_calvis_oi1 and one pair (S, I) for
% C>avh_calvis_oi1

intercept = bsxfun(@lt, ...
                   single(ce(:, :, 1:3)), ...
                   shiftdim([data_line.avh_calvis_oi1; ...
                             data_line.avh_calvis_oi2; ...
                             data_line.avh_calvis_oi3a].', ...
                            -1));

below = bsxfun(@plus, ...
               bsxfun(@times, ...
                      shiftdim([data_line.avh_calvis_os11; ...
                                data_line.avh_calvis_os21; ...
                                data_line.avh_calvis_os3a1].', ...
                               -1), ...
                      single(ce(:, :, 1:3))), ...
               shiftdim([data_line.avh_calvis_oi11; ...
                         data_line.avh_calvis_oi21; ...
                         data_line.avh_calvis_oi3a1].', ...
                        -1));

above = bsxfun(@plus, ...
               bsxfun(@times, ...
                      shiftdim([data_line.avh_calvis_os12; ...
                                data_line.avh_calvis_os22; ...
                                data_line.avh_calvis_os3a2].', ...
                               -1), ...
                      single(ce(:, :, 1:3))), ...
               shiftdim([data_line.avh_calvis_oi12; ...
                         data_line.avh_calvis_oi22; ...
                         data_line.avh_calvis_oi3a2].', ...
                        -1));
           
albedo = zeros(size(below), 'single');
albedo(intercept) = below(intercept);
albedo(~intercept) = above(~intercept);

%% calibrate thermal channels
%
% According to NOAA KLM User's Guide, Section 7.1.2.3, page 7-7 (page 253),
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c7/sec7-1.htm#a091405a
%
% Equation (7.1.2.3-1):
%
% Ne = a0 + a1*ce + a2*ce^2;

% extract calibration coefficients

a0 = [data_line.avh_calir_o3b1; ...
      data_line.avh_calir_o41; ...
      data_line.avh_calir_o51];
a1 = [data_line.avh_calir_o3b2; ...
       data_line.avh_calir_o42; ...
       data_line.avh_calir_o52];
a2 = [data_line.avh_calir_o3b3; ...
       data_line.avh_calir_o43; ...
       data_line.avh_calir_o53];

% calibrate channel 3B where appropriate

Ne(:, ~chan3_is_3a, 3) = ...
    bsxfun(@plus, ...
           a0(1, :), ...
           bsxfun(@plus, ...
                  bsxfun(@times, a1(1, :), single(ce(:, :, 3))), ...
                  bsxfun(@times, a2(1, :), single(ce(:, :, 3)).^2)));

% calibrate channels 4 and 5

term2 = bsxfun(@times, shiftdim(a1(2:3, :).', -1), single(ce(:, :, 4:5)));
term3 = bsxfun(@times, shiftdim(a2(2:3, :).', -1), single(ce(:, :, 4:5)).^2);
Ne(:, :, 4:5) = bsxfun(@plus, ...
                       shiftdim(a0(2:3, :).', -1), ...
                       bsxfun(@plus, term2, term3));

if any(any(any(Ne<0)))                  
    logtext(atmlab('ERR'), 'Setting %d negative radiances to 0!\n', ...
        length(find(Ne<0)));
    Ne(Ne<0) = 0;
end
% now Ne contains radiance in mW/(m2-sr-cm-1) 

%% Convert radiances to brightness temperatures
%
% According to NOAA KLM User's Guide, equation (7.1.2.4-8, -9).
% Page 7-10 (page 256),
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c7/sec7-1.htm#a070102d
%
% Te* = c2*vc/log(1 + c1*v^3/Ne)
% Te = (Te*-A)/B
%
% with (c1, c2) from Nigel Atkinson and (A, B) from headers

vc = [data_head.avh_h_radtempcnv3bc, data_head.avh_h_radtempcnv4c, data_head.avh_h_radtempcnv5c];
b1 = [data_head.avh_h_radtempcnv3b1, data_head.avh_h_radtempcnv41, data_head.avh_h_radtempcnv51];
b2 = [data_head.avh_h_radtempcnv3b2, data_head.avh_h_radtempcnv42, data_head.avh_h_radtempcnv42];
%[vc_, A_, B_] = avhrr_coef_therm2rad(data_head.avh_h_satid);

% Coefficients from word-document attached by Nigel Atkinson  
c1 = 1.191e-5; % mW m^-2 sr^-1 cm^4
c2 = 1.439; % K cm

Tep = zeros(size(Ne), 'single');

Tep(:, ~chan3_is_3a, 3) = ...
    c2 * vc(1) ./ log(1 + c1 * vc(1).^3 ./ Ne(:, :, 3));

Tep(:, :, 4:5) = ...
    bsxfun(@rdivide, ...
           c2 * reshape(vc(2:3), [1, 1, 2]), ...
           log(1 + c1 * bsxfun(@rdivide, ...
                              reshape(vc(2:3).^3, [1, 1, 2]), ...
                              Ne(:, :, 4:5))));
% The following two equations are equivalent:
% Tb = (Tep - A) / B;
% Tb = b1 + b2 * Tep;
% ...with A, B from KLM User's Guide or b1, b2 from headers

Tb = zeros(size(Tep), 'single');

Tb(:, ~chan3_is_3a, 3) = b1(1) + b2(1) * Tep(:, ~chan3_is_3a, 3);

Tb(:, :, 4:5) = bsxfun(@plus, ...
                       reshape(b1(2:3), [1, 1, 2]), ...
                       bsxfun(@times, ...
                              reshape(b2(2:3), [1, 1, 2]), ...
                              Tep(:, :, 4:5)));

%% Put it all together                          

y = zeros(size(Ne), 'single');

y(:, :, 1:2) = albedo(:, :, 1:2);

y(:, chan3_is_3a, 3) = albedo(:, chan3_is_3a, 3);

y(:, ~chan3_is_3a, 3) = Tb(:, ~chan3_is_3a, 3);

y(:, :, 4:5) = Tb(:, :, 4:5);

end

function [lat, lon] = navigate_avhrr(data_head, data_line)
% Calculate lan/lon for each observation
%
% From NOAA KLM User's Guide, Table 8.3.1.4.3.2 (page 8-79 / 363)
%
% lat/lon 5, 13, ..., 405
% for viewpos 1, 2, ..., 409
%
% Distance between anchorpoints is 30–150 km
%
% UNFINISHED!

loc = reshape([data_line.avh_pos], [2, 51, 9320]);
nlines = length(data_line);
lat = zeros(409, nlines);
lon = zeros(409, nlines);

pos_given = 5:8:405;
%{
IDL code

spots_nav = lindgen(51)*8 + 5
d2r = !pi/180

nspots = 409
spots_req = lindgen(nspots) + 1

nlines = n_elements(pos(0,0,*))
lat = fltarr(nspots,nlines)
lon = fltarr(nspots,nlines)

for iline=0,nlines-1 do begin
  lat_in = pos(0,*,iline)*1.0E-4*d2r
  lon_in = pos(1,*,iline)*1.0E-4*d2r

  x_in = cos(lon_in)*cos(lat_in);
  y_in = sin(lon_in)*cos(lat_in);
  z_in = sin(lat_in);

  x = spline(spots_nav,x_in,spots_req)
  y = spline(spots_nav,y_in,spots_req)
  z = spline(spots_nav,z_in,spots_req)

  lon(*,iline) = atan(y,x)/d2r
  lat(*,iline) = atan(z,sqrt(x*x + y*y))/d2r
endfor

%}


end
function [vc, A, B] = avhrr_coef_therm2rad(satid)
% get coefficients for thermal channel temperature-to-radiance
%
% satid as per field avh_h_satid 'Spacecraft Identification Code'.
% From NOAA KLM User's Guide, Table 8.3.1.4.2.1-1:
%
% 2=NOAA-L
% 4=NOAA-K
% 6=NOAA-M
% 7=NOAA-N
% 8=NOAA-P
% 11=MetOp-1 ( = MetOp-B)
% 12=MetOp-A
%
% Not in use, could be used as backup if header unavailable?

% NB! MetOp-A = MetOp-2; MetOp-B = MetOp-1!
% http://database.eohandbook.com/database/missionsummary.aspx?missionID=261
% NOAA KLM User's Guide Table D-2 (page 906)

switch satid
    case 2 % NOAA-16
        % Table D.2-12 (page D-91 / page 995)
        vc = [2700.1148, 917.2289, 838.1255];
        A = [1.592459, 0.332380, 0.674623];
        B = [0.998147, 0.998522, 0.998363];
    case 4 % NOAA-15
        % Table D.1-11 (page D-19 / page 923)
        vc = [2695.9743, 925.4075, 839.8979];
        A = [1.621256, 0.337810, 0.304558];
        B = [0.998015, 0.998719, 0.999024];
    case 6 % NOAA-17
        % Table D.3-7 (page D-117 / page 1021)
        vc = [2669.3554, 926.2947, 839.8246];
        A = [1.702380, 0.271682, 0.309180];
        B = [0.997378, 0.998794, 0.999012];
    case 7 % NOAA-18
        % Table D.4-7 (page D-183 / page 1087)
        vc = [2659.7952, 928.1460, 833.232];
        A = [1.698704, 0.436645, 0.253179];
        B = [0.996960, 0.998607, 0.999057];
    case 8 % NOAA-19
        % Table D.6-7 (page D-785 / page 1689)
        vc = [2670.0, 928.9, 831.9];
        A = [1.67396, 0.53959, 0.36064];
        B = [0.997364, 0.998534, 0.998913];
%    case 11 % MetOp-1 ??
    case 12 % MetOp-A
        % Table D.5-7 (page D-492 / page 1396)
        vc = [2687.0, 927.2, 837.7];
        A = [2.06699, 0.55126, 0.34716];
        B = [0.996577, 0.998509, 0.998947];
    otherwise
        error(['atmlab:', mfilename, ':unknownid'], ...
            'Unknown satellite id: %d', id);
end
end
