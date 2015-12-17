% load_database_wfilter  A function to load chunks of a ISMAR database and to 
%                        join the chunks. 
%
%   Chunks of a ISMAR database base are loaded and and are joined. 
%   Additionally there is the possibility to filter the data, so that only
%   data that passes the filter will be joined.
%
% FORMAT data=load_database_wfilter(dbase_folder,list_of_datachunks,filters)
%
% OUT   data,               the chunks of the database combined to one
%                           structure.
% IN    dbase_folder        path to the folder where the chunks of the database
%                           are saved.
%       list_of_datachunks  a structure with the list of the chunks which will 
%                           be loaded. If set to empty, then all inside
%                           dbase_folder will be loaded.
%       filters             a structure with varying numbers of fields. the
%                           fieldnames have to be the ones from the database.
%                           each field must consist of a 1x2 vector with first
%                           entry being the minimum and the second entry the
%                           maximum. A field can also be 1x1 with a logical
%                           like a flg, if a flag is set within database.
%                           Works with the fields:
%                               case_index,
%                               lat, lon,
%                               pressure,
%                               surface_altitude,
%                               surface_temperature,
%                               time
%

%   2015-12-17  Manfred Brath


function data=load_database_wfilter(dbase_folder,list_of_datachunks,filters)


if nargin<3
    filters=struct();
end


if nargin<2 || isempty(list_of_datachunks)
   list_of_datachunks=dir([dbase_folder,'/*.mat']); 
end

disp('Filters:')
disp(filters)
disp('-------------------------------------------------------------------')
disp('  ')

%set flag to zero
flag=0;

disp('...loading data.')

%loop over list
for i=1:length(list_of_datachunks)

    %load a chunk of data
    main_temp=load([dbase_folder,list_of_datachunks(i,1).name]); 
    
    logic_temp=~structfun(@isempty,filters);
    
    %filter data
    if sum(logic_temp)>0
        logic_array=false(size(main_temp.surface_temperature,1),sum(logic_temp));
        filter_fields=fieldnames(filters); 

        index=1;
        for ii=1:length(filter_fields)

            if ~isempty(filters.(filter_fields{ii})) && length(filters.(filter_fields{ii}))==2

                logic_lower=filters.(filter_fields{ii})(1,1)<=main_temp.(filter_fields{ii});
                logic_upper=main_temp.(filter_fields{ii})<=filters.(filter_fields{ii})(1,2);

                logic_array(:,index)=logic_lower & logic_upper;
                index=index+1;

            elseif ~isempty(filters.(filter_fields{ii})) && length(filters.(filter_fields{ii}))==1

                logic_one=filters.(filter_fields{ii})==main_temp.(filter_fields{ii});
                logic_array(:,index)=logic_one;
                index=index+1;

            else
                continue
            end

        end

        logic_filter=logical(prod(logic_array,2));  
    else
        logic_filter=true(size(main_temp.surface_temperature,1),1);
    end
        
    disp(['i = ',num2str(i),' => ',list_of_datachunks(i,1).name])
        
    
    if flag==0
        fields = fieldnames(main_temp)';    
        data=main_temp;
        flag=1;
        
        for j=1:length(fields)
            
            %get size
            data_temp=data.(fields{1,j});
            qtemp=size(data_temp);
            
            %check size
            chnk_length=length(main_temp.case_index);
            
            
            if qtemp(1)~=chnk_length
                continue
            end
            
            data.(fields{1,j})=data_temp(logic_filter,:,:,:,:);           
            
        end
        
    else
        for j=1:length(fields)
        
            %get from next chunk for appending
            data_temp=main_temp.(fields{1,j});
            qtemp=size(data_temp);
            
            %check size
            chnk_length=length(main_temp.case_index);
            
            
            if qtemp(1)~=chnk_length
                continue
            end
            
            %the data, where to append
            data_main=data.(fields{1,j});
            qmain=size(data_main);
            

            data_main(qmain(1)+1:qmain(1)+sum(logic_filter),:,:,:,:)=data_temp(logic_filter,:,:,:,:);
                
            
            %store it in structure
            data.(fields{1,j})=data_main;
        end            
    end
end

data.dbase_folder=dbase_folder;
data.list_of_datachunks=list_of_datachunks;


end
