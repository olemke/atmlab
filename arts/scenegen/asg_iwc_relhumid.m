% ASG_IWC_RELHUMID modify the water vapour field in Gcs
%
% The function reguires that water vapour and
% temperatures are fields in Gcs, and iwc in
% Gdbz. The water vapor field is modified if
% the iwc is above zero in a given position. 
% A stochastic relative humidity field centered
% around 100% +-10% rhi is computed, and weighted with 
% the original relative humidity field (computed from 
% temperature and water vapour field).
%
% The "returned" relative humdity field is then
% rhi=w*rhi(stochastic)+(1-w)*rhi(original)
% where w=1-exp(-100*iwc)
%
% The relative humdity field is not returned,
% but the water vapour field in Gcs is modified.
%
% The grids of Q will determine the grids of
% of the water vapor data in the returned Gcs  
%
% OUT Gcs modified Gformat array
%
% IN  D    gformat definition structure
%     Gcs  gformat atmospheric data
%     Gdbz gformat cloud data
%     Q    Qarts setting structure   

% 2007-12-12 created by Bengt Rydberg

function Gcs=asg_iwc_relhumid(D,Gcs,Gdbz,Q)


%find indices
water_ind=min(find(strncmp(lower({Gcs.NAME}),'water',5)));
tem_ind=min(find(strncmp(lower({Gcs.NAME}),'temperature',11)));
iwc_ind=min(find(strncmp(lower({Gdbz.NAME}),'iwc',3)));

if isempty(water_ind)
   error('water vapour must be included in Gcs')
end

if isempty(tem_ind)
   error('Temperature must be included in Gcs')
end

if isempty(iwc_ind)
   error('iwc must be included in Gdbz')
end

if ~any([ length( find( ( [length(Gcs(water_ind).DIMS)==3,...
                      length(Gcs(tem_ind).DIMS)==3,...
                      length(Gdbz(iwc_ind).DIMS)==3 ] ) ) )==3,...
     
          length( find( ( [length(Gcs(water_ind).DIMS)==2,...
                      length(Gcs(tem_ind).DIMS)==2,...
                      length(Gdbz(iwc_ind).DIMS)==2 ] ) ) )==3,...
  
          length( find( ( [length(Gcs(water_ind).DIMS)==1,...
                      length(Gcs(tem_ind).DIMS)==1,...
                      length(Gdbz(iwc_ind).DIMS)==1 ] ) ) )==3])

   error('all data has not the same dimensions')

end

dim=length(Gcs(water_ind).DIMS);


%reduce the resolution of Gcs in order to be able
%to make perturbation while calling asg_rndmz
%without memory problem

Q1          = Q;
Q1.P_GRID         = 1000/16e3;
Q1.LAT_GRID = Gdbz(iwc_ind).GRID2;
Q1.LON_GRID = Gdbz(iwc_ind).GRID3;
Q2 = asg_atmgrids( D, Gdbz(iwc_ind), Q1 );
Gcs1        = asg_regrid( D, Gcs([water_ind,tem_ind]), Q2 );

%create a random relative humidity field
%
Grhi=Gcs1(1);

%set randomize parameters
if dim<4
   RND.FORMAT    = 'param'; 
   RND.SEPERABLE = 1;
   RND.CCO       = 0.01;           % Cut-off for correlation values 
   RND.TYPE      = 'rel';          % Relative disturbances as default
   RND.DATALIMS  = [0];            % Do not allow negative values
   %
   RND.SI        = 0.1;            % 10 % std. dev. as default
   %
   RND.CFUN1     = 'exp';              % Exp. correlation function for p-dim.
   RND.CL1       = [0.15 0.3 0.3]';    % Corr. length varies with altitude
   RND.CL1_GRID1 = [1100e2 10e2 1e-3];
end

if dim>1    
   %
   RND.CFUN2     = 'lin';            % Linear correlation function for lat-dim.
   RND.CL2       = 1.5;              % Corr. length 1.5 deg everywhere
   %
end

if dim>2
   RND.CFUN3     = 'lin';            % Linear correlation function for lat-dim.
   RND.CL3       = 1.5;              % Corr. length 1.5 deg everywhere
end

Grhi.RNDMZ=RND;

%set the field to be 1==100%rhi
Grhi.DATA=ones(size(Grhi.DATA));

%perturb the field
Grhi = asg_rndmz( D, Grhi );


G2        = asg_regrid( D, [Gdbz(iwc_ind),Gcs([water_ind,tem_ind]),...
                        Grhi], Q );

%Equilibrium water vapor pressure over ice
ei = e_eq_ice(G2(3).DATA);

%create a pressure matrix
P=zeros(size(G2(3).DATA));
if dim==1
   P=G2(3).GRID1;
end

if dim>1
   p=vec2col(G2(3).GRID1)*ones(1,length(G2(3).GRID2));
   if dim==2
      P=p;
   else
      for i=1:length(G2(3).GRID3)
          P(:,:,i)=p;
      end
   end
end

%relative humdity 
rhi=G2(2).DATA.*P./ei;

%weights
%an iwc of 0.1 will give 100% weight to the stochastic value
%0.01 63%
%0.001 10%
%0.0001 1%
w=1-exp(-100*G2(1).DATA);

%apply the weights
rhi=w.*G2(4).DATA+(1-w).*rhi;

%transform back to vmr
Gcs(water_ind).DATA=rhi.*ei./P;


