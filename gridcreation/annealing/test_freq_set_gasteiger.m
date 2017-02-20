% TEST_FREQ_SET_gasteiger
%
% Test a frequency selection and use the error definition by Gasteiger 2014.
%
% FORMAT e = test_freq_set_gasteiger(s, y_ref, H, y_mono, H_ref, use_rel_error)
%
% OUT e = Gasteiger error of this selection, compared to reference
%
% IN  s       frequency set (type logical, dimension must match H)
%     y_ref   reference Tbs, result of H*y_mono
%     H       Weight matrix
%     y_mono  a batch of monochromatic Tbs (dimension must match
%             y_ref and w)
%     H_ref   sensor reponse of selected frequencies s. Dim: 1 x number of
%             chosen frequencies. It is NOT the weight matrix!
%             H needs to be normalized by its maximum value. 
%     use_rel_error Flag: If true then use relative error instead
%                   of absolute error.

function e = test_freq_set_gasteiger(s, y_ref, H, y_mono, H_ref, use_rel_error)

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
% correct weights, calculated by linear regression. (And in fact
% H is also explicitly normalized to one.)

y_mono_red = y_mono(s,:);

y_test = H_red * y_mono_red;

if (use_rel_error)
%  disp('Using relative error!')
  d = (y_test - y_ref)./y_ref;  
else
%  disp('Using absolute error!')
  d = y_test - y_ref;  
end

%            Gasteiger 2014 formula
e = rms(d) * full(1 + sqrt(1/sum(s) * sum((H_red./H_ref).^2)) );
