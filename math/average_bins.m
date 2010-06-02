function out = average_bins(data_bins,output)
%% AVERAGE_BINS returns grid averages, sum, and numel from a cell of gridded data
% 
% IN: 1) data_bins (mandatory), cell of gridded vectors of data
%     2) output (optional), 'a_data', 's_data', or 'n_data'
%             e.g gridded  (average), (sum)   ,  or (numel)
%
%
% OUT: structure containg:
%                s_data = the sum of measurements for each grid box
%                n_data = the number of elements involved in each sum
%                a_data = s_data./n_data
%
% Note:
% - I recommend the function binning_fast.m to set up the cell from ungridded data.
% - Values less than 0 are ignored in the sum and numel per grid box.
% - Assumes that the data cell has dimensions {lat,lon}
% - Use 'output' if you only want one field (e.g. a_data, i.e field of averages)   
%
% 2010-06-02 Salomon Eliasson


% Need to look in the third dim even if there isn't one, i.e. size(data_bins,3)=1
a=size(data_bins,1);
b=size(data_bins,2);
c=size(data_bins,3);

summ = zeros(a,b,c);
n_data = zeros(a,b,c);

for oo=1:c
    for ii = 1:a
        for jj = 1:b
            bin = data_bins{ii,jj,oo};
            d = bin(bin >= 0);
            summ(ii,jj,oo) = sum(d);
            n_data(ii,jj,oo) = numel(d);
        end
    end
end

out.s_data = squeeze(sum(summ,3)); % gridded sum
out.n_data=squeeze(sum(n_data,3)); % gridded numel
out.a_data=summ./n_data;           % gridded average 

if exist('output','var')
    out = out.(output);
end