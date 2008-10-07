% TEST_FREQ_SET
%
% Test a frequency selection.
%
% FORMAT e = test_freq_set(s, y_ref, H, y_mono)
%
% OUT e = RMS error of this selection, compared to reference
%
% IN  s       frequency set (type logical, dimension must match H)
%     y_ref   reference Tbs, result of H*y_mono
%     H       Weight matrix
%     y_mono  a batch of monochromatic Tbs (dimension must match
%             y_ref and w)

function e = test_freq_set(s, y_ref, H, y_mono)

% Number of channels:
x = size(H);
nchannels = x(1);

%keyboard

H_red = H(:,s);

% Normalize correctly
%for i=1:nchannels
%  H_norm = sum(H_red(i,:));
%  H_red(i,:) = H_red(i,:) / H_norm;
%end
% We do no longer normalize, since the matrix H contains the
% correct weights, calculated by linear regression.

y_mono_red = y_mono(s,:);

y_test = H_red * y_mono_red;

d = y_test - y_ref;

e = rms(d);
