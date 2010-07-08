function out = average_bins2(data_bins,output)
%% AVERAGE_BINS2 returns grid averages, sum, and numel from a cell of gridded data
% 
% IN: 1) data_bins (mandatory), cell of gridded vectors of data
%     2) output (optional), 'a_data', 's_data', or 'n_data'
%             e.g gridded  (average), (sum)   ,  or (numel)
%
%
% OUT: structure containg:
%                s_data = the sum of measurements for each grid box
%                n_data = the number of elements involved in each sum
%                m_data = the median of measurements for each grid box
%                d_data = the standard deviation of measurements for each
%                         grid box
%                a_data = s_data./n_data
%
% Note:
% - I recommend the function binning_fast.m to set up the cell from ungridded data.
% - Values less than 0 are ignored in the sum and numel per grid box.
% - Assumes that the data cell has dimensions {lat,lon}
% - Use 'output' if you only want one field (e.g. a_data, i.e field of averages)   
%
% 2010-06-02 Salomon Eliasson
% 2010-07-08 Oliver Lemke (temporary duplicate of original function)

a=size(data_bins,1);
b=size(data_bins,2);

out.s_data = zeros(a,b);
out.n_data = zeros(a,b);
out.m_data = zeros(a,b);
out.d_data = zeros(a,b);

for ii = 1:a
    for jj = 1:b
        bin = data_bins{ii,jj};
        d = bin(bin >= 0);
        out.s_data(ii,jj) = sum(d);
        out.n_data(ii,jj) = numel(d);
        out.m_data(ii,jj) = median(d);
        out.d_data(ii,jj) = std(d);
    end
end

out.a_data=out.s_data./out.n_data;           % gridded average 

if exist('output','var')
    out = out.(output);
end