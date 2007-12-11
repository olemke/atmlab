% GF_MERGE merge two gformat arrays
%          The output G will follow
%          the D1 definitions          
%
% OUT  G modified Gformat data
%      D Gformat definition structure
%
% IN   D1 Gformat definition structure
%      G1 Gformat data
%      D2 Gformat definition structure
%      G2 Gformat data
%      lims1 cell array of limits where
%      G should be filled with G1 data
%      lims1{1} correspond to G1.GRID1
%      lims2 analog to lims1 but 
%      corresponding to G2
%

% 2007-12-11 created by Bengt Rydberg

function [G,D]=gf_merge(D1,G1,lims1,D2,G2,lims2)

%set a counter
ng=1;

for ig1=1:length(G1)
    
    %find matching data
    ig2=min(find(strcmp(G1(ig1).NAME,{G2.NAME})));

    if ~isempty(ig2)
       %check dimensionality of data

       dim1=length(G1(ig1).DIMS);
       dim2=length(G2(ig2).DIMS);

       if dim1>3 | dim2>3
          error('the function only handle dimensions less than 4')
       end

       if length(lims1)~=dim1
          error( 'mismatch in size between G1.DIMS and lims1.') 
       end
       if length(lims2)~=dim2
          error( 'mismatch in size between G2.DIMS and lims2.') 
       end

       %check the definition of D1 and D2

       for id = 1:3

           gname1 = lower( D1.(sprintf('GRID%d_NAME',id)) );
           gname2 = lower( D2.(sprintf('GRID%d_NAME',id)) );
        
           if strncmp( gname1, 'pressure', 8 )
              dims1(1) = id;
           elseif strncmp( gname1, 'latitude', 8 )
              dims1(2) = id;
           elseif strncmp( gname1, 'longitude', 8 )
              dims1(3) = id;
           end
 
           if strncmp( gname2, 'pressure', 8 )
              dims2(1) = id;
           elseif strncmp( gname2, 'latitude', 8 )
              dims2(2) = id;
           elseif strncmp( gname2, 'longitude', 8 )
              dims2(3) = id;
           end
 
       end
         
       Lims2=lims2;
       for i=dim2+1:3
           Lims2{i}=[];
       end

       Lims1=lims1;
       for i=dim1+1:3
           Lims1{i}=[];
       end      

       if length(find(dims1==dims2))==3
          %D1 and D2 are defined in the same way
          %do nothing

       elseif length(find(dims1))~=3 | length(find(dims2))~=3
          error('uncorrect definition of D1 or D2')

       else 
          %change G2 to D1 definition

          for i=1:3
              gname=sprintf('GRID%d',dims1(i));
              grids{i}=G2(ig2).(gname);
              lims2mod{i}=Lims2{dims1(i)};
          end

          G2(ig2).GRID1=grids{1};
          G2(ig2).GRID2=grids{2};
          G2(ig2).GRID3=grids{3};
   
          for i=1:3
              gname=sprintf('GRID%d',i);
              i_len(i)=length(G2(ig2).(gname));
          end   
          i_len(find(i_len==0))=1;
   
          data=zeros(i_len);
      
          i1=find(dims1(1)==dims2);
          i2=find(dims1(2)==dims2); 
          i3=find(dims1(3)==dims2);

          for i=1:size(data,1)
           for j=1:size(data,2)
            for k=1:size(data,3)

              if i1==1
                 j1=i;
              elseif i1==2
                 j2=i;
              elseif i1==3 
                 j3=i;
              end
 
              if i2==1
                 j1=j;
              elseif i2==2
                 j2=j;
              elseif i2==3
                 j3=j;
              end 
           
              if i3==1
                 j1=k;
              elseif i3==2
                 j2=k;
              elseif i3==3 
                 j3=k;
              end 
           
              data(i,j,k)=G2(ig2).DATA(j1,j2,j3);

            end
           end
          end
          Lims2=lims2mod;
          G2(ig2).DATA=data;
       end


       %Dims1=dims1(G1(ig1).DIMS);
       %Dims2=dims2(G2(ig2).DIMS);

       %check that the specified limits do not cover the same area
    
       for i=1:3
           if ~isempty(Lims1{i}) & ~isempty(Lims2{i})
 
              if max(Lims1{i})>max(Lims2{i})
                 if max(Lims2{i})<min(Lims1{i})
                    error('lims1 and lims2 are intersecting')
                 end
              else
                 if max(Lims1{i})<min(Lims2{i})
                    error('lims1 and lims2 are intersecting')
                 end
              end
           end
       end


       %find indices inside lims and create merged grids

       for i=1:3
    
           gname=sprintf('GRID%d',i);
           dname= sprintf('GRID%d_NAME',i);   
           
           ind1{i}=find(G1(ig1).(gname)>=min(Lims1{i}) & ...
                        G1(ig1).(gname)<=max(Lims1{i}));
           ind2{i}=find(G2(ig2).(gname)>=min(Lims2{i}) & ...
                        G2(ig2).(gname)<=max(Lims2{i}));
    
           grids1{i}=G1(ig1).(gname)(ind1{i});
           grids2{i}=G2(ig2).(gname)(ind2{i});

           grids{i}=sort([ vec2col(grids1{i})' vec2col(grids2{i})']);
           if isempty(grids{i})
              grids{i}=[];
           end           

           if strcmp(D1.(dname),'Pressure')
              grids{i}=flipud(vec2col(grids{i}));
           end

           if isempty(ind1{i})
              ind1{i}=1;
              grids1{i}=[];
           end
           if isempty(ind2{i})
              ind2{i}=1;
              grids2{i}=[];
           end

       end

       Data1=G1(ig1).DATA(ind1{1},ind1{2},ind1{3});
       Data2=G2(ig2).DATA(ind2{1},ind2{2},ind2{3});

       g=[length(grids{1}) length(grids{2}) length(grids{3})];
       g(find(g==0))=1;
       Data=zeros(g);
       
       for i=1:size(Data,1)
        for j=1:size(Data,2)
         for k=1:size(Data,3)
            
          for l=1:3    
            if l==1
               m=i;
            elseif l==2
               m=j;
            else
               m=k;
            end
       
            if length(grids{l})>1
               if length(Lims1{1})==2
                  %check if the data point is inside lims1
                  if length(grids1{l})>0
                     t1(l)=max(grids1{l}(:))>=grids{l}(m) & ...
                               min(grids1{l}(:))<=grids{l}(m);
                     if t1(l)
                        %find indices
                        ind_1(l)=find(grids1{l}==grids{l}(m));
                     end
                  else
                     t1(l)=0;
                  end
               else
                  t1(l)=1;
                  ind_1(l)=1;
               end
               if length(Lims2{l})==2
                  %check if the data point is inside lims2
                  if length(grids2{l})>0
                     t2(l)=max(grids2{l}(:))>=grids{l}(m) & ...
                           min(grids2{l}(:))<=grids{l}(m);
                     if t2(l)
                        %find indices
                        ind_2(l)=find(grids2{l}==grids{l}(m));
                     end
                  end
               else
                  t2(l)=1;
                  ind_2(l)=1;
               end
            else
               t1(l)=1;
               ind_1(l)=1;
               t2(l)=1;
               ind_2(l)=1;
            end

          end
 
          if sum(t1)==3
            %the data point is inside lims1
            Data(i,j,k)=Data1(ind_1(1),ind_1(2),ind_1(3));       
          else
            %the data point is inside lims2
            Data(i,j,k)=Data2(ind_2(1),ind_2(2),ind_2(3)); 
          end
         end
        end
       end

       G(ng)=G1(ig1);
       G(ng).DIMS=1:length(find(g>1));
       G(ng).GRID1=grids{1};
       G(ng).GRID2=grids{2};
       G(ng).GRID3=grids{3};
       G(ng).SOURCE=[{G1(ig1).SOURCE},{G2(ig2).SOURCE}];
       G(ng).DATA=Data;
       ng=ng+1;
   end
end

D=D1;