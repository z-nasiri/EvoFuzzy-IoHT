tic
%%%%%%%%%%%%%%%%%%%%%%% GA Parameters

IterGA=100;
PopGA=50;
NumR=5;
NumC=15;
NumM=30;
NumMuteParam_max=1;
NumMuteParam_min=1;
Roulette_Power=1;

NumVar=model.K*model.D;
VarMin=eps*ones(1,model.K*model.D);
VarMax=(model.F+model.N)*ones(1,model.K*model.D);
aa=find(reshape(DC,1,model.K*model.D)==1);
VarMin(aa)=VarMin(aa)+model.F;

cst=[];
mean_cost=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%% initial population %%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:PopGA
    
    pop(i).SOL=VarMin+rand(1,NumVar).*(VarMax-VarMin);

    [pop(i).Cost,pop(i).Penalty]=CostFunction_GSA(model,pop(i).SOL);
    
end

cost=zeros(1,PopGA);
for i=1:PopGA
    cost(i)=pop(i).Cost;
end

%%%%%%%%%%%%%%%%%%%%%%%% Sort Population 

[val,ind]=sort(cost);

pop=pop(ind);

Solution=pop(1);

mean_cost=mean(cost);

cst=Solution.Cost;

disp(['GA Phase: ' 'It = ' num2str(0) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 

FF=randperm(F);
FF=FF(1:fix(F/2));

%%%%%%%%%%%%%%%%%%%%% Begining the main loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n=1:IterGA

    %%%%%%%%%%%%%%%%%%%% Population Updating %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%% Recombination
    
    popnew(1:NumR)=pop(1:NumR);

    PP=(1./cost);
    PP=(PP-min(PP))/(max(PP)-min(PP));
    
    %%%%%%%%%%%%%%%%%%%% Crossover

    for k=NumR+1:NumR+NumC

        P=PP.^Roulette_Power;
        
        par1=RouletteWheelSelection(P);
        P(par1)=0;
        par2=RouletteWheelSelection(P);

        popnew(k).SOL=Crossover(pop(par1).SOL,pop(par2).SOL);

    end

    %%%%%%%%%%%%%%%%%%%% Mutation

    NumMuteParam=round(NumMuteParam_max-(NumMuteParam_max-NumMuteParam_min)*n/IterGA);
    
    for k=NumR+NumC+1:PopGA

        P=PP.^Roulette_Power;

        par=RouletteWheelSelection(P);

        popnew(k).SOL=Mutation(pop(par).SOL,VarMin,VarMax,NumMuteParam);

    end

    %%%%%%%%%%%%%%%%%%%% Replacement 

    pop=popnew;
        
    %%%%%%%%%%%%%%%%%%%% Cost Function 

    for i=1:PopGA

        [pop(i).Cost,pop(i).Penalty]=CostFunction_GSA(model,pop(i).SOL);
        
    end
    
    cost=zeros(1,PopGA);
    for i=1:PopGA
        cost(i)=pop(i).Cost;
    end

    %%%%%%%%%%%%%%%%%%%% Sort Population 

    [val,ind]=sort(cost);

    pop=pop(ind);

    Solution=pop(1);

    mean_cost=[mean_cost mean(cost)];

    cst=[cst Solution.Cost];

    disp(['GA Phase: ' 'It = ' num2str(n) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%% SA Phase %%%%%%%%%%%%%%%%%%%%%%%%%%

T_initial=30;
T_final=0;
IterSA=5000;

Sol_old=Solution.SOL;
OF_old=Solution.Cost;
BestSol=Solution.SOL;
BestOF=Solution.Cost;

%%%%%%%%%%%%%%%%%%%%%%%% Begining the Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%

for nn=1:IterSA   
    
%%%%%%%% neighborhood Search

Sol_new=Mutation(Sol_old,VarMin,VarMax,NumMuteParam);
    
%%%%%%%% Cost Function
    
[OF_new,~]=CostFunction_GSA(model,Sol_new);

%%%%%%%% Update Best Solution

if OF_new<BestOF
    BestSol=Sol_new;
    BestOF=OF_new;
end

%%%%%%%% Acceptance Rule Checking

Tsa=T_initial+(T_final-T_initial)*nn/IterSA;

if OF_new<OF_old
    Sol_old=Sol_new;
    OF_old=OF_new;
else
    DeltaOF=OF_new-OF_old;
    Pa=exp(-DeltaOF/Tsa);
    if rand<Pa
        Sol_old=Sol_new;
        OF_old=OF_new;
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot Result %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if rem(nn,PopGA)==0
    disp(['SA Phase: ' 'It = ' num2str(nn) ', ObjFun =  ' num2str(BestOF)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

SOL=BestSol;

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
            Selected_Fogs=[DataAllocate_FogNodes2(k,d) randi(F) randi(F) FF(randi(length(FF)))];
            F_CPU_Usage(t,Selected_Fogs)=F_CPU_Usage(t,Selected_Fogs)+I_CPU(k,d);
            F_RAM_Usage(t,Selected_Fogs)=F_RAM_Usage(t,Selected_Fogs)+I_RAM(k,d);
            F_DISK_Usage(t,Selected_Fogs)=F_DISK_Usage(t,Selected_Fogs)+I_DISK(k,d);
            F_POWER_Usage(t,Selected_Fogs)=F_POWER_Usage(t,Selected_Fogs)+I_Size(k,d)*F_POWER(Selected_Fogs);
            E_POWER_Usage(t)=E_POWER_Usage(t)+I_Size(k,d)*E_POWER;
       end
    end
end

ResponseTime_Eachperiod=toc;
