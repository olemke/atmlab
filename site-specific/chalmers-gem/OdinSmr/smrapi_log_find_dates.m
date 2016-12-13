% SMRAPI_LOG_FIND_DATES   Finds log data for a set of dates

function SMR = smrapi_log_find_dates(API,freqmode,dates)


if ischar(dates)
  error( '*dates* is not allow to be a string (use a cell string instead).' );
end


% We obtain final URLs by using date overview 
%
SMR = [];
%
for d = 1 : length(dates)
  url = sprintf( 'http://%s/rest_api/%s/freqmode_info/%s',...
                 API.webapi_url, API.l1_version, smrapi_time(dates,d) );

  [O,e] = smrapi_call( API, url );

  if ~isempty(O)
  
    if ~isempty(e)
      disp(e)
      
    else

      ihit = find( [O.FreqMode] == freqmode );
  
      for i = ihit
        
        [W,e] = smrapi_call( API, O(i).URL ); 
        
        if ~isempty(e)
          disp(e)
        else

          for j = 1 : length(W)
            if isempty(SMR)
              SMR.Log = W(j);
            else
              SMR(end+1).Log = W(j);
            end
          end
        end
      end  
    end
  end
end