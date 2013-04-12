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

limit = 500; % while still in progress
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
     'avh_telem_id'}, ...
    limit);

S.Tb = calibrate_avhrr(data_head, data_line);

end

function Tb = calibrate_avhrr(data_head, data_line)

% calibration according to NOAA KLM User's Guide, section 7.1.2.3

% extract calibration coefficients

limit = 500; % while still in progress

a0 = [data_line.avh_calir_o3b1; ...
      data_line.avh_calir_o41; ...
      data_line.avh_calir_o51];
a1 = [data_line.avh_calir_o3b2; ...
       data_line.avh_calir_o42; ...
       data_line.avh_calir_o52];
a2 = [data_line.avh_calir_o3b3; ...
       data_line.avh_calir_o43; ...
       data_line.avh_calir_o53];

% bit0 in avh_telem_id 1st word specifies 3A or 3B:
% 0 means 3B, 1 means 3A
chan3_is_3a = bitand(par([data_line.avh_telem_id], 1, ':'), 1);

% FIXME: make this call vectorised
%ce = par(unpack_bip(data_line(1).avh_video), ':', 4);
X = arrayfun(@(i) unpack_bip(data_line(i).avh_video), 1:limit, 'UniformOutput', false);
ce = reshape(vertcat(X{:}), [409, limit, 5]);

% pre-allocate calibrated radiance array
Ne = zeros(size(ce), 'single');

%% calibrate thermal channels
%
% Equation (7.1.2.3-1):
%
% Ne = a0 + a1*ce + a2*ce^2;

% calibrate channel 3B

Ne(:, ~chan3_is_3a, 3) = ...
    bsxfun(@plus, ...
           a0(1, :), ...
           bsxfun(@plus, ...
                  bsxfun(@times, a1(1, :), single(ce(:, :, 3))), ...
                  bsxfun(@times, a2(1, :), single(ce(:, :, 3)).^2)));

% calibrate the always-thermal channels
%

term2 = bsxfun(@times, shiftdim(a1(2:3, :).', -1), single(ce(:, :, 4:5)));
term3 = bsxfun(@times, shiftdim(a2(2:3, :).', -1), single(ce(:, :, 4:5)).^2);
Ne(:, :, 4:5) = bsxfun(@plus, ...
                       shiftdim(a0(2:3, :).', -1), ...
                       bsxfun(@plus, term2, term3));


% in mW/(m2-sr-cm-1) 

%% Convert radiances to brightness temperatures
%
% equation (7.1.2.4-8, -9)
%
% Te = c2*vc/log(1 + c1*v^3/Ne)

vc = [data_head.avh_h_radtempcnv3bc, data_head.avh_h_radtempcnv4c, data_head.avh_h_radtempcnv5c];
b1 = [data_head.avh_h_radtempcnv3b1, data_head.avh_h_radtempcnv41, data_head.avh_h_radtempcnv51];
b2 = [data_head.avh_h_radtempcnv3b2, data_head.avh_h_radtempcnv42, data_head.avh_h_radtempcnv42];
%[vc_, A_, B_] = avhrr_coef_therm2rad(data_head.avh_h_satid);

% Coefficients from word-document attached by Nigel Atkinson  
c1 = 1.191e-5; % mW m^-2 sr^-1 cm^4
c2 = 1.439; % K cm

Tep = zeros(size(Ne), 'single');
Tb = zeros(size(Ne), 'single');

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

Tb(:, ~chan3_is_3a, 3) = b1(1) + b2(1) * Tep(:, ~chan3_is_3a, 3);

Tb(:, :, 4:5) = bsxfun(@plus, ...
                       reshape(b1(2:3), [1, 1, 2]), ...
                       bsxfun(@times, ...
                              reshape(b2(2:3), [1, 1, 2]), ...
                              Tep(:, :, 4:5)));

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
