tic
%%%%%%%%%%%%%%%%%%%%%%% WOA Parameters

IterWOA=100;
PopWOA=50;
         
NumVar=model.K*model.D;
VarMin=eps*ones(1,model.K*model.D);
VarMax=(model.F+model.N)*ones(1,model.K*model.D);
aa=find(reshape(DC,1,model.K*model.D)==1);
VarMin(aa)=VarMin(aa)+model.F;

cst=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%% initial population %%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:PopWOA
    
    pop(i).SOL=VarMin+rand(1,NumVar).*(VarMax-VarMin);

    [pop(i).Cost,pop(i).Penalty]=CostFunction_WOA(model,pop(i).SOL);
    
end

cost=zeros(1,PopWOA);
for i=1:PopWOA
    cost(i)=pop(i).Cost;
end

%%%%%%%%%%%%%%%%%%%%%%%% Sort Population 

[val,ind]=sort(cost);

pop=pop(ind);

Solution=pop(1);

mean_cost=mean(cost);

cst=Solution.Cost;

disp(['WOA Phase: ' 'It = ' num2str(0) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 
FF=randperm(F);
FF=FF(1:fix(F/4));

%%%%%%%%%%%%%%%%%%%%% Begining the main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n=1:IterWOA
    
    %%%%%%%%%%%%%%%%%%%% Population Updating 
    
    popnew=Solution;

    for k=2:PopWOA
        
        popnew(k).SOL=UpdateSolutionWOA(pop(k).SOL,Solution.SOL,pop(randi(PopWOA)).SOL,n,IterWOA,VarMin,VarMax);
                
    end


    %%%%%%%%%%%%%%%%%%%% Replacement 

    pop=popnew;
    
    %%%%%%%%%%%%%%%%%%%% Cost Function

    for i=1:PopWOA

        [pop(i).Cost,pop(i).Penalty]=CostFunction_WOA(model,pop(i).SOL);

    end
    
    cost=zeros(1,PopWOA);
    for i=1:PopWOA
        cost(i)=pop(i).Cost;
    end

    %%%%%%%%%%%%%%%%%%%% Sort Population 

    [val,ind]=sort(cost);

    pop=pop(ind);

    Solution=pop(1);

    mean_cost=[mean_cost mean(cost)];

    cst=[cst Solution.Cost];

    disp(['WOA Phase: ' 'It = ' num2str(n) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 

end

SOL=Solution.SOL;

PLC=reshape(ceil(SOL),K,D);

a=find(PLC>F);
b=find(PLC<=F);
DataAllocate_Layer(a)=1;
DataAllocate_Layer(b)=2;

DataAllocate_CloudNode=zeros(K,D);
DataAllocate_FogNodes2=zeros(K,D);

DataAllocate_CloudNode(a)=PLC(a)-F;

DataAllocate_FogNodes2(b)=PLC(b);

DataAllocate_FogNodes=zeros(K,D,F);
for k=1:K
    for d=1:D
        if DataAllocate_Layer(k,d)==2
            f=DataAllocate_FogNodes2(k,d);
            DataAllocate_FogNodes(k,d,f)=1;
        end
    end
end

for k=1:K
    m=Pk_FD(k,t);
    for d=1:D
       if DataAllocate_Layer(k,d)==1
           Selected_Cloud=DataAllocate_CloudNode(k,d);
           C_CPU_Usage(t,Selected_Cloud)=C_CPU_Usage(t,Selected_Cloud)+I_CPU(k,d);
           C_RAM_Usage(t,Selected_Cloud)=C_RAM_Usage(t,Selected_Cloud)+I_RAM(k,d);
           C_DISK_Usage(t,Selected_Cloud)=C_DISK_Usage(t,Selected_Cloud)+I_DISK(k,d);
           C_POWER_Usage(t,Selected_Cloud)=C_POWER_Usage(t,Selected_Cloud)+I_Size(k,d)*C_POWER(Selected_Cloud);
           E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
       else
            Selected_Fogs=[DataAllocate_FogNodes2(k,d) randi(F) FF(randi(length(FF)))];
            F_CPU_Usage(t,Selected_Fogs)=F_CPU_Usage(t,Selected_Fogs)+I_CPU(k,d);
            F_RAM_Usage(t,Selected_Fogs)=F_RAM_Usage(t,Selected_Fogs)+I_RAM(k,d);
            F_DISK_Usage(t,Selected_Fogs)=F_DISK_Usage(t,Selected_Fogs)+I_DISK(k,d);
            F_POWER_Usage(t,Selected_Fogs)=F_POWER_Usage(t,Selected_Fogs)+I_Size(k,d)*F_POWER(Selected_Fogs);
            E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
       end
    end
end

ResponseTime_Eachperiod=toc;
