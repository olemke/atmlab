% SMR_GET_SUB_FIELD   Extraction of data in sub-fields
%
%    As the SMR data are stored in structures having several levels, it is
%    not always possible to extract the data using standard Matlab syntax.
%    This function provides help. 
%
%    The function can compile data from SMR arrays as long as the basic data
%    is of numeric type with a constant size. For example, all spectra can 
%    obtained as:
%       Tb = smr_get_subfield( SMR, 'L1b.Spectrum' );
%
% FORMAT   D = smr_get_subfield( SMR, datapos )
%
% OUT   D         Extracted data. The leading size is the same as length(SMR), 
%                 and the following ones are decided by the basic data.
%  IN   SMR       SMR data.
%       datapos   Data position, a string.

% 2016-12-13   Patrick Eriksson


function D = smr_get_subfield( SMR, datapos )


% Matlab can always not handle SMR.(datapos) as datapos can contain several
% levels and we need to go down one level at the time
%
subfields = textscan( datapos, '%s', 'Delimiter', '.' );


n = length( SMR );


for i = 1 : n

  D1 = SMR(i).(subfields{1}{1});
    
  for j = 2 : length(subfields{1})
    D1 = D1.(subfields{1}{j});
  end

   if i == 1
      D = zeros( [n, size(D1) ] );
   end

   D(i,:,:,:,:) = D1;
end    
