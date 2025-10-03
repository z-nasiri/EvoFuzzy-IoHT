clc
clear all
close all
warning off

N=10;                   % Number of Cloud Data Centers: Max: 20
M=10;                   % Number of Fog Domains; Max: 20
K=500;                  % Number of IoHT Devices: Max: 3000
T=100;                  % Number of Time Priods (Days): Max: 360
P_Failure_Fogs=0.02;    % Probability of Failure for each Fog Node

%%% Load Data

DataName='DataFolder/FullData.mat';
load(DataName)

%%% Revise Data

model=DataSelection(model,N,M,K,T,P_Failure_Fogs);

%%%%%%%%%%%%%%%%%%%%%%% GA Parameters

IterGA=100;
PopGA=50;
NumR=5;
NumC=30;
NumM=15;
NumMuteParam_max=3;
NumMuteParam_min=1;
Roulette_Power=2;

NumVar=30;
VarMin=[eps*ones(1,6) zeros(1,10) 0.5*ones(1,10) eps*ones(1,4)];
VarMax=[5*ones(1,2) 15*ones(1,4) ones(1,10) 3*ones(1,10) 2 3 2 3];


obj=[];
cst=[];
pen=[];
mean_cost=[];
mean_obj=[];
mean_pen=[];

%%%%%%%%%%%%%%%%%%%%%%% Objective Function Parameters

Wcf(1)=0.5;             % Weight of Mean Response Time
Wcf(2)=0.2;             % Weight of Load Balancing in Cloud Data Centers (STD of loads)
Wcf(3)=0.2;             % Weight of Load Balancing in Fog Nodes (STD of loads)
Wcf(4)=.1;              % Weight of Power Consumption
MaxFailureRate=0.001;   % Maximum Allowable Failure Rate (Failure/Request)
MaxDelayRate=0.005;     % Maximum Allowable Delay Rate   (s/Request)

%%%%%%%%%%%%%%%%%%%%%%%%%%% initial population %%%%%%%%%%%%%%%%%%%%%%%%%%%%

CFD.Algorithm=2;
CFD.Wcf=Wcf;
CFD.MaxFailureRate=MaxFailureRate;
CFD.MaxDelayRate=MaxDelayRate;

for i=1:PopGA
    
    pop(i).SOL=VarMin+rand(1,NumVar).*(VarMax-VarMin);

    [pop(i).ObjFun,pop(i).Penalty,pop(i).Cost,pop(i).Subcost]=CostFunction(model,pop(i).SOL,CFD);
    
end

cost=zeros(1,PopGA);
objmat=zeros(1,PopGA);
penmat=zeros(1,PopGA);
for i=1:PopGA
    cost(i)=pop(i).Cost;
    objmat(i)=pop(i).ObjFun;
    penmat(i)=pop(i).Penalty;
end

%%%%%%%%%%%%%%%%%%%%%%%% Sort Population 

[val,ind]=sort(cost);

pop=pop(ind);

Solution=pop(1);
Result=pop(1).Subcost;

mean_cost=mean(cost);
mean_obj=mean(objmat);
mean_pen=mean(penmat);

obj=Solution.ObjFun;
cst=Solution.Cost;
pen=Solution.Penalty;

disp(['GA Phase: ' 'It = ' num2str(0) ', ObjFun =  ' num2str(Solution.ObjFun) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 

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

        [pop(i).ObjFun,pop(i).Penalty,pop(i).Cost,pop(i).Subcost]=CostFunction(model,pop(i).SOL,CFD);
        
    end
    
    cost=zeros(1,PopGA);
    objmat=zeros(1,PopGA);
    penmat=zeros(1,PopGA);
    for i=1:PopGA
        cost(i)=pop(i).Cost;
        objmat(i)=pop(i).ObjFun;
        penmat(i)=pop(i).Penalty;
    end

    %%%%%%%%%%%%%%%%%%%% Sort Population 

    [val,ind]=sort(cost);

    pop=pop(ind);

    Solution=pop(1);
    Result=pop(1).Subcost;

    mean_obj=[mean_obj mean(objmat)];
    mean_cost=[mean_cost mean(cost)];
    mean_pen=[mean_pen mean(penmat)];

    obj=[obj Solution.ObjFun];
    cst=[cst Solution.Cost];
    pen=[pen Solution.Penalty];

    disp(['GA Phase: ' 'It = ' num2str(n) ', ObjFun =  ' num2str(Solution.ObjFun) ', Penalty =  ' num2str(Solution.Penalty) ', Cost =  ' num2str(Solution.Cost)]) 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%% End of the main loop %%%%%%%%%%%%%%%%%%%%%%%%%%

SOL=Solution.SOL

Result=Result

BN_HC=ceil(SOL(1));
BN_MC=ceil(SOL(2));
TH1_HC=ceil(SOL(3));
TH2_HC=max(TH1_HC,ceil(SOL(4)));
TH1_MC=ceil(SOL(5));
TH2_MC=max(TH1_MC,ceil(SOL(6)));
W_C=round(100*SOL(7:11))/100;
W_F=round(100*SOL(12:16))/100;
A_C=round(2*SOL(17:21))/2;
A_F=round(2*SOL(22:26))/2;
NumInputMFsF=1+2*ceil(SOL(27));
NumOutputMFsF=3+2*ceil(SOL(28));
NumInputMFsC=1+2*ceil(SOL(29));
NumOutputMFsC=3+2*ceil(SOL(30));

DataName=['DataFolder/MetaFIS_' num2str(5) '_' num2str(10) '_' num2str(500) '_' num2str(100) '_' '.mat'];
save(DataName,'BN_HC','BN_MC','TH1_HC','TH2_HC','TH1_MC','TH2_MC','W_C','W_F','A_C','A_F','NumInputMFsF','NumOutputMFsF','NumInputMFsC','NumOutputMFsC','Result','obj','pen','mean_obj','mean_pen')
