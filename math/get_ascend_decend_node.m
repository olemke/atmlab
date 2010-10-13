function ascend = get_ascend_decend_node(latitude)
%% GETNODE
% Purpose: Create a logical array, the same size as latitude -matrix that
% indicates whether a pixel is in the ascending mode containing whether a pixel is ascending or not.
%
% In: Latitude (ungridded)
% OUt: ascend (logical). true for ascend, false for descend.
% 
% Note: 1) This is for ungridded data. 
%       2) If there is only one latitude value. ascend(i) will remain false. not
%          nice but I suppose the error is negligable.
%
% $Id$



lat=latitude(:,round(end/2)); %always a vector
ascend=false(size(latitude));

if length(lat)>1
    % this line checks if the next latitude is higher or not (using indexing).
    % the second last and last scanlines are set to be equally ascending or
    % descending to their neighbouring point
    
    i = 1:length(lat)-1;
    ascend(i,:)=repmat(lat(i)-lat(i+1) < 0,1,size(ascend,2));
    ascend(end,:) = ascend(end-1,:);
end