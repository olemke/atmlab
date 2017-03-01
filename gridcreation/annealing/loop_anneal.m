
% LOOP_ANNEAL Loop annealing algorithm until desired accuracy
% reached
%
% This is a higher level function, that uses the lower level
% function find_best_freq_set_anneal. 
% Call this function directly instead of apply_annealing. 
%
% It starts by calling find_best_freq_set_anneal with n_start
% frequencies and storing the result. Then it calles it over again
% with one frequency more, and so on until the desired accuracy is
% reached.
%
% FORMAT R = loop_anneal(H, y_mono_array, n_start, n_incr, acc, C, bf_below)
%
% OUT R       An array of structures. Each structure has elements sb, Wb,
%             eb, h, which correspond to the output arguments of
%             find_best_freq_set_anneal.
% IN  
%     H       H matrix -> sensor_reponse variable in arts.  
%     y_mono_array  monochromatic beam radiances/brightness temperatures 
%     n_start The starting number of frequencies. (You should take
%             at least one per channel.)
%     n_incr  By how much to increment n in each iteration.
%     acc     The desired accuracy, at which the looping is
%             stopped. This is the RMS error in the solution, as
%             returned by find_best_freq_set_anneal in eb.
%     C       Parameters of find_best_freq_set_anneal. 
%     bf_below optional integer use brute force approach (= calculation all
%             rms with equal weights for all node combinations in channel)
%             under this number. Default: 1 (no brute force approach)
%             possible values: 1, 2

% 2008-09-25 Created by Stefan Buehler. 
% 2017-02-20 Modified by Mareike Burba. Added bf_below functionality, 
%            and moved the reshaping of y_mono_array from apply_annealing
%            to this function such that apply_annealing is not needed any more. 
%            Commented are some lines which hardcode a limit of 10 frequencies
%            to be selected per channel, this was helpful to apply the simulated
%            annealing to IASI. 
%            However one may think about another way to avoid that the algorithm
%            tries more and more frequencies and the error is not decreasing. 

function R = loop_anneal(H, y_mono_array, n_start, n_incr, acc, C, bf_below)


% Check input 
if nargin < 6
    C = struct();   % will be filled with default in find_best_freq_anneal_rowWise
    bf_below = 1;
elseif nargin <7
    bf_below = 1;
elseif nargin ==7
    if (~ismember(bf_below, [1,2])) % currently allowed values for bf_below. 
        warning('brute_force_below %d is not supported. Set to %d instead. ',...
            bf_below, 2)
        bf_below = 2;
    end
end

[y_mono, nlos] = checkDimensions(y_mono_array, H);    % reformat y_mono_array


disp('****************************************')
disp(sprintf('Starting with n = %d.', n_start))

go_on = true;
i = 1;
n = n_start;
while go_on
    if (bf_below > n)
        switch n 
            case 1
                [sb, Wb, eb, h] = bruteForce_1( y_mono, C, H );
            otherwise
                [sb, Wb, eb, h] = find_best_freq_set_anneal_rowWise...
                    (H, y_mono, n, C);
        end
    else
        [sb, Wb, eb, h] = find_best_freq_set_anneal_rowWise...
            (H, y_mono, n, C);
    end
   
  R(i).sb = sb;
  R(i).Wb = Wb;
  R(i).eb = eb;
  R(i).h  = h;
  
  disp('****************************************')

  if nargin >= 6
     % Control parameter C is provided!
     if (C.use_rel_error)
       disp(sprintf('n = %d, acc = %g [fractional]', n, eb))
     else
       disp(sprintf('n = %d, acc = %g K', n, eb))
     end
   end

  if eb<=acc
    go_on = false;
  else
    i = i+1;
    n = n+n_incr;
    
    %%%%%% ATTENTION HARD CODED LIMIT 08.11.2016 MFB %%%%%%%%%%%%%%%%%%%%%%
    % you may want to limit the number of frequencies per channel if the
    % gasteiger flag is set to true. 
    % Uncomment below to limit. 
    % if n>10
    %    go_on = false;
    %    disp('I choose to stop here. number of selected frequencies is greater than 10 now')
    % end
  end
end
end





%% check the input, especially dimensions of matrices and set defaults.

function [y_mono, nlos] = checkDimensions(y_mono_array, H)

    nfreq_H = length(H);             % number of frequencies in H
    nspectra = length(y_mono_array); % number of input spectra, i.e. atmospheres
    
    nlos = length(y_mono_array{1})/nfreq_H; % number of lines of sight
    nfreq_y = length(y_mono_array{1})/nlos; % number of frequ. in y_mono_array
    
    % Do matrix dimensions agree? Is nlos an integer? 
    if ((nfreq_H ~= nfreq_y) || (mod(nlos,1)~=0))
        error('Gridsize of ''H'' and spectra do not agree, check input');
    end
    
    % Reformat spectra
    y_mono = cell2mat(y_mono_array);
    y_mono = reshape(y_mono, nfreq_y, nlos* nspectra);
    
end







%% apply brute force approach for one node in the actual channel. 

function [sb, Wb, eb, h] = bruteForce_1( irr_noBackend, C, H)

    irr_wiBackend = H * irr_noBackend;

    if (C.use_rel_error)
        d = (repmat(irr_wiBackend,size(irr_noBackend,1),1) - irr_noBackend)...
            ./ repmat(irr_wiBackend,size(irr_noBackend,1),1);
    else % absolute error
        d = repmat(irr_wiBackend,size(irr_noBackend,1),1) - irr_noBackend;
    end
    
    if isfield(C, 'use_gasteiger') && (C.use_gasteiger)
        %   Gasteiger 2014 formula
        H_ref = H / max(H); % Gasteiger needs Matrix which is normalized to max value. 
        
        %   sqrt(1/[#freqs] * sum("weight of 1 channel =1"./ H_ref))
        e = rms(d, 2) .* full(1 + sqrt(1 .* (1./H_ref).^2) )';
    else
        e = rms(d, 2);
    end

    [eb, idx] = min(e);
    
    % create the annealing data structure
    sb = false(1,size(irr_noBackend,1));
    sb(1,idx) = true; 
    
    Wb = sparse(1,size(irr_noBackend,1),0);
    Wb(1, idx) = 1;
    
    h.brute_force_n_nodes = 1;
    
end

